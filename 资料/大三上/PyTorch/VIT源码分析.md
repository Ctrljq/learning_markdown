![img](https://github.com/lucidrains/vit-pytorch/raw/main/images/vit.gif)

在 Transformer 模型中，尤其是在 Vision Transformer（ViT）中，序列通常指的是一组一维向量的集合。这些向量代表的是模型处理的基本单元（例如词向量或图像的 patch 向量），它们被组织成一个序列，并作为输入提供给自注意力机制。

## 1|

### **为什么 `(16, 768, 14, 14)` 不是序列，而 `(16, 768, 196)` 是序列？**

1. **(16, 768, 14, 14) 的含义**：
   - **16**：表示 batch size，即一次输入的 16 个样本。
   - **768**：表示每个样本的通道数（或嵌入的特征维度）。
   - **14x14**：表示每个样本的空间维度（高度为 14，宽度为 14），通常对应卷积神经网络中的特征图（feature map）。

   这种形状是 **图像格式**（或特征图格式），通常用于卷积层的输出。它的空间信息仍然以二维形式（高度和宽度）存在，**不是**序列形式。

2. **(16, 768, 196) 的含义**：
   - **16**：表示 batch size，即一次输入的 16 个样本。
   - **768**：表示每个样本的通道数或特征维度。
   - **196**：==表示序列的长度，即 14x14 的二维空间被展平为一维，得到 196 个元素（patch）。==

   这种形状是 **序列格式**，可以理解为包含 196 个 token，每个 token 是一个 768 维的向量。在这种情况下，模型将每个空间位置（patch）当作一个独立的 token，类似于 Transformer 处理文本中的词向量。**(16, 768, 196)** 被认为是序列，因为每个样本的空间信息已经展平成了一个序列，每个 token 都可以独立地被 Transformer 模型处理。
   
   > - **196 是序列长度**，**784 是卷积核个数**，那么我们可以重新解释为什么在这种情况下需要交换维度。
   >
   >   ### 1. **形状 (64, 784, 196) 的含义**
   >
   >   让我们明确形状 `(64, 784, 196)` 的具体含义：
   >
   >   - `64`：表示 batch size，即有 64 个样本。
   >   - `784`：表示每个样本中使用了 784 个卷积核（也可以理解为特征维度的数量，或每个 patch/特征图的数量）。
   >   - `196`：表示每个卷积核或特征图的序列长度，可能对应于经过卷积后的图像或 patch 的展平特征。
   >
   >   ### 2. **为什么交换维度**
   >
   >   在这种情况下，交换维度的主要原因通常和模型的计算需求以及张量处理要求有关。具体来说，交换维度 **(64, 784, 196)** 到 **(64, 196, 784)** 的原因可以从以下几个方面解释：
   >
   >   #### **原因 1：符合矩阵乘法的顺序**
   >
   >   在某些计算过程中，尤其是涉及到矩阵乘法或自注意力机制时，需要对序列长度维度（`196`）和卷积核数量（`784`）进行不同的处理。
   >
   >   - 在自注意力机制中，经常需要对序列进行操作。例如在 Transformer 中，常常需要对**序列长度**维度上的数据进行计算（如 self-attention 中的 Q, K, V 矩阵运算）。
   >   - 假设你需要对序列进行特定的操作，那么序列长度（`196`）通常需要被放到特定的位置（例如作为矩阵乘法中的行或列），这时需要将原始形状调整为 `(64, 196, 784)`，以便处理过程中维度顺序匹配。

### 总结：为什么 `(16, 768, 196)` 是序列？
- **(16, 768, 14, 14)**：这个形状是典型的 **图像特征图格式**，表示 16 张图像的每张图像都有 768 个通道，且每个通道的大小是 14x14，表示的是二维的空间特征。这种情况下，**空间信息以二维形式存在**，并不是一个序列。
  
- **(16, 768, 196)**：这个形状表示的是 16 个样本，每个样本有 196 个 token，每个 token 是 768 维的向量。这里的 **196 是由 14x14 展平而成**，相当于将图像的二维空间信息展平为了一个 **序列**，每个位置（patch）可以独立作为序列中的一个元素进行处理。

在 ViT 中，模型首先将图像切割成小块（patch），并将每个 patch 展平，形成类似于 NLP 中的词向量的输入格式（序列）。这就是为什么 `(16, 768, 196)` 这种形状被认为是序列，而 `(16, 768, 14, 14)` 不是。

> 是的，你的理解是正确的。我们可以从以下两个方面进一步解释：
>
> ### 1. **784 表示特征的维度**
> 在形状 `(64, 784, 196)` 中：
> - `784` 确实表示每个向量的长度，也可以说是**特征的维度**。可以理解为在每个样本中，经过卷积或其他操作后，每个序列（或 patch）被表示为一个 784 维的向量。
>
> ### 2. **196 是由 14x14 展平得到的，表示序列的个数**
> - `196` 是从 14×14 的特征图展平得到的，这个数字实际上代表的是将图像分块（patch）之后的**序列数量**。
> - 具体来说，假设你处理的是 14×14 的特征图，将其展平时，每个位置会形成一个向量，每个向量的长度就是 **784**（也就是特征维度）。因此，`196` 表示图像被分成了 196 个小块（patch），每个块被展平后形成一个长度为 784 的向量。
>
> ### 3. **总结关系**
> - **196**：是序列的个数，即有 196 个 patch。这个数字来源于 14×14 的特征图，展平后的每个 patch 对应于序列中的一个向量。
> - **784**：是每个向量的长度，也就是特征的维度。可以理解为每个 patch 经过处理后，被表示为一个长度为 784 的特征向量。
>
> 因此，**形状 `(64, 784, 196)` 表示的是每个 batch 中的 64 个样本，每个样本有 196 个长度为 784 的向量**，也可以理解为有 196 个 patch，每个 patch 被表示为一个 784 维的词向量。
>
> 如果要处理这类数据，例如在 Transformer 或 ViT 中，我们会对每个向量（长度为 784 的特征向量）进行后续的计算，比如注意力机制等。

## 2、ModuleList

```
ModuleList(
  (0-11): 12 x Block(
    (attention_norm): LayerNorm((768,), eps=1e-06, elementwise_affine=True)
    (ffn_norm): LayerNorm((768,), eps=1e-06, elementwise_affine=True)
    (ffn): Mlp(
      (fc1): Linear(in_features=768, out_features=3072, bias=True)
      (fc2): Linear(in_features=3072, out_features=768, bias=True)
      (dropout): Dropout(p=0.1, inplace=False)
    )
    (attn): Attention(
      (query): Linear(in_features=768, out_features=768, bias=True)
      (key): Linear(in_features=768, out_features=768, bias=True)
      (value): Linear(in_features=768, out_features=768, bias=True)
      (out): Linear(in_features=768, out_features=768, bias=True)
      (attn_dropout): Dropout(p=0.0, inplace=False)
      (proj_dropout): Dropout(p=0.0, inplace=False)
      (softmax): Softmax(dim=-1)
    )
  )
)
```

这个 `ModuleList` 列出了一个包含 12 层 `Block` 的结构，每个 `Block` 都代表 Transformer 的一个编码层（也就是 Transformer 编码器中的一层）。每一层 `Block` 都由**注意力机制**（`Attention`）、**前馈神经网络**（`Mlp`）和**层归一化**（`LayerNorm`）组成。

接下来我结合代码和模块结构逐步解释这个 `ModuleList` 中的每个部分。

### 1. **`ModuleList`**
- `ModuleList` 是 PyTorch 提供的一种容器，用来存放多个 `nn.Module` 子模块。在这个例子中，它存储了 12 层 `Block`，这些 `Block` 是 Transformer 编码器的组成部分。

### 2. **`Block`**
每个 `Block` 是 Transformer 的一个完整层，负责对输入进行自注意力机制和前馈神经网络的操作。每一层包含以下组件：

### **(1) Attention 部分**
这是自注意力机制的核心模块，主要包括：
- **`query`、`key` 和 `value` 线性变换：**
  - 这三个 `Linear` 层对输入的 `hidden_states` 进行线性投影，将其映射为 Q（查询向量）、K（键向量）和 V（值向量）。
  - 这些线性层的输入尺寸是 `768`（输入维度），输出维度也是 `768`，因此投影后的 Q、K、V 向量的维度依然是 `768`。
  
- **`softmax`：**
  - 计算注意力分布，取 `Q` 和 `K` 的点积并应用 softmax 操作，生成注意力权重。
  
- **`attn_dropout` 和 `proj_dropout`：**
  - `attn_dropout` 是应用在注意力权重上的 dropout，用于防止过拟合。
  - `proj_dropout` 是在注意力输出投影后的 dropout。
  
- **`out`：**
  - 将经过加权的 `value` 向量再次通过一个线性层，输出更新的 `hidden_states`。

### **(2) LayerNorm（注意力部分和前馈部分）**
- **`attention_norm` 和 `ffn_norm`**：每一层都会有两个层归一化（Layer Normalization）模块：
  - `attention_norm` 在进行自注意力操作之前应用，用来稳定网络训练。
  - `ffn_norm` 在前馈神经网络之前应用，同样是为了稳定训练。

### **(3) MLP（前馈神经网络）**
这是每个 Transformer 编码层中的前馈网络部分，包含两个全连接层：
- **`fc1` 和 `fc2`：**
  - `fc1` 是从 `768` 维度输入，输出维度为 `3072`。
  - `fc2` 是从 `3072` 维度输入，输出回到 `768`。
  
- **`dropout`：**
  - 用于在前馈网络中引入随机性，防止过拟合。

### 3. **总结解释**
这个 `ModuleList` 中包含了 12 层 `Block`，每个 `Block` 都依次执行：
1. 对输入的 `hidden_states` 应用自注意力机制（`Attention`），生成新的 `hidden_states`。
2. 然后将 `hidden_states` 通过前馈神经网络（`Mlp`）进行进一步的非线性变换。
3. 每一层还包括两个层归一化操作：分别在注意力机制和前馈网络之前进行归一化，以稳定网络训练。

每一层会将更新后的 `hidden_states` 传递给下一层，最终经过 12 层这样的处理，得到最后的输出。

### 直观理解
在 Transformer 中，输入的每个单词/特征的表示（`hidden_states`）会依次通过 12 层这样的编码器，每一层都会计算当前单词和其他单词的相似度（通过 Q、K、V），然后通过前馈网络进一步提取特征。这些层叠加在一起，可以捕捉输入序列中的复杂依赖关系和高级特征。

### 注意：
每一层的 `Block` 模块结构相同，但每一层的权重是不同的，因此每一层都会在不同的程度上处理输入的 `hidden_states`。

> `self.layer` 在添加 `Block` 实例之前和之后的区别主要体现在它的内容和结构的变化。以下是这两种状态下的差异：
>
> ### 1. **添加 `Block` 实例之前的 `self.layer`**
>
> - **定义：**==`self.layer = nn.ModuleList()`==
> - ==此时，`self.layer` 是一个空的 `ModuleList`，还没有任何 `Block` 实例被添加到其中==。
> - **状态：** `self.layer` 是空的，内部没有任何模块或层。其类型是 `nn.ModuleList`，但内容为空。
>
> ```py
> self.layer = ModuleList()  # 空的 nn.ModuleList
> ```
>
> ### 2. **添加 `Block` 实例之后的 `self.layer`**
>
> - 定义：
>
>    通过循环将多个 
>
>   ```py
>   Block
>   ```
>
>    实例添加到 
>
>   ```py
>   self.layer
>   ```
>
>    中：
>
>   ```py
>   for _ in range(config.transformer["num_layers"]):
>       layer = Block(config, vis)
>       self.layer.append(copy.deepcopy(layer))
>   ```
>
> - 在循环中，程序根据 ==`config.transformer["num_layers"]` 的值（比如12层或6层），创建多个独立的 `Block` 实例，并通过深拷贝将它们逐一添加到 `self.layer` 中。==
>
> - **状态：** 此时，`self.layer` 不再为空，而是包含了 `config.transformer["num_layers"]` 个 `Block` 实例。每个 `Block` 代表 Transformer 的一个编码层，每个层都包括自注意力机制、前馈网络、归一化等模块。
>
> ```py
> self.layer = ModuleList(
>     (0-11): 12 x Block(...)  # 12 层 Block，每层包含不同的子模块
> )
> ```

## 3、MLP

`MLP` 是多层感知机（**Multi-Layer Perceptron**）的缩写，通常用于神经网络中的前馈神经网络层，主要用于非线性映射。具体到你提供的代码，它实现了一个两层的前馈网络，并且使用了激活函数和 Dropout 来增加模型的非线性能力以及防止过拟合。

### 代码解释：

```python
class Mlp(nn.Module):
    def __init__(self, config):
        super(Mlp, self).__init__()
        
        # 定义第一个全连接层，输入维度为 hidden_size，输出维度为 mlp_dim
        self.fc1 = Linear(config.hidden_size, config.transformer["mlp_dim"])
        
        # 定义第二个全连接层，输入维度为 mlp_dim，输出维度为 hidden_size
        self.fc2 = Linear(config.transformer["mlp_dim"], config.hidden_size)
        
        # 激活函数，使用 GELU（Gaussian Error Linear Unit）
        self.act_fn = ACT2FN["gelu"]
        
        # Dropout，用于防止过拟合
        self.dropout = Dropout(config.transformer["dropout_rate"])

        # 初始化权重
        self._init_weights()

    def _init_weights(self):
        # 使用 Xavier 初始化全连接层的权重
        nn.init.xavier_uniform_(self.fc1.weight)
        nn.init.xavier_uniform_(self.fc2.weight)
        
        # 初始化偏置项为正态分布，标准差为 1e-6
        nn.init.normal_(self.fc1.bias, std=1e-6)
        nn.init.normal_(self.fc2.bias, std=1e-6)

    def forward(self, x):
        # 第一层全连接 + 激活函数 + Dropout
        x = self.fc1(x)
        x = self.act_fn(x)
        x = self.dropout(x)
        
        # 第二层全连接 + Dropout
        x = self.fc2(x)
        x = self.dropout(x)
        
        return x
```

### 各部分功能说明：

1. **`fc1` 和 `fc2`**：这是两层线性全连接层。
   - `fc1`：将输入的维度从 `config.hidden_size`（例如 768）映射到一个更高的维度 `config.transformer["mlp_dim"]`（例如 3072）。
   - `fc2`：将维度从 `mlp_dim` 再映射回 `hidden_size`。
   
2. **激活函数 (`act_fn`)**：使用的是 `GELU` 激活函数，它是一种常见的非线性激活函数，在 Transformer 和 BERT 等模型中常用。它比传统的 ReLU 函数在处理小梯度时表现更好。

3. **Dropout**：在两个全连接层后使用 Dropout，可以防止模型过拟合，尤其是在训练深度神经网络时。`Dropout` 会随机丢弃一部分神经元，以增强模型的泛化能力。

4. **权重初始化 (`_init_weights`)**：使用 Xavier 均匀初始化权重。这种初始化方式可以帮助梯度在前向传播和反向传播过程中保持稳定，避免梯度消失或爆炸问题。

5. **`forward` 函数**：表示数据前向传播时的流向。
   - 首先，输入经过第一层全连接层，然后通过激活函数，再应用 Dropout。
   - 接着，经过第二层全连接层，并再次应用 Dropout，最后输出。

### 在 Transformer 中的作用：
在 Transformer 中，这个 `MLP` 部分通常是在自注意力层之后的处理步骤，也就是所谓的 “前馈网络层”。通过两层全连接层，MLP 将注意力层的输出经过进一步的非线性变换，以增强模型的学习能力和表达能力。

## 4、注意力层

