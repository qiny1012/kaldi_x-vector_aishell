. ./cmd.sh
. ./path.sh


mfccdir=feature/mfcc
steps/make_mfcc.sh --mfcc-config conf/mfcc.conf --nj 20 --cmd "$train_cmd" \
    data/train_aug exp/make_mfcc $mfccdir