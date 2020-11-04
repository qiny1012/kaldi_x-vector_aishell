. ./path.sh
. ./cmd.sh


## 计算训练集的x-vector
nnet_dir=exp/xvector_nnet_1a
sid/nnet3/xvector/extract_xvectors.sh --cmd "$train_cmd --mem 12G" --nj 20\
    $nnet_dir data/train_combined \
    exp/xvectors_train_combined
    
## 计算训练集x-vector的均值
$train_cmd exp/xvectors_train_combined/log/compute_mean.log \
    ivector-mean scp:exp/xvectors_train_combined/xvector.scp \
    exp/xvectors_train_combined/mean.vec || exit 1;

# 利用LDA将数据进行降维
# This script uses LDA to decrease the dimensionality prior to PLDA.
lda_dim=150
$train_cmd exp/xvectors_train_combined/log/lda.log \
    ivector-compute-lda --total-covariance-factor=0.0 --dim=$lda_dim \
    "ark:ivector-subtract-global-mean scp:exp/xvectors_train_combined/xvector.scp ark:- |" \
    ark:data/train_combined/utt2spk exp/xvectors_train_combined/transform.mat || exit 1;

## 训练PLDA模型
# Train an out-of-domain PLDA model.
$train_cmd exp/xvectors_train_combined/log/plda.log \
    ivector-compute-plda ark:data/train_combined/spk2utt \
    "ark:ivector-subtract-global-mean scp:exp/xvectors_train_combined/xvector.scp ark:- | transform-vec exp/xvectors_train_combined/transform.mat ark:- ark:- | ivector-normalize-length ark:-  ark:- |" \
    exp/xvectors_train_combined/plda || exit 1;
    