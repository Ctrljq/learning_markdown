![image-20241222142406456](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241222142406456.png)

==图像中像素点太多了，如果需要更多的特征就必须构建很长的序列。越长的序列算起注意力肯定越慢，这就导致了效率问题==
能否==用窗口和分层的形式来替代长序列==的方法呢？这就是它的本质

# 一、整体网络架构

1.得到各Pathch特征构建序列；2.分层计算attention（逐步下采样过程）

**其中Block是最核心的，对attention的计算方法进行了改进**

![image-20241222142606727](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241222142606727.png)

> 首先将图片输入到Patch Partition模块中进行分块，即每4x4相邻的像素为一个Patch，然后在channel方向展平（flatten）。假设输入的是RGB三通道图片，那么每个patch就有4x4=16个像素，然后每个像素有R、G、B三个值所以展平后是16x3=48，所以==通过Patch Partition后图像shape由 [H, W, 3]变成了 [H/4, W/4, 48]==。然后==再通过Linear Embeding层对每个像素的channel数据做线性变换，由48变成C，即图像shape再由 [H/4, W/4, 48]变成了 [H/4, W/4, C]==。**其实在源码中Patch Partition和Linear Embeding就是直接通过一个卷积层实现的**，和之前Vision Transformer中讲的 Embedding层结构一模一样。
>
> 然后就是通过四个Stage构建不同大小的特征图，==除了Stage1中先通过一个Linear Embeding层外，剩下三个stage都是先通过一个Patch Merging层进行下采样==。然后都是重复堆叠Swin Transformer Block注意这里的Block其实有两种结构，如图(b)中所示，这两种结构的不同之处仅在于一个使用了W-MSA结构，一个使用了SW-MSA结构。而且这两个结构是成对使用的，先使用一个W-MSA结构再使用一个SW-MSA结构。所以你会发现堆叠Swin Transformer Block的次数都是偶数（因为成对使用）。
>
> 最后对于分类网络，后面还会接上一个Layer Norm层、全局池化层以及全连接层得到最终输出。图中没有画，但源码中是这样做的。
>

## 1、Transformer Blocks

这俩是一个组合（得一起上）
**W-MSA：基于窗口的注意力计算**
**SW-MSA：窗口滑动后重新计算注意力**
它俩串联在一起就是一个block

![image-20241222142758292](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241222142758292.png)

## 2、PipeLine

### 2.1、Patch Embeding

**Patch Embedding** 是一种用于将图像输入适配为 Transformer 模型可处理的序列数据的方法。其主要目的是将图像数据从二维空间表示（如像素矩阵）转化为一维的向量序列，为 Transformer 提供输入。

> ### **目的**
>
> | **目的**           | **解释**                                                     |
> | ------------------ | ------------------------------------------------------------ |
> | **结构化输入适配** | Transformer 原本设计用于处理一维序列（如自然语言中的词序列），Patch Embedding 将二维图像转化为一维向量序列，使其适配 Transformer 输入格式。 |
> | **降维与特征压缩** | 将原始图像的高分辨率像素矩阵划分为固定大小的小块（patch），减少数据量，同时保留每个 patch 的特征信息。 |
> | **捕获局部信息**   | 每个 patch 表示局部区域的信息，有助于 Transformer 更好地理解图像的空间结构和特征分布。 |
> | **特征表示初始化** | 在嵌入阶段，通常会使用线性投影或卷积来提取每个 patch 的特征，为后续的 Transformer 模块提供高质量的特征表示。 |
>
> ------
>
> ### **工作过程**
>
> 1. **划分图像为 Patch**
>    - 将输入图像 $X \in \mathbb{R}^{H \times W \times C}$ 划分为固定大小的 patch，每个 patch 的大小为 $P \times P$。
>    - 得到的 patch 数量为 $N = \frac{H}{P} \times \frac{W}{P}$。
> 2. **线性投影**
>    - 每个 patch 被展平为一维向量 $x_i \in \mathbb{R}^{P^2 \cdot C}$。
>    - 然后通过一个线性变换（通常是一个可学习的全连接层）投影到固定维度的嵌入空间 $E \in \mathbb{R}^d$，即$x_i' = W \cdot x_i + b$。
> 3. **嵌入位置编码**
>    - 为了保留图像的空间位置信息，通常会为每个 patch 加入可学习的位置编码$\text{pos}_i$，即最终嵌入为： $z_i = x_i' + \text{pos}_i$
> 4. **输出序列**
>    - 最终得到的输出是一个包含所有 patch 的嵌入序列$Z \in \mathbb{R}^{N \times d}$，其中 N 是 patch 数量，d 是嵌入维度。

