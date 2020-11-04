. ./cmd.sh
. ./path.sh

## 1. 将train_aug数据和train数据合并
utils/combine_data.sh data/train_combined data/train_aug data/train
utils/fix_data_dir.sh data/train_combined 
 
## 2. 该脚本应用CMVN并删除非语音帧。 会重新复制一份feature，确保磁盘空间。
local/nnet3/xvector/prepare_feats_for_egs.sh --nj 40 --cmd "$train_cmd" \
    data/train_combined data/train_combined_no_sil exp/train_combined_no_sil
utils/fix_data_dir.sh data/train_combined_no_sil
  
## 3. 如果语音长度少于200帧，会被去除。200帧，（25ms帧长，10ms帧移），大约2s
min_len=200
mv data/train_combined_no_sil/utt2num_frames data/train_combined_no_sil/utt2num_frames.bak
awk -v min_len=${min_len} '$2 > min_len {print $1, $2}' data/train_combined_no_sil/utt2num_frames.bak > data/train_combined_no_sil/utt2num_frames
utils/filter_scp.pl data/train_combined_no_sil/utt2num_frames data/train_combined_no_sil/utt2spk > data/train_combined_no_sil/utt2spk.new
mv data/train_combined_no_sil/utt2spk.new data/train_combined_no_sil/utt2spk
utils/fix_data_dir.sh data/train_combined_no_sil

## 4. 去除语音数量少于8个的说话人。
min_num_utts=8
awk '{print $1, NF-1}' data/train_combined_no_sil/spk2utt > data/train_combined_no_sil/spk2num
awk -v min_num_utts=${min_num_utts} '$2 >= min_num_utts {print $1, $2}' data/train_combined_no_sil/spk2num | utils/filter_scp.pl - data/train_combined_no_sil/spk2utt > data/train_combined_no_sil/spk2utt.new
mv data/train_combined_no_sil/spk2utt.new data/train_combined_no_sil/spk2utt
utils/spk2utt_to_utt2spk.pl data/train_combined_no_sil/spk2utt > data/train_combined_no_sil/utt2spk

utils/filter_scp.pl data/train_combined_no_sil/utt2spk data/train_combined_no_sil/utt2num_frames > data/train_combined_no_sil/utt2num_frames.new
mv data/train_combined_no_sil/utt2num_frames.new data/train_combined_no_sil/utt2num_frames
# Now we're ready to create training examples.
utils/fix_data_dir.sh data/train_combined_no_sil