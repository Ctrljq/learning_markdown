# 注意力机制学习笔记

这份笔记根据一段关于注意力机制的深度问答对话整理而成，旨在分解其核心概念，特别是自注意力（Self-Attention）和多头注意力（Multi-head Attention），以便于后续复习和巩固理解。

## 1. 核心思想：自注意力 (Self-Attention)

自注意力机制允许模型在处理一个序列时，权衡该序列中不同单词（或称为token）的重要性。它能捕捉输入序列内部的依赖关系。

### 为什么要增加一个维度？—— 批次维度 (Batch Dimension)

在大多数神经网络框架中，为了提高计算效率，数据是以“批次”为单位处理的。因此，即便我们只处理一个句子，也需要手动为其增加一个**批次维度**。

- **原始形状**: `[序列长度, 嵌入维度]` (e.g., `[seq_len, embedding_dim]`)
- **增加批次维度后**: `[1, 序列长度, 嵌入维度]` (e.g., `[1, seq_len, embedding_dim]`)

这种格式统一是为了满足注意力函数对输入形状的标准要求 `[批次大小, 序列长度, 特征深度]` (`[batch_size, seq_len, depth]`)，从而确保代码能够一致地处理单个样本和批量数据。

### QKV 模型：查询（Query）、键（Key）、值（Value）

自注意力机制通过三个由输入嵌入（input embeddings）衍生出的矩阵来工作：

- **查询 (Query, Q)**: 代表当前正在寻找上下文的单词/token。
- **键 (Key, K)**: 代表序列中所有能提供上下文信息的单词/token。
- **值 (Value, V)**: 代表每个单词/token的实际内容或意义。

#### Q, K, V 的初始化

这些矩阵的标准形状是 `[批次大小, 序列长度, 特征深度]`。选择此惯例有几个原因：

1. **自然的序列表示**: 这种结构很直观：(样本数, 序列中的位置, 每个位置的特征)。
2. **模型输入输出一致性**: 与Transformer等模型的输入输出格式保持一致，减少了不必要的维度变换。
3. **行业标准**: 这种“批次优先，特征最后”的格式在TensorFlow、PyTorch等主流框架中被广泛采用。

### 计算步骤详解

#### 步骤 1: 计算注意力分数 (Attention Scores)

为了决定每个词应该对其他所有词投入多少“关注”，我们计算一个分数。这通过查询矩阵 (Q) 和键矩阵 (K) 的点积来完成。

```
# Q 的形状: [batch_size, seq_len_q, depth]
# K 的形状: [batch_size, seq_len_k, depth]

# 为了进行矩阵乘法，需要转置 K 的最后两个维度
# K 转置后的形状: [batch_size, depth, seq_len_k]
matmul_qk = np.matmul(Q, np.transpose(K, [0, 2, 1]))

# 结果形状: [batch_size, seq_len_q, seq_len_k]
```

**为什么必须转置 K？**

矩阵乘法要求两个矩阵的“内部维度”必须匹配。

- 对于高维张量，`np.matmul` 在最后两个维度上执行矩阵乘法。前面的维度必须相同或可广播。
- 规则是: `[..., a, b] @ [..., b, c] = [..., a, c]`
- 在我们的例子中: `[batch, seq_len_q, depth] @ [batch, depth, seq_len_k]` 是有效的，因为内部维度 `depth` 匹配。如果不转置K，`[batch, seq_len_q, depth]` 和 `[batch, seq_len_k, depth]` 的维度将不兼容，无法相乘。

#### 步骤 2: 缩放分数 (Scaling)

点积的结果可能会变得非常大，这会导致softmax函数计算梯度时变得极小，从而阻碍模型学习。为了解决这个问题，我们需要对分数进行缩放。

```
scaled_attention_logits = matmul_qk / np.sqrt(depth)
```

这是《Attention is All You Need》论文中的一个关键创新。它有助于：

- **稳定梯度**: 防止梯度消失问题。
- **归一化方差**: 缩放因子 `sqrt(depth)` 能将点积的方差从 `depth` 重新调整回 1，保持数值稳定。

#### 步骤 3: 使用 Softmax 获取权重

缩放后的分数通过softmax函数转换成一个概率分布（所有值在0到1之间，且总和为1）。这些就是最终的**注意力权重**。

