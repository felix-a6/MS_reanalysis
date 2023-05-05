from pymsconvert.pymsconvert import *
import argparse
import os

if __name__=='__main__':
    parser = argparse.ArgumentParser(description='conversion_raw_to_mgf')
    parser.add_argument('in_dir', type=str,
                        help='input directory')
    parser.add_argument('out_dir', type=str,
                        help='output directory')
    parser.add_argument('thermoraw_path', type=str,
                        help='-')
    parser.add_argument('slurm_home', type=str,
                        help='-')
    parser.add_argument('env_file', type=str,
                        help='-')
    parser.add_argument('time_limit', type=str, default = '01:00:00', 
                        help='-')

    args = parser.parse_args()

    C = Converter(args.in_dir, args.out_dir, args.thermoraw_path, args.env_file, args.slurm_home, args.time_limit, in_format = 'raw')

    files = [f for f in os.listdir(C.in_dir) if
        os.path.isfile(os.path.join(C.in_dir, f)) and C.in_format in f.lower()]

    files_exist = [ os.path.isfile(os.path.join(C.in_dir, f)) for f in os.listdir(C.in_dir)]

    files_format =[ C.in_format in f.lower() for f in os.listdir(C.in_dir)]

    print(C.in_dir)
    print(files_exist)
    print(files_format)
    print(C.in_format)

    f_list = C.get_file_list()

    C.convert_slurm()