. ./path.sh
. ./cmd.sh

nnet_dir=exp/xvector_nnet_1a
mfccdir=mfcc
vaddir=vad

#split the test to enroll and eval
mkdir -p data/test/enroll data/test/eval
cp data/test/spk2utt data/test/enroll
cp data/test/spk2utt data/test/eval
cp data/test/feats.scp data/test/enroll
cp data/test/feats.scp data/test/eval
cp data/test/vad.scp data/test/enroll
cp data/test/vad.scp data/test/eval

local/split_data_enroll_eval.py data/test/utt2spk  data/test/enroll/utt2spk  data/test/eval/utt2spk
trials=data/test/aishell_speaker_ver.lst
local/produce_trials.py data/test/eval/utt2spk $trials
utils/fix_data_dir.sh data/test/enroll
utils/fix_data_dir.sh data/test/eval

sid/nnet3/xvector/extract_xvectors.sh --cmd "$train_cmd --mem 10G" --nj 20 \
    $nnet_dir data/test \
    $nnet_dir/xvectors_test