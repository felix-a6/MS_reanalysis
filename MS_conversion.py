from pymsconvert.pymsconvert import *
import argparse

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


    C = Converter(args['in_dir'], args['out_dir'], args['thermoraw_path'], args['env_file'], args['slurm_home'], args['time_limit'])
    f_list = C.get_file_list()

    C.convert_slurm()