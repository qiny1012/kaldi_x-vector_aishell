. ./cmd.sh
. ./path.sh

steps/data/reverberate_data_dir.py \
--rir-set-parameters "0.5, /home/qinyc/openSLR/SLR28_rir/RIRS_NOISES/simulated_rirs/smallroom/rir_list" \
--rir-set-parameters "0.5, /home/qinyc/openSLR/SLR28_rir/RIRS_NOISES/simulated_rirs/mediumroom/rir_list" \
--speech-rvb-probability 1 \
--pointsource-noise-addition-probability 0 \
--isotropic-noise-addition-probability 0 \
--num-replications 1 \
--source-sampling-rate 16000 \
data/train data/train_reverb

cp data/train/vad.scp data/train_reverb/
utils/copy_data_dir.sh --utt-suffix "-reverb" data/train_reverb data/train_reverb.new
rm -rf data/train_reverb
mv data/train_reverb.new data/train_reverb



# Prepare the MUSAN corpus, which consists of music, speech, and noise
# suitable for augmentation.
steps/data/make_musan.sh --sampling-rate 16000 /home/qinyc/openSLR/SLR17_musan/musan data

# Get the duration of the MUSAN recordings.  This will be used by the
# script augment_data_dir.py.
for name in speech noise music; do
    utils/data/get_utt2dur.sh data/musan_${name}
    mv data/musan_${name}/utt2dur data/musan_${name}/reco2dur
done

# Augment with musan_noise
steps/data/augment_data_dir.py --utt-suffix "noise" --fg-interval 1 --fg-snrs "15:10:5:0" --fg-noise-dir "data/musan_noise" data/train data/train_noise
# Augment with musan_music
steps/data/augment_data_dir.py --utt-suffix "music" --bg-snrs "15:10:8:5" --num-bg-noises "1" --bg-noise-dir "data/musan_music" data/train data/train_music
# Augment with musan_speech
steps/data/augment_data_dir.py --utt-suffix "babble" --bg-snrs "20:17:15:13" --num-bg-noises "3:4:5:6:7" --bg-noise-dir "data/musan_speech" data/train data/train_babble

# Combine reverb, noise, music, and babble into one directory.
utils/combine_data.sh data/train_aug data/train_reverb data/train_noise data/train_music data/train_babble