```
输入：图像数据（224，224，3）
输出：（3136，96）相当于序列长度是3136个，每个的向量是96维特征(96为嵌入维度)

通过卷积得到，Conv2d(3, 96, kernel_size=(4, 4), stride=(4, 4)）

3136也就是 (224/4) * (224/4)得到的，也可以根据需求更改卷积参数
```

==（224，224，3）->（3136，96）==

### 2.2、window_partition

```
输入：特征图（56，56，96）
默认窗口大小为7，所以总共可以分成8*8个窗口
输出：特征图（64，7，7，96）
之前的单位是序列，现在的单位是窗口（共64个窗口）
```

==（56，56，96）->（64，7，7，96）==

2.3、**Patch Merging**

该模块的作用是在每个Stage开始前做[降采样](https://zhida.zhihu.com/search?content_id=169709736&content_type=Article&match_order=1&q=降采样&zhida_source=entity)，用于缩小分辨率，调整通道数 进而形成层次化的设计，同时也能节省一定运算量。

> 在CNN中，则是在每个Stage开始前用`stride=2`的卷积/池化层来降低分辨率。

每次降采样是两倍，因此**在行方向和列方向上，间隔2选取元素**。

然后拼接在一起作为一整个[张量](https://zhida.zhihu.com/search?content_id=169709736&content_type=Article&match_order=1&q=张量&zhida_source=entity)，最后展开。**此时通道维度会变成原先的4倍**（因为H,W各缩小2倍），此时再通过一个**全连接层再调整通道维度为原来的两倍**

![img](https://pic3.zhimg.com/v2-a1a0ea5d9455083caed65006433c4efe_1440w.jpg)

### 2.4、W-MSA

（Window Multi-head Self Attention）

==对得到的窗口，计算各个窗口自己的自注意力得分==

```py
qkv = self.qkv(x).reshape(B_, N, 3, self.num_heads, C // self.num_heads).permute(2, 0, 3, 1, 4)
q = q * self.scale  #缩放的目的是为了防止在计算注意力得分时出现数值过大的情况，从而导致软最大化函数（Softmax）输出非常小的梯度，造成梯度消失。在深度学习中，这种数值稳定性是非常重要的。self.scale为（1/根d）
# 注意力得分的范围会显著扩大，导致 Softmax 的输出接近于 0 或 1
```

```
qkv三个矩阵放在一起了：（3，64，3，49，32）  
```

```
（qkv，窗口数，多头，7* 7，嵌入维度/多头） 
3个矩阵，64个窗口，heads为3，窗口大小7*7=49，每个head特征96/3=32
```

$Attention(Q,K,V)=SoftMax(\frac{QK^T}{\sqrt{D}}+B)V$

==attention结果为：（64，3，49，49） 每个头都会得出每个窗口内的自注意力==

64个窗口，3个头，窗口内49个与49个间的自注意力机制

### 2.5、window_reverse❤️

==将attention结果（64，3，49，49）进行重构计算得到新的特征（64，49，96）==

总共64个窗口，每个窗口7*7的大小，每个点对应96维向量

==window_reverse就是通过reshape操作还原回去（56，56，96）==

这就==得到了跟输入特征图一样的大小，但是其已经计算过了attention==

### 2.6、SW-MSA

（Shifted Window）

为什么要shift？原来的window都是算自己内部的
这样就会导致只有内部计算，没有它们之间的关系
容易上模型局限在自己的小领地，可以通过shift操作来改善

左边是没有重叠的Window Attention，而右边则是将窗口进行移位的Shift Window Attention。可以看到移位后的窗口包含了原本相邻窗口的元素。但这也引入了一个新问题，即**window的个数翻倍了**，由原本四个窗口变成了9个窗口。

==在实际代码里，我们是**通过对特征图移位，并给Attention设置mask来间接实现的**。能在**保持原有的window个数下**，最后的计算结果等价。==

![img](https://pic3.zhimg.com/v2-07a98325a29db1da6521e4ddaaed3c88_1440w.jpg)

#### **特征图移位操作**

代码里对特征图移位是通过`torch.roll`来实现的，下面是示意图

![img](https://pica.zhimg.com/v2-8d8274d62026e0732c8a7827de1070fc_1440w.jpg)

<img src="https://pica.zhimg.com/v2-52b0bec2b0e2341e1eab1fd6342bc9e6_1440w.jpg" alt="img" style="zoom:50%;" />

<img src="https://pica.zhimg.com/v2-af19485ae400a2f52ede6306fcfb078e_1440w.jpg" alt="img" style="zoom: 25%;" />

# 二、为什么能提高小目标精度

> Swin Transformer 在检测小目标方面表现优秀，主要原因是其架构和特性在捕获细粒度的局部特征和全局上下文信息上有显著优势。以下是具体原因：
>
> ------
>
> ### **1. 分层特性（Hierarchical Feature Maps）**
>
> - 分层结构：Swin Transformer 的多层次特征提取机制类似于卷积神经网络（如 ResNet），能够逐步提取从低级到高级的特征。
>   - 低级特征层（浅层）保留了更多的细节信息，对小目标（通常只占据图像较少像素）尤为关键。
>   - 高级特征层则捕获更多语义信息，帮助更准确地识别目标。
> - **实际效果**：通过逐步下采样，浅层特征对小目标的纹理、边缘细节进行精细建模，而高层特征负责提供全局上下文支持。
>
> ------
>
> ### **2. 局部感受野（Window-based Attention）**
>
> - 窗口注意力机制（Window Attention）：Swin Transformer 使用固定大小的局部窗口（如 $7 \times 7$）进行自注意力计算。
>   - ==这种机制使得模型能够聚焦于局部区域的细节==。
>   - ==对小目标的边界和纹理信息有更精确的捕获能力==。
> - 相比传统 Transformer：
>   - 全局自注意力（Global Attention）对小目标的局部信息可能过于分散。
>   - 窗口注意力限制了计算范围，使得模型更加专注于局部信息，同时降低了计算复杂度。
>
> ------
>
> ### **3. 滑动窗口机制（Shifted Window Attention）**
>
> - 窗口移动（Shifted Window）：在 Swin Transformer 中，窗口之间通过滑动操作（Shift）实现信息交互。
>   - 常规窗口注意力容易导致窗口之间的信息割裂，小目标特征可能被分隔在不同窗口中。
>   - 滑动窗口有效缓解了这一问题，通过跨窗口的特征聚合，增强了对小目标的全局建模能力。
> - 实际效果：
>   - 即使小目标处于窗口边界区域，滑动窗口机制也能使其与周围上下文信息连接起来。
>
> ------
>
> ### **4. 自适应尺度建模（Multi-scale Representation）**
>
> - 多尺度特征提取：Swin Transformer 的分层架构支持多尺度建模，每层特征具有不同的分辨率。
>   - 小目标的细节信息可以在浅层保留，高层的全局信息可以为上下文建模提供支持。
> - 结合应用：检测小目标：
>   - ==多尺度特征结合 FPN（Feature Pyramid Network）等技术，进一步增强小目标检测效果。==
>
> ------
>
> ### **5. 丰富的全局上下文信息**
>
> - 全局建模能力：尽管 Swin Transformer以局部窗口为核心，但通过滑动窗口和跨窗口操作，模型仍然可以高效捕获全局上下文。
>   - 小目标通常依赖其周围上下文进行检测（如背景、邻近目标）。
>   - Swin Transformer 在保持局部精度的同时，提供了更好的上下文感知能力。
>
> ------
>
> ### **6. 模型的归纳偏置（Inductive Bias）**
>
> - 类卷积的特性：Swin Transformer 的分层设计和局部窗口类似于卷积神经网络，天然具有对局部信息的建模优势。
>   - 这种归纳偏置使得它对小目标更友好，尤其是空间上紧凑的小目标。
>
> ------
>
> ### **实际应用场景**
>
> 1. **无人驾驶**：检测远处的小行人、车辆等目标。
> 2. **卫星图像分析**：识别高分辨率图像中的小型建筑物或车辆。
> 3. **医疗影像分析**：在 CT 或显微镜图像中定位小病变区域。
> 4. **安防监控**：监测远处或模糊场景中的小型异常行为。
>
> ------
>
> ### **实验对比与验证**
>
> - **与卷积网络（CNN）对比**：Swin Transformer 的多尺度特性和局部注意力使其在小目标检测中性能优于纯卷积网络。
> - **与标准 Transformer 对比**：相比全局自注意力机制（如 ViT），Swin Transformer 的窗口注意力和分层特性更适合捕捉小目标特征。
>
> ------
>
> ### **总结**
>
> Swin Transformer 对小目标检测的优势来自：
>
> 1. 分层架构保留了更多的细粒度信息。
> 2. 局部窗口注意力增强了局部细节捕获。
> 3. 滑动窗口机制缓解了窗口边界效应。
> 4. 多尺度特征表征和全局上下文建模相结合。
>
> 这些特性让 Swin Transformer 成为检测小目标任务中一个高效的模型选择。