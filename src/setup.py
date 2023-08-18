#-------------------------------------------------------------
# Name:         setup.py
# Description:  script sets up a working environment,
#               defines file paths for data import and output.
# Author:       Florian Franz
# Contact:      florian.franz@nw-fva.de
#-------------------------------------------------------------

import os

# 01 - setup working environment
# --------------------------------

# create directory called 'data' with subdirectories
# 'raw_data', 'processed_data', and 'metadata'
base_dir = os.path.abspath('.')[:-8]

data_directories = [
    os.path.join(base_dir, 'data/raw_data/nDSM'),
    os.path.join(base_dir, 'data/raw_data/DOP'),
    os.path.join(base_dir, 'data/raw_data/gaps_poly'),
    os.path.join(base_dir, 'data/processed_data'),
    os.path.join(base_dir, 'data/metadata')
]

for directory in data_directories:
    if not os.path.exists(directory):
        os.makedirs(directory)

# create other necessary directories
other_directories = [
    os.path.join(base_dir, 'src'),
    os.path.join(base_dir, 'scripts'),
    os.path.join(base_dir, 'output')
 ]

for directory in other_directories:
    if not os.path.exists(directory):
        os.makedirs(directory)

# 02 - file path definitions
# ---------------------------

# define raw data directory
raw_data_dir = 'data/raw_data/'
raw_data_dir = os.path.join(base_dir, raw_data_dir)

# define processed data directory
processed_data_dir = 'data/processed_data/'
processed_data_dir = os.path.join(base_dir, processed_data_dir)

# define output directory
output_dir = 'output/'
output_dir = os.path.join(base_dir, output_dir)

# list the files and directories
print(os.listdir(base_dir))
