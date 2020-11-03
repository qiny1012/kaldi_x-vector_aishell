. ./cmd.sh
. ./path.sh


mfccdir=mfcc
vaddir=vad
for name in train test; do
    steps/make_mfcc.sh --write-utt2num-frames true --mfcc-config conf/mfcc.conf --nj 20 --cmd "$train_cmd" \
        data/${name} exp/make_mfcc $mfccdir
    utils/fix_data_dir.sh data/${name}
    sid/compute_vad_decision.sh --nj 40 --cmd "$train_cmd" \
        data/${name} exp/make_vad $vaddir
    utils/fix_data_dir.sh data/${name}
done