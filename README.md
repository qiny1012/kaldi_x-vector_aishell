## 使用kaldi中的x-vector在aishell数据库上建立说话人识别系统

**写在前面**

整个系统可以分为三个部分，第一，前端预处理部分，主要包括mfcc特征提取，VAD，数据扩充（增加混响、增加不同类型的噪声）等；第二，训练基于TDNN的特征提取器，该结构生成说话人表征，说话人表征也可以被称为embedding、x-vector；第三，后端处理，对于说话人表征，采用LDA进行降维并训练PLDA模型对测试对进行打分。

x-vector的论文发表在ICASSP 2018，kaldi的核心开发者Daniel Povey也是这篇论文的作者之一，论文来链接如下：

[X-VECTORS: ROBUST DNN EMBEDDINGS FOR SPEAKER RECOGNITION](https://ieeexplore.ieee.org/document/8461375)

#### 开始构建系统

使用kaldi进行建立基于x-vector的说话人识别系统，主要是通过脚本来实现的。在官方项目x-vector(`~/kaldi/egs/sre16/v2`) 中，通过run.sh脚本在SRE相关数据库上进行训练。我们将这部分代码迁移到aishell数据库上，在迁移过程中有部分代码进行了修改。于是将原有的run.sh脚本分成了9个内容更小的脚本，并且在jupyter notebook中运行，jupyter notebook可以记录了每一段脚本的log，能够帮助我们更好的理解每一段脚本的含义。

相关代码发布到github:

https://github.com/qiny1012/kaldi_x-vector_aishell

#### 准备工作

1. 准备好AISHELL，MUSAN，RIRS_NOISES的数据库；

2. 将x-vector的项目复制到合适的位置，原来项目的地址在`~/kaldi/egs/sre16/v2`；

3. 在path.sh中配置kaldi的存放位置，这个代码会将kaldi的目录增加到环境变量中；

4. 修改cmd.sh中的内容，将queue.pl改为run.pl，并设置一个合适自己计算机的内存大小。注意，使用多台计算机并行运算使用queue.pl，一台计算机运算使用run.pl；

5. 将一些脚本从下面这些地址中复制到当前的项目的local中：

   `~/kaldi/egs/aishell/v1/local/aishell_data_prep.sh`     

   `~/kaldi/egs/aishell/v1/local/produce_trials.py`  

   `~/kaldi/egs/aishell/v1/local/split_data_enroll_eval.py`  

   `~/kaldi/egs/voxceleb/v2/local/prepare_for_eer.py`  

#### 运行脚本

在jupyter notebook中打开，[使用kaldi在aishell上进行x-vector实验的流程.ipynb](https://github.com/qiny1012/kaldi_x-vector_aishell/blob/master/%E4%BD%BF%E7%94%A8kaldi%E5%9C%A8aishell%E4%B8%8A%E8%BF%9B%E8%A1%8Cx-vector%E5%AE%9E%E9%AA%8C%E7%9A%84%E6%B5%81%E7%A8%8B.ipynb)，按照步骤分别运行。

**1.准备训练集、测试集的配置文件**

这段脚本将当前的项目的目录中建立一个data文件，里面将生成一些配置文件。

核心的配置文件包括下面这些：

```
	    data
​		├── test
​		│   ├── spk2utt
​		│   ├── text
​		│   ├── utt2spk
​		│   └── wav.scp
​		└── train
​    		├── spk2utt
​    		├── text
​    		├── utt2spk
​    		└── wav.scp
```

其中spk2utt文件是每个说话人和语音段的映射，text是每一个语音段的转义文本（没有有使用），utt2spk是每个语音段和说话人的映射，wav.scp是每个语音段和具体位置的映射。

**2.准备原始语音的mfcc表征，并进行VAD操作**

将data/train和data/test中涉及的文件提取mfcc特征，并进行VAD操作。conf/mfcc.conf中存放了mfcc的参数。

**3.数据扩充（加混响，加噪音）**

每个段语音分别被加混响，加noise，加music，加speech增强，扩充了4倍的数据。
RIRS_NOISES数据库需要解压到当前文件夹下，即`/YOU_path/v2/`。若下一步操作中出现`(360294 != 480392),...,Less than 95% the features were successfully generated. Probably a serious error.`之类的警告，则为系统找不到混响数据库，请检查RIR_NOISES数据库的位置。

**4.提取扩充数据的mfcc表征和VAD**

**5.过滤语音**

代码主要进行了4个工作，第一个工作，将data/train和data/train_aug的配置文件合并，配置文件合并在之前的代码中已经使用过；第二个工作，按照VAD的结果去除静音帧，并在每一段语音进行归一化（CMVN）；第三个工作，去除语音长度小于2s的语音，这个操作需要和在训练过程中的最大帧参数保持一致；第四个工作，去除语音数量少于8的说话人。

**6.训练x-vector**

在执行这个过程中会出现一个错误，根据 https://blog.csdn.net/weixin_43056919/article/details/87480205 中的描述，只需要生成一个0.raw的文件就可以。

最终训练好的模型存放的位置是`exp/xvector_nnet_1a/final.raw`

**7.提取训练数据的说话人表征，然后LDA降维再训练PLDA**

**8.在测试集中制作任务，并提取他们的说话人表征**

**9.利用PLAD计算每个测试对的得分，并计算最终的EER以及minDCF**

```
训练了80次的结果：
EER: 0.6745%
minDCF(p-target=0.01): 0.1043
minDCF(p-target=0.001): 0.1816
```
