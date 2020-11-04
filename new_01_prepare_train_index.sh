. ./cmd.sh
. ./path.sh

set -e # exit on error
data=/home/qinyc/aishell

# Data Preparation
local/aishell_data_prep.sh $data/data_aishell/wav $data/data_aishell/transcript