. ./path.sh
. ./cmd.sh



# $train_cmd exp/xvectors_train_combined/log/compute_mean.log \
#     ivector-mean scp:exp/xvectors_train_combined/xvector.scp \
#     exp/xvectors_train_combined/mean.vec || exit 1;

nnet_dir=exp/xvector_nnet_1a
mfccdir=mfcc
vaddir=vad
trials=data/test/aishell_speaker_ver.lst
$train_cmd exp/scores/log/test_score.log \
    ivector-plda-scoring --normalize-length=true \
   "ivector-copy-plda --smoothing=0.0 exp/xvectors_train_combined/plda - |" \
    "ark:ivector-subtract-global-mean exp/xvectors_train_combined/mean.vec scp:$nnet_dir/xvectors_test/xvector.scp ark:- | transform-vec exp/xvectors_train_combined/transform.mat ark:- ark:- | ivector-normalize-length ark:- ark:- |" \
    "ark:ivector-subtract-global-mean exp/xvectors_train_combined/mean.vec scp:$nnet_dir/xvectors_test/spk_xvector.scp ark:- | transform-vec exp/xvectors_train_combined/transform.mat ark:- ark:- | ivector-normalize-length ark:- ark:- |" \
    "cat '$trials' | cut -d\  --fields=1,2 |" exp/scores_test || exit 1;


eer=`compute-eer <(local/prepare_for_eer.py $trials exp/scores_test) 2> /dev/null`
mindcf1=`sid/compute_min_dcf.py --p-target 0.01 exp/scores_test $trials 2> /dev/null`
mindcf2=`sid/compute_min_dcf.py --p-target 0.001 exp/scores_test $trials 2> /dev/null`
echo "EER: $eer%"
echo "minDCF(p-target=0.01): $mindcf1"
echo "minDCF(p-target=0.001): $mindcf2"