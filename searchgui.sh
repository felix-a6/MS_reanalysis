#!/bin/bash

#SBATCH --account=def-xroucou
#SBATCH --time=05:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=10G
#SBATCH --array=1

module load java

FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /scratch/felix6/RBC_MS_analysis/whole_rbc_IP_lysis_6840_mgf/mgf_files_list.txt)
EXP_NAME=${FILE%.mgf}
OUT_PATH=$SLURM_TMPDIR/$EXP_NAME
mkdir $OUT_PATH
cp /home/felix6/scratch/RBC_MS_analysis/human_proteome_fasta/human_proteome_and_xavier.fasta $SLURM_TMPDIR
search_db=$SLURM_TMPDIR/human_proteome_and_xavier.fasta

echo "copying compomics"
cp -R /home/felix6/scratch/RBC_MS_analysis/compomics $SLURM_TMPDIR
searchgui_jar_path=$SLURM_TMPDIR/compomics/SearchGUI-4.2.12/SearchGUI-4.2.12.jar
echo $searchgui_jar_path

mkdir $SLURM_TMPDIR/mgfs
echo "copying $FILE"
cp /scratch/felix6/RBC_MS_analysis/whole_rbc_IP_lysis_6840_mgf/$FILE $SLURM_TMPDIR/mgfs
spectra_file=$SLURM_TMPDIR/mgfs/$FILE

echo "will analyze $spectra_file, with decoy $search_db"

tmp_dir=$SLURM_TMPDIR/tmp
mkdir -p $tmp_dir

java -cp $searchgui_jar_path eu.isas.searchgui.cmd.PathSettingsCLI \
	-temp_folder $tmp_dir \
	-use_log_folder 0

java -cp $searchgui_jar_path eu.isas.searchgui.cmd.IdentificationParametersCLI \
	-fixed_mods "Carbamidomethylation of C" \
	-enzyme "Trypsin (no P rule)" \
	-max_charge 5 \
	-xtandem_min_frag_mz 50 \
	-myrimatch_num_ptms 5 \
	-ms_amanda_instrument "b, y, -H2O, -NH3" \
	-comet_num_ptms 5 \
	-comet_remove_meth 1 \
	-variable_mods "Oxidation of M" \
	-frag_tol 0.5 \
	-frag_ppm 0 \
	-prec_tol 0.5 \
	-prec_ppm 0 \
	-msgf_instrument 1 \
	-msgf_protocol 5 \
	-msgf_fragmentation 3 \
	-use_log_folder 0 \
	-out $OUT_PATH/id_params.par

java -Xmx27G -cp $searchgui_jar_path eu.isas.searchgui.cmd.SearchCLI \
	-spectrum_files $spectra_file\
	-fasta_file $search_db \
	-output_folder $OUT_PATH \
	-id_params $OUT_PATH/id_params.par \
	-andromeda 0 \
	-omssa 1 \
	-xtandem 1 \
	-msgf 1 \
	-ms_amanda 0 \
	-myrimatch 0 \
	-comet 1 \
	-tide 0 \
	-protein_fdr 1 \
	-use_log_folder 0

echo "copying output"
mkdir /home/felix6/scratch/RBC_MS_analysis/searchgui_output
ls $OUT_PATH
cp -R $OUT_PATH /home/felix6/scratch/RBC_MS_analysis/searchgui_output/
echo "output copied"