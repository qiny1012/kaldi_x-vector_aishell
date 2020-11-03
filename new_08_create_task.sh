. ./path.sh
. ./cmd.sh

nnet_dir=exp/xvector_nnet_1a
mfccdir=mfcc
vaddir=vad

# steps/make_mfcc.sh --write-utt2num-frames true --mfcc-config conf/mfcc.conf --nj 20 --cmd "$train_cmd" \
#     data/test exp/make_mfcc $mfccdir
# utils/fix_data_dir.sh data/test
# sid/compute_vad_decision.sh --nj 10 --cmd "$train_cmd" \  ## 进程数太大，无法将任务分割
#     data/test exp/make_vad $vaddir
# utils/fix_data_dir.sh data/test



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

sid/nnet3/xvector/extract_xvectors.sh --cmd "$train_cmd --mem 4G" --nj 1 --use-gpu true \
    $nnet_dir data/test \
    $nnet_dir/xvectors_test