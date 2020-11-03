data=/home/qinyc/aishell
data_url=www.openslr.org/resources/33

## hhh
. ./cmd.sh
. ./path.sh

set -e # exit on error

# Data Preparation
local/aishell_data_prep.sh $data/data_aishell/wav $data/data_aishell/transcript