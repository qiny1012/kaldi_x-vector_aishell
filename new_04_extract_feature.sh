. ./cmd.sh
. ./path.sh


mfccdir=mfcc_aug

steps/make_mfcc.sh --mfcc-config conf/mfcc.conf --nj 20 --cmd "$train_cmd" \
    data/train_aug exp/make_mfcc $mfccdir