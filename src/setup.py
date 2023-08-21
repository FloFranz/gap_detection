#-------------------------------------------------------------
# Name:         setup.py
# Description:  script sets up a working environment,
#               defines file paths for data import and output.
# Author:       Florian Franz
# Contact:      florian.franz@nw-fva.de
#-------------------------------------------------------------

from pathlib import Path

# 01 - setup working environment
# --------------------------------

# create directory called 'data' with subdirectories
# 'raw_data', 'processed_data', and 'metadata'
base_dir = Path(__file__).parents[1]

data_directories = [
    base_dir / 'data' / 'raw_data' / 'nDSM',
    base_dir / 'data' / 'raw_data' / 'DOP',
    base_dir / 'data' / 'raw_data' / 'gaps_poly',
    base_dir / 'data' / 'processed_data',
    base_dir / 'data' / 'metadata'
]

for directory in data_directories:
    directory.mkdir(parents=True, exist_ok=True)

# create other necessary directories
other_directories = [
    base_dir / 'src',
    base_dir / 'scripts',
    base_dir / 'output'
]

for directory in other_directories:
    directory.mkdir(parents=True, exist_ok=True)

# 02 - file path definitions
# ---------------------------

# define raw data directory
raw_data_dir = base_dir / 'data' / 'raw_data'

# define processed data directory
processed_data_dir = base_dir / 'data' / 'processed_data'

# define output directory
output_dir = base_dir / 'output'

# list the files and directories
print([p.name for p in base_dir.iterdir()])
