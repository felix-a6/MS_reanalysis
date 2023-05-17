#!/bin/bash

#SBATCH --account=def-xroucou
#SBATCH --time=02:30:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=10G
#SBATCH --array=1

module load java

FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /scratch/felix6/RBC_MS_analysis/whole_rbc_IP_lysis_6840_mgf/searchgui_out_list.txt)
EXP_NAME=${FILE%.mgf}
OUT_PATH=$SLURM_TMPDIR/$EXP_NAME
mkdir $OUT_PATH

cp -R /home/felix6/scratch/RBC_MS_analysis/compomics $SLURM_TMPDIR
peptideshaker_jar_path=$SLURM_TMPDIR/compomics/PeptideShaker-2.2.23/PeptideShaker-2.2.23.jar

cp /home/felix6/scratch/RBC_MS_analysis/human_proteome_fasta/human_proteome_and_xavier.fasta $SLURM_TMPDIR
search_db=$SLURM_TMPDIR/human_proteome_and_xavier.fasta

#cp searchgui_out $SLURM_TMPDIR
#searchgui_out=$SLURM_TMPDIR/searchgui_out

peptideshaker_out=$OUT_PATH/peptideshaker_out.psdb

tmp_dir=$SLURM_TMPDIR/tmp
mkdir -p $tmp_dir

cp /scratch/felix6/RBC_MS_analysis/whole_rbc_IP_lysis_6840_mgf/$FILE $tmp_dir
local_spectra=$tmp_dir/$FILE    

java -cp $peptideshaker_jar_path eu.isas.peptideshaker.cmd.PathSettingsCLI \
    -temp_folder $tmp_dir \
    -use_log_folder 0

java -Xmx27G -cp {peptideshaker_jar_path} eu.isas.peptideshaker.cmd.PeptideShakerCLI \
    -reference $EXP_NAME \
    -fasta_file $search_db \
    -identification_files $searchgui_out \
    -spectrum_files $local_spectra \
    -out $OUT_PATH/peptideshaker_out.psdb \
    -use_log_folder 0 \
    -zip $peptideshaker_out

echo "Sanity check PeptideShakerCLI with ls on outputs:  peptideshaker_out.psdb.zip and searchgui_out.zip"
ls $OUT_PATH/searchgui_out.zip
ls $OUT_PATH/peptideshaker_out.psdb.zip

echo "peptideshaker done."

echo "copying output"
mkdir /home/felix6/scratch/RBC_MS_analysis/peptideshaker/
cp $OUT_PATH /home/felix6/scratch/RBC_MS_analysis/peptideshaker/
echo "output copied"