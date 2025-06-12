![image-20241206142129819](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241206142129819.png)

**deformable attention**

Deformable-Detr是在detr的基础上了主要做了2个改进，Deformable attention（可变形注意力）和多尺度特征，通过可变性注意力降低了显存，多尺度特征对小目标检测效果比较好。

![image-20241206200600939](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241206200600939.png)

![image-20241206204141263](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241206204141263.png)

![image-20241206203631937](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241206203631937.png)

![image-20241206142641440](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241206142641440.png)

![img](https://pica.zhimg.com/v2-6e9b00f7338ea3890f2b9607cd414b0c_1440w.jpg) 

[【图像分割】mask2former：通用的图像分割模型详解 - 知乎](https://zhuanlan.zhihu.com/p/650724045)

# 关于特征对齐问题（映射回原图）

```py
def single_level_grid_priors(self,
                             featmap_size: Tuple[int],
                             level_idx: int,
                             dtype: torch.dtype = torch.float32,
                             device: DeviceType = 'cuda',
                             with_stride: bool = False) -> Tensor:
    feat_h, feat_w = featmap_size
    stride_w, stride_h = self.strides[level_idx]
    shift_x = (torch.arange(0, feat_w, device=device) +
               self.offset) * stride_w
    # keep featmap_size as Tensor instead of int, so that we
    # can convert to ONNX correctly
    shift_x = shift_x.to(dtype)

    shift_y = (torch.arange(0, feat_h, device=device) +
               self.offset) * stride_h
    # keep featmap_size as Tensor instead of int, so that we
    # can convert to ONNX correctly
    shift_y = shift_y.to(dtype)
    shift_xx, shift_yy = self._meshgrid(shift_x, shift_y)
    if not with_stride:
        shifts = torch.stack([shift_xx, shift_yy], dim=-1)
    else:
        # use `shape[0]` instead of `len(shift_xx)` for ONNX export
        stride_w = shift_xx.new_full((shift_xx.shape[0], ),
                                     stride_w).to(dtype)
        stride_h = shift_xx.new_full((shift_yy.shape[0], ),
                                     stride_h).to(dtype)
        shifts = torch.stack([shift_xx, shift_yy, stride_w, stride_h],
                             dim=-1)
        all_points = shifts.to(device)
        return all_points
```

在目标检测中，特征图通常由卷积层输出，每个像素点代表原始图像中的一个区域。==为了进行准确的目标定位，需要把这些特征图上的位置与原始图像中的位置对齐==。而==“通过 `offset=0.5` 将点定位到特征图的单元格中心，避免边界问题”==的意思是说，==在计算特征图上每个点的对应位置时，**需要让每个网格点尽量处于它所代表的图像区域的中心位置，而不是对齐到区域的边缘**。==

## 1、背景

特征图的每个像素位置并不直接对应于输入图像中的像素，而是代表输入图像中的一个区域。假设我们有一个 4x4 的特征图，每个特征图的像素（网格点）实际上代表输入图像中的一个 4x4 的区域。

如果我们不使用 `offset=0.5`，特征图上的网格点可能会对齐到某个区域的边缘，导致位置不够精确。==例如，对于一个步幅为 8 的特征图，如果特征图的第一列对齐的是输入图像的第一个像素位置（`x=0`），那么它可能并不是该 4x4 区域的中心位置，而是左上角的位置。==

## 2、为什么是 `offset=0.5`？

`offset=0.5` 的作用是将网格点的计算方式从特征图的 **边缘对齐** 调整为 **中心对齐**。具体来说，`offset` 让我们在==计算特征图每个位置的对应输入图像中的位置时，给每个点增加一个偏移量，保证该点定位到单元格的中心，而不是边缘。==

 **例子**

假设输入图像的某一区域的尺寸是 16x16，特征图的步幅为 8。那么：

- 原始输入图像的一个 16x16 区域，经过卷积层降采样后，会变成一个 2x2 的特征图。
- 假设特征图中的一个点对应于原始图像的 16x16 区域的左上角。如果我们不加偏移量 `offset=0.5`，那么这个点可能表示输入图像的左上角。
- 如果加上 `offset=0.5`，则该点将会被定位到该 16x16 区域的中心，而不是左上角，这样可以避免只对齐到边缘，提升定位精度。

## 3、具体示例

假设 `stride=8`，`featmap_size=(4, 4)`，`offset=0.5`，我们来看看 `shift_x` 计算过程：

1. **不加 offset 的情况**：
   - 如果没有 `offset`，`torch.arange(0, 4)` 会生成 `[0, 1, 2, 3]`，这些表示的是特征图每列的位置。
   - 计算时直接乘以步幅：`shift_x = [0, 1, 2, 3] * 8 = [0, 8, 16, 24]`。
   - 这样得到的点分别是原始图像的==`[0, 8, 16, 24]` 位置，表示的实际上是每个特征图单元的左上角位置。==
2. **加上 offset 的情况**：
   - 如果加上 `offset=0.5`，`torch.arange(0, 4) + 0.5` 会变成 `[0.5, 1.5, 2.5, 3.5]`，这表示每个特征图单元的位置相对于原始图像的偏移。
   - 乘以步幅后：`shift_x = [0.5, 1.5, 2.5, 3.5] * 8 = [4, 12, 20, 28]`。
   - 这样得到的点分别是原始图像的 ==`[4, 12, 20, 28]` 位置，表示的是每个特征图单元的 **中心位置**，而不是左上角。==

## 4、为什么这样做？

1. **定位精度**：将特征图的网格点对齐到中心而不是边缘，可以使得目标定位更加精确。例如，当模型需要预测某个物体的位置时，使用中心对齐可以更准确地定位物体的中心点。
2. **避免偏移**：如果没有使用偏移量，那么预测的框（bounding box）就有可能偏移到特征图单元的边缘，导致预测框的不准确。`offset=0.5` 使得每个网格点与输入图像中的对应区域对齐得更好。

`offset=0.5` 的核心作用是将每个网格点的计算方式从特征图单元的 **边缘对齐** 调整为 **中心对齐**，这样可以提高物体检测模型在特征图上对物体位置的预测精度，避免了偏离目标中心的定位问题。

# 二、源码解析

## 1、Cost模块

### 1.1、Cls_Cost

```py
if self.cls_cost.weight != 0 and cls_pred is not None:
	# tips：cls_pred（100，81） gt_labels（10，）
    # gt_labels：[39,39,39,39,39,1,1,0,0,67]
	cls_cost = self.cls_cost(cls_pred, gt_labels)  # (100,10)
else:
	cls_cost = 0
```

`self.cls_cost:`

```py
cls_score = cls_pred.softmax(-1)
cls_cost = -cls_score[:, gt_labels]  # (100,10)
return cls_cost * self.weight
```

### 1.2、Mask_Cost

```py
if self.mask_cost.weight != 0:
    # mask_pred shape = [num_query, h, w]
    # gt_mask shape = [num_gt, h, w]
    # mask_cost shape = [num_query, num_gt]
    # mask_pred（100，12544）, gt_mask（10，12544）。12544是256*256采样点数
    mask_cost = self.mask_cost(mask_pred, gt_mask)  
else:
    mask_cost = 0
```

```py
if ....
            return cls_cost * self.weight
```

  `self.mask_cost:`

```py
# cls_pred（100，12544） gt_labels（10，12544）
cls_pred = cls_pred.flatten(1).float()  
gt_labels = gt_labels.flatten(1).float() 
n = cls_pred.shape[1]  # 12544

pos = F.binary_cross_entropy_with_logits(  # (100, 12544)
    cls_pred, torch.ones_like(cls_pred), reduction='none')
neg = F.binary_cross_entropy_with_logits(  # (100, 12544)
    cls_pred, torch.zeros_like(cls_pred), reduction='none')

cls_cost = torch.einsum('nc,mc->nm', pos, gt_labels) + torch.einsum('nc,mc->nm', neg, 1-gt_labels)
cls_cost = cls_cost / n

return cls_cost  # (100,10)
```

`torch.ones_like(cls_pred)` 代表将所有类别的真实标签设置为 `1`，表示每个类别是正样本。

`cls_pred` 是预测的类别得分。`binary_cross_entropy_with_logits` 计算的是每个类别的 **二元交叉熵损失**，其中 `cls_pred` 是预测的得分（未经过 Sigmoid 激活函数的原始输出）。

`torch.zeros_like(cls_pred)` 表示将所有类别的真实标签设置为 `0`，表示每个类别是负样本。

计算每个类别的 **负样本二元交叉熵损失**。

> #### `torch.einsum('nc,mc->nm', pos, gt_labels)`：
>
> - `'nc'` 表示 `pos` 张量的维度，其中 `n=100` 和 `c=12544`。`pos` 是 `(100, 12544)` 形状。
> - `'mc'` 表示 `gt_labels` 张量的维度，其中 `m=10` 和 `c=12544`。`gt_labels` 是 `(10, 12544)` 形状。
> - `-> nm` 表示输出的维度应该是 `(n, m)`，即 `(100, 10)`。
>
> 这行代码的作用是将 `pos` 张量和 `gt_labels` 张量按照 `c` 维度做一个按元素相乘并求和的操作，最终得到一个 `(100, 10)` 形状的张量。
>
> #### `torch.einsum('nc,mc->nm', neg, 1 - gt_labels)`：
>
> 同理，这行代码是将 `neg` 张量和 `1 - gt_labels` 张量做相同的操作，得到一个 `(100, 10)` 形状的张量。

### 1.3、Dice_Cost

```py
if self.dice_cost.weight != 0:
    # mask_pred（100，12544）, gt_mask（10，12544）
	dice_cost = self.dice_cost(mask_pred, gt_mask)
else:
	dice_cost = 0
```

```py
if.....
        return dice_cost * self.weight
```

> **Dice Loss** 是一种常用于图像分割任务中的损失函数，特别是在医学图像分割和目标检测等领域。它的目标是衡量两个集合的相似度，通常用于评估模型预测的分割结果与真实标注之间的相似程度。
>
> ### 1. **Dice 系数 (Dice Coefficient)**
>
> Dice 系数（或称为 **Dice Similarity Coefficient, DSC**）是一个衡量两个集合相似度的指标，定义为：
>
> $\text{Dice} = \frac{2|A \cap B|}{|A| + |B|}$
>
> 其中：
>
> -  A 和 B 分别是预测结果和真实标签的二值集合（即，分割区域和真实区域）。
> - |A| 和 |B| 分别是集合 A 和 B 的元素个数（即，集合的大小）。
> - $|A \cap B|$ 是两个集合的交集大小。
>
> Dice 系数的值范围是 [0, 1]，其中：
>
> - 1 表示完全一致（完全匹配）。
> - 0 表示完全不相交（没有重合部分）。
>
> ### 2. **Dice Loss**
>
> Dice Loss 是 Dice 系数的一个变体，目的是将高相似度（即高 Dice 系数）转化为一个最小化的损失值。在训练过程中，我们希望最小化损失函数，因此可以通过以下公式来计算 Dice Loss：
>
> $\text{Dice Loss} = 1 - \frac{2 \sum_{i} (p_i \cdot y_i)}{\sum_{i} p_i + \sum_{i} y_i}$
>
> 其中：
>
> - $p_i$是预测结果（概率或二值化的预测值）。
> - $y_i$ 是真实标签（目标值，通常是二值化的标签，0 或 1）。
>
> 这个公式计算了预测结果与真实标签之间的重叠程度，最终的损失值越小，表示模型的预测越接近真实标签。
>
> ### 3. **Dice Loss 的优点**
>
> - **适应性强**：对于不平衡的数据集（如目标区域占比较小的图像），Dice Loss 更加稳定，因为它强调了重叠部分而不是整个图像。
> - **适合分割任务**：Dice Loss 本身就是为了解决分割任务中目标区域识别的问题，因此非常适用于图像分割，特别是医学图像分割。
>
> ### 4. **与其他损失函数的比较**
>
> Dice Loss 和其他常见损失函数（如交叉熵损失）不同，因为它关注的是预测区域与真实区域的重叠程度，而不是单纯的像素级别的分类准确度。它更适用于解决类不平衡问题，因为即使目标区域在图像中很小，Dice Loss 也能通过强调重叠区域来提高模型性能。

`self.dice_cost:`

```py
mask_preds = mask_preds.flatten(1)  # (100，12544）
gt_masks = gt_masks.flatten(1).float()  # (10，12544）

numerator = 2 * torch.einsum('nc,mc->nm', mask_preds, gt_masks)  # 分子

if self.naive_dice:  # 分母
    denominator = mask_preds.sum(-1)[:, None] + \
    gt_masks.sum(-1)[None, :]
else:
    denominator = mask_preds.pow(2).sum(-1)[:, None] + \
    gt_masks.pow(2).sum(1)[None, :]
    loss = 1 - (numerator + self.eps) / (denominator + self.eps)  # Dice Loss
    return loss      
```



## 2、匈牙利匹配

```py
matched_row_inds, matched_col_inds = linear_sum_assignment(cost)  # cost(100,10)
```

`linear_sum_assignment` 是一个常用于求解二分图最小化问题的函数，它基于匈牙利算法（Hungarian Algorithm）来找到一组最优的匹配（即最小化总成本）。具体到你的例子，`cost` 矩阵的大小为 (100, 10)，意味着有 100 个行和 10 列的元素，每个元素代表一个匹配的成本。==`linear_sum_assignment` 会根据这个成本矩阵返回两组索引：`matched_row_inds` 和 `matched_col_inds`，分别表示行和列中最佳匹配的索引。==

### 解释为什么要使用 `linear_sum_assignment`：

在 Mask2Former 等模型中，`linear_sum_assignment` 通常用于解决“分配问题”——比如将检测到的目标（比如 100 个检测框）与实际的目标（比如 10 个类标签）进行匹配。==匹配的标准是根据一个“成本矩阵”来决定哪个检测框与哪个类别标签最匹配==，通常这个成本矩阵是通过计算检测框与标签之间的某种距离度量（例如 IoU）得到的。

### 代码解析：

假设你有 `cost` 矩阵，形状是 `(100, 10)`，表示有 100 个检测框（行），和 10 个类别（列），每个元素代表检测框和类别之间的“匹配成本”。==`linear_sum_assignment(cost)` 会找到一个“匹配”方式，使得所有的行（检测框）与列（类别）之间的总成本最小。返回的 `matched_row_inds` 和 `matched_col_inds` 代表的是最佳匹配的行列索引。==

### 具体含义：

- `matched_row_inds`: 代表每个检测框在最佳匹配下，应该对应哪个类别。
- `matched_col_inds`: 代表每个类别在最佳匹配下，应该匹配到哪个检测框。

### 为什么需要这个？

==在物体检测任务中，我们往往面临一个“多对多”匹配的问题。比如可能有多个预测框与多个真实框，需要通过某种方式来确定每个预测框与哪个真实框（或类别）匹配，以便计算损失函数（例如，分类损失和回归损失）。==`linear_sum_assignment` 就是用来解决这个“最优匹配”问题的。

### 举个例子：

假设有 3 个预测框和 3 个类别，`cost` 矩阵如下：

```
cost = [[1, 2, 3], 
        [4, 1, 2], 
        [3, 5, 1]]
```

这个矩阵表示：

- 第一个预测框与第一个类别的匹配成本是 1，第二个类别是 2，第三个类别是 3。
- 第二个预测框与第一个类别的匹配成本是 4，第二个类别是 1，第三个类别是 2。
- 第三个预测框与第一个类别的匹配成本是 3，第二个类别是 5，第三个类别是 1。

执行 `linear_sum_assignment(cost)` 后，可能得到的输出是：

```python
matched_row_inds = [0, 1, 2]
matched_col_inds = [0, 1, 2]
```

这意味着：

- 第一个预测框匹配到第一个类别，
- 第二个预测框匹配到第二个类别，
- 第三个预测框匹配到第三个类别。

这种匹配方式使得总的匹配成本最小。

### 总结：

`linear_sum_assignment` 在 Mask2Former 等模型中，主要用于解决目标检测中的“分配问题”，即如何将检测到的多个框与真实的类别进行最优匹配。通过这种方法，可以有效地计算损失，并在训练过程中进行优化。