```
def softmax(x):
    """一个数值稳定的softmax实现"""
    # 减去最大值可以防止在计算exp(x)时发生数值溢出
    exp_x = np.exp(x - np.max(x, axis=-1, keepdims=True))
    # 归一化得到概率分布
    return exp_x / np.sum(exp_x, axis=-1, keepdims=True)

attention_weights = softmax(scaled_attention_logits)
# attention_weights 的形状: [batch_size, seq_len_q, seq_len_k]
```

最终得到的 `attention_weights` 矩阵显示了每个查询token对每个键token的关注程度。

#### 步骤 4: 计算最终输出

最后，将注意力权重与值矩阵 (V) 相乘，得到一个加权后的序列表示。在这个表示中，上下文相关的token被赋予了更高的权重。

```
output = np.matmul(attention_weights, V)
# output 的形状: [batch_size, seq_len_q, depth_v]
```

## 2. 多头注意力机制 (Multi-Head Attention)

相比于只进行一次注意力计算，多头机制让模型拥有多个“头”，每个头可以学习关注不同表示子空间中的不同类型关系。

### 输入

多头注意力的输入仍然是一个序列。

```
# 示例输入序列
x = np.random.randn(1, seq_len, d_model) # 形状: [批次, 序列长度, 模型维度]
```

### 维度划分与投影

为了保持计算效率，模型的总维度 (`d_model`) 被平均分配给多个注意力头 (`num_heads`)。

- **每个头的维度**: `d_head = d_model // num_heads`
- 这确保了总计算量和参数数量与使用 `d_model` 维度的单头注意力大致相同。

对于每个头，我们都创建一组独立的投影矩阵 (W_q, W_k, W_v)，用来将输入 `x` 变换到该头特定的 Q, K, V。

**为什么投影矩阵的形状是 `[d_model, d_head]`？**

这个形状是实现维度转换所必需的。

- **输入 `x` 的形状**: `[batch_size, seq_len, d_model]`
- **投影矩阵 `W_q` 的形状**: `[d_model, d_head]`
- **结果 `Q` 的形状**: `[batch_size, seq_len, d_model] @ [d_model, d_head] = [batch_size, seq_len, d_head]`

这个矩阵乘法有效地将高维输入特征映射到了每个头处理的低维子空间中。

### 拼接 (Concatenation)

在每个头计算出其输出（一个加权的V矩阵）后，所有头的结果会被拼接在一起。

```
# all_outputs 是一个包含各头输出的列表
# e.g., 若 num_heads=2, all_outputs = [output_head_1, output_head_2]
# 其中每个输出的形状为 [1, 4, 4]

# 沿着最后一个轴（特征维度）进行拼接
concat_output = np.concatenate(all_outputs, axis=-1)
```

- **拼接前**: 一个列表，包含多个形状为 `[batch_size, seq_len, d_head]` 的数组。
- **拼接后**: 一个形状为 `[batch_size, seq_len, d_model]` 的单一数组 (因为 `d_head * num_heads = d_model`)。

这个最终输出的维度与原始输入相同，使其可以无缝地传递给模型的后续层。

## 3. 其他注意力变体

- **掩码自注意力 (Masked Self-Attention)**: 用于解码器（如GPT），防止一个位置注意到它之后的位置（即“看到未来”）。
- **交叉注意力 (Cross-Attention)**: 用于编码器-解码器架构（如机器翻译）。查询(Q)来自解码器，而键(K)和值(V)来自编码器的输出。
- **稀疏自注意力 (Sparse Self-Attention)**: 一种计算上更高效的变体，只计算部分token对之间的注意力分数，适用于非常长的序列。
- **相对位置自注意力 (Relative Position Self-Attention)**: 考虑token之间的相对距离而非绝对位置，增强了模型对不同序列长度的泛化能力。

## 4. 辅助操作

### 压缩维度 (Squeezing)

`squeeze()` 操作常用于移除大小为1的维度，这对于简化张量以便于分析或可视化非常有用。

- **原始形状**: `[1, seq_len, seq_len]` (例如，来自批次大小为1的情况)
- **执行 `attention_weights.squeeze(0)`**
- **压缩后形状**: `[seq_len, seq_len]` (一个二维矩阵，非常适合用热力图显示)。