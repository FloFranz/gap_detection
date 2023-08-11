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
base_dir = os.path.abspath('.')  # Get the absolute path of the current directory

data_directories = [
    os.path.join(base_dir, 'data/raw_data/nDSM'),
    os.path.join(base_dir, 'data/raw_data/DOP'),
    os.path.join(base_dir, 'data/processed_data'),
    os.path.join(base_dir, 'data/metadata')
]

for directory in data_directories:
    if not os.path.exists(directory):
        os.makedirs(directory)

# create other necessary directories
other_directories = ['src', 'scripts', 'output']

for directory in other_directories:
    if not os.path.exists(directory):
        os.makedirs(directory)

# 02 - file path definitions
# ---------------------------

# define raw data directory
raw_data_dir = 'data/raw_data/'

# define processed data directory
processed_data_dir = 'data/processed_data/'

# define output directory
output_dir = 'output/'

# list the files and directories
print(os.listdir('.'))  # Lists files and directories in the current directory
