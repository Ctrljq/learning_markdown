# 一、可变形注意力机制概述

# 二、mask2former网络结构

<img src="C:/Users/HUAWEI/Documents/Tencent%20Files/1436941594/nt_qq/nt_data/Pic/2024-12/Thumb/26120516910d62d03a5db49be679a410_720.png" alt="26120516910d62d03a5db49be679a410_720" style="zoom: 50%;" />



# 三、mask2former中的实际运用



## 1、先将原始图像传入backbone得到4个尺度的特征图

```py
# IMP:img:(2,3,1024,1024)
# tips：x为backbone输出的四个层级的特征图
#  （2，256，256，256）（2，512，128，128）（2，1024，64，64）（2，2048，32，32）
x = self.extract_feat(img)
```

## 2、向pixel_decoder输入四层级特征【SA&deformable A】

```py
# attn：输入feats为4个层级特征，
#  mask_features为（2，256，256，256）的掩码特征
#  multi_scale_memorys为经过encoder处理得到的多尺度特征，
# list（3）：（2，256，32，32）（2，256，64，64）（2，256，128，128）
mask_features, multi_scale_memorys = self.pixel_decoder(feats)
```

### 2.1、遍历处理每一层（由低到高分辨率）

```
从低分辨率到高分辨率。（2，2048，32，32）->（2，1024，64，64）->（（2，512，128，128）
```

```
得到当前层的特征图并降维（通道数=256）
位置编码与level编码
棋盘格映射（映射为）并归一化
```

```py
# Chapter：loop：遍历每一层（由低到高分辨率）
for i in range(self.num_encoder_levels):  # self.num_encoder_levels=3

    # chapter：得到当前层的特征图并降维（通道数）
    # tips：从低分辨率到高分辨率。（2，2048，32，32）->（2，1024，64，64）->（（2，512，128，128）
    level_idx = self.num_input_levels - i - 1

    feat = feats[level_idx]  # 得到当前层的特征图
    feat_projected = self.input_convs[i](feat)  # attn：卷积降维eg:(2,2048,32,32)->(2,256,32,32)。统一降维到256
    h, w = feat.shape[-2:]  # 32 32

    # no padding
    padding_mask_resized = feat.new_zeros(
        (batch_size, ) + feat.shape[-2:], dtype=torch.bool)  # （2，32，32）

    # chapter:加位置编码与level编码
    pos_embed = self.postional_encoding(padding_mask_resized)  # IMP:输入为（2，32，32）输出为（2，256，32，32）
    level_embed = self.level_encoding.weight[i]  # （256，）而非（256，32，32）只是区分了不同的level
    level_pos_embed = level_embed.view(1, -1, 1, 1) + pos_embed  # IMP:（1，256，1，1）+（2，256，32，32）=（2，256，32，32）

    # chapter:棋盘格映射并归一化
    # IMP:即将特征图（1024个点上，每个点有2个坐标）映射到原始输入
    #  【reference_points：也就是现在的每一个点对应的原始输入的位置】
    reference_points = self.point_generator.single_level_grid_priors(  # (1024,2)  1024(32*32)个点，每个点有2个坐标
        feat.shape[-2:], level_idx, device=feat.device)

    # 对reference_points归一化
    factor = feat.new_tensor([[w, h]]) * self.strides[level_idx]  # 长宽*stride=[1024,1024]
    reference_points = reference_points / factor  # （1024，2）

    # chapter:转换维度
    # shape (batch_size, c, h_i, w_i) -> (h_i * w_i, batch_size, c)
    feat_projected = feat_projected.flatten(2).permute(2, 0, 1)  # （2，256，32*32）->(1024,2,256)
    level_pos_embed = level_pos_embed.flatten(2).permute(2, 0, 1)  # （2，256，32*32）->(1024,2,256)
    padding_mask_resized = padding_mask_resized.flatten(1)  # (2,32*32)=(2,1024)

    # chapter:添加到list
    encoder_input_list.append(feat_projected)
    padding_mask_list.append(padding_mask_resized)
    level_positional_encoding_list.append(level_pos_embed)
    spatial_shapes.append(feat.shape[-2:])
    reference_points_list.append(reference_points)
```



### 2.2、初始化deformable attention的 encoder参数

```py
# chapter：初始化deformable attention的 encoder参数
# shape (batch_size, total_num_query),
# total_num_query=sum([., h_i * w_i,.])
# tips：（2，21504）
padding_masks = torch.cat(padding_mask_list, dim=1)

# shape (total_num_query, batch_size, c)
# attn：（21504,2,256）  32*32+64*64+128*128=21504，拼接了3个level的特征图，2为batch_size，256为通道数
encoder_inputs = torch.cat(encoder_input_list, dim=0)
level_positional_encodings = torch.cat(level_positional_encoding_list, dim=0)
device = encoder_inputs.device

# shape (num_encoder_levels, 2), from low
# resolution to high resolution
# tips:（3，2）[[32,32],[64,64],[128,128]
spatial_shapes = torch.as_tensor(spatial_shapes, dtype=torch.long, device=device)

# shape (0, h_0*w_0, h_0*w_0+h_1*w_1, ...),tips：算出每一个层级的起始索引
# tips:(3,)-[0,1024,5120]
level_start_index = torch.cat((spatial_shapes.new_zeros((1, )), spatial_shapes.prod(1).cumsum(0)[:-1]))

# attn：（21504,2）  32*32+64*64+128*128=21504，拼接了3个level的特征图，2为x，y坐标
reference_points = torch.cat(reference_points_list, dim=0)

# reference_points[None, :, None]：在第0维和第2维增加一个新的维度。
# 将变形后的张量在第0维（批量维度）复制batch_size次，在第2维（层级维度）复制self.num_encoder_levels次。
# tips：（2，21504，3，2）
reference_points = reference_points[None, :, None].repeat(batch_size, 1, self.num_encoder_levels, 1)

# tips：（2，3，2）
# valid_radios 是一个标志张量，指示每个查询的有效区域。
# 它用于在编码器中控制哪些区域应该被考虑，哪些区域应该被忽略，通常与参考点一起工作。
valid_radios = reference_points.new_ones((batch_size, self.num_encoder_levels, 2))
```

### 3.3、deformable attention的encoder

```py
 memory = self.encoder(  # （输入输出维度相同，即（21504，2，256）
            query=encoder_inputs,
            key=None,  # IMP:k和v都为None，都是由query计算得到
            value=None,
            query_pos=level_positional_encodings,
            key_pos=None,
            attn_masks=None,
            key_padding_mask=None,
            query_key_padding_mask=padding_masks,
            spatial_shapes=spatial_shapes,
            reference_points=reference_points,
            level_start_index=level_start_index,
            valid_radios=valid_radios)
```

> `encoder_inputs`为卷积降维为256后的特征图拼接得到的结果
>
> ==（21504，2，256）==$21504=32*32+64*64+128*128$​，2为batch，256为通道数
>
> `padding_masks`此时形状是21504，2。但此时全为0（false）
>
> `spatial_shapes`记录了三个特征图的尺寸，32，64，128
>
> `reference_points`棋盘格归一化的坐标，==（2，21504，3，2）==
>
> ```py
> # attn：（21504,2）  32*32+64*64+128*128=21504，拼接了3个level的特征图，2为x，y坐标
> reference_points = torch.cat(reference_points_list, dim=0)
> 
> # reference_points[None, :, None]：在第0维和第2维增加一个新的维度。
> # 将变形后的张量在第0维（批量维度）复制batch_size次，在第2维（层级维度）复制self.num_encoder_levels次。
> # tips：（2，21504，3，2）
> reference_points = reference_points[None, :, None].repeat(batch_size, 1, self.num_encoder_levels, 1)
> ```
>
> `level_start_index`为每一层级的起始索引：`[0,1024,5120]`

### 3.4、self.operation_order:4（self_attn, norm, ffn, norm）

==一开始的key和value都是query==

```py
if layer == 'self_attn':
    temp_key = temp_value = query  # keys：一开始的key和value都是query
    query = self.attentions[attn_index](
        query,
        temp_key,
        temp_value,
        identity if self.pre_norm else None,
        query_pos=query_pos,
        key_pos=query_pos,
        attn_mask=attn_masks[attn_index],
        key_padding_mask=query_key_padding_mask,
        **kwargs)
    attn_index += 1
    identity = query
```

得到偏移与权重

```py
# 会通过Q分别连接全连接层得到偏移量与每个点的权重.query:（2，21504，256）
# Linear(in_features=256, out_features=192, bias=True)。
#（2，21504，8，3，4，2）192=8*3*4*2，8个头，3个level，4个采样点，2个偏移量。此处的多头是通过切分通道实现的。
sampling_offsets = self.sampling_offsets(query).view(
    bs, num_query, self.num_heads, self.num_levels, self.num_points, 2)

# Linear(in_features=256, out_features=96, bias=True)。
# （2，21504，8，12）96=8*3*4，8个头，3个level，4个采样点
attention_weights = self.attention_weights(query).view(
    bs, num_query, self.num_heads, self.num_levels * self.num_points)

attention_weights = attention_weights.softmax(-1)
```

原坐标+偏移

```py
offset_normalizer = torch.stack(  # （3，）[32,32][64,64][128,128]
    [spatial_shapes[..., 1], spatial_shapes[..., 0]], -1)

# reference_points:(2,21504,3,2) sampling_offsets:（2，21504，‘8’，3，‘4’，2）这8个头，4个采样点初始化位置相同
# sampling_locations:(2,21504,8,3,4,2)
# 移量除以归一化因子 offset_normalizer，确保偏移量与特征图尺寸相匹配
sampling_locations = reference_points[:, :, None, :, None, :] \
+ sampling_offsets \
/ offset_normalizer[None, None, None, :, None, :]
```

经过多个encoder后，最终结果变为：（21504，2，256）

### 3.5、将encoder的输出拆分为多尺度特征图

```py
# chapter：将encoder的输出拆分为多尺度特征图
# from low resolution to high resolution
num_query_per_level = [e[0] * e[1] for e in spatial_shapes]  # tips：（3，）[[1024],[4096][16384]]
outs = torch.split(memory, num_query_per_level, dim=-1)
outs = [
    x.reshape(batch_size, -1, spatial_shapes[i][0],
              spatial_shapes[i][1]) for i, x in enumerate(outs)
]  # tips：（2，256，32，32）（2，256，64，64）（2，256，128，128）
```

### 3.6、生成掩码特征图返回mask_feature, multi_scale_features

用的是256*256的进行的掩码特征图

```py
# Chapter：生成掩码特征图
# self.num_encoder_levels=3，self.num_input_levels=4
# range(0, -1, -1)，这意味着循环将只执行一次（i=0），最终的循环次数是 1 次。
for i in range(self.num_input_levels - self.num_encoder_levels - 1, -1,
               -1):
    x = feats[i]  # feats：（2，256，256，256）（2，512，128，128）（2，1024，64，64）（2，2048，32，32）
    cur_feat = self.lateral_convs[i](x)
    y = cur_feat + F.interpolate(
        outs[-1],
        size=cur_feat.shape[-2:],
        mode='bilinear',
        align_corners=False)
    y = self.output_convs[i](y)
    outs.append(y)
    multi_scale_features = outs[:self.num_outs]  # self.num_outs=3

    mask_feature = self.mask_feature(outs[-1])
    return mask_feature, multi_scale_features

```

## 3、deformable attention的 decoder准备【CA&deformable A】

### 3.1、遍历

```py
# CHAPTER:遍历decoder层
for i in range(self.num_transformer_decoder_layers):
    level_idx = i % self.num_transformer_feat_level

    # tips：刚开始可能全识别为了背景
    # if a mask is all True(all background), then set it all False.
    attn_mask[torch.where(
        attn_mask.sum(-1) == attn_mask.shape[-1])] = False

    # cross_attn + self_attn
    layer = self.transformer_decoder.layers[i]
    attn_masks = [attn_mask, None]  # IMP:cross_attn有mask机制, self_attn没有mask机制

    query_feat = layer(
        query=query_feat,
        key=decoder_inputs[level_idx],  # IMP:pixel_decoder的输出再经过了形状处理+level_embed的结果
        value=decoder_inputs[level_idx],  # （1024，2，256）（4096，2，256）（16384，2，256）
        query_pos=query_embed,  # 位置编码
        key_pos=decoder_positional_encodings[level_idx],
        attn_masks=attn_masks,
        query_key_padding_mask=None,
        # here we do not apply masking on padded region
        key_padding_mask=None)

    cls_pred, mask_pred, attn_mask = self.forward_head(
        query_feat, mask_features, multi_scale_memorys[
            (i + 1) % self.num_transformer_feat_level].shape[-2:])

    cls_pred_list.append(cls_pred)
    mask_pred_list.append(mask_pred)

    return cls_pred_list, mask_pred_list  # list（10）(2，100，81)-(2，100，256，256)

```



### 3.2、随机初始化query_feat和query_embed

```py
# CHAPTER:初始化query_feat和query_embed
# shape (num_queries, c) -> (num_queries, batch_size, c)
# tips：self.query_feat = nn.Embedding(self.num_queries, feat_channels)
#  创建一个嵌入层，用于生成查询向量。嵌入层的输入维度为 self.num_queries（查询数目），输出维度为 feat_channels（特征维度）。
#  nn.Embedding 的权重在初始化时是随机的。权重矩阵的每一行代表一个嵌入向量，默认情况下，这些嵌入向量会随机初始化，通常使用正态分布或均匀分布生成。
# eg：（100，2，256）
query_feat = self.query_feat.weight.unsqueeze(1).repeat(
    (1, batch_size, 1))
query_embed = self.query_embed.weight.unsqueeze(1).repeat(
    (1, batch_size, 1))
```

### 3.3、生成每个q的分类预测，掩码预测

```py
# attn：cls_pred, mask_pred, attn_mask = self.forward_head(
#             query_feat, mask_features, multi_scale_memorys[0].shape[-2:])
#  query_feat：（100，2，256）
#  mask_features：（2，256，256，256）
#  multi_scale_memorys[0].shape[-2:]：（256，256）

decoder_out = self.transformer_decoder.post_norm(decoder_out)  # LN，维度不变（100，2，256）
decoder_out = decoder_out.transpose(0, 1)  # （100，2，256）->（2，100，256）

# Linear（in_features=256, out_features=81, bias=True）
# shape (batch_size, num_queries, c)
cls_pred = self.cls_embed(decoder_out)  # (2,100，81)

# self.mask_embed包含多个全连接层
# shape (batch_size, num_queries, c)
mask_embed = self.mask_embed(decoder_out)  # (2,100，256)

# shape (batch_size, num_queries, h, w)
# ATTN：mask_feature的维度为（2，256，256，256），
#  mask_embed的维度为（2，100，256）.100个查询，每个查询的长度为256.
#  每个查询生成（256，256），一共有（2，100，256，256）
mask_pred = torch.einsum('bqc,bchw->bqhw', mask_embed, mask_feature)

# 将mask_pred的维度映射到当前层级的空间尺寸
# EG：（2，100，32，32）
attn_mask = F.interpolate(
    mask_pred,
    attn_mask_target_size,
    mode='bilinear',
    align_corners=False)

# shape (batch_size, num_queries, h, w) ->
#   (batch_size * num_head, num_queries, h*w)
# self.num_heads=8  IMP：此处的多头是通过复制通道实现
# EG：（16，100，1024）
attn_mask = attn_mask.flatten(2).unsqueeze(1).repeat(
    (1, self.num_heads, 1, 1)).flatten(0, 1)

attn_mask = attn_mask.sigmoid() < 0.5
attn_mask = attn_mask.detach()

return cls_pred, mask_pred, attn_mask
```

### 3.4、cross attention

```py
elif layer == 'cross_attn':
    query = self.attentions[attn_index](
        query,  # （100，2，256）
        key,
        value,  # （1024，2，256）
        identity if self.pre_norm else None,
        query_pos=query_pos,
        key_pos=key_pos,
        attn_mask=attn_masks[attn_index],
        key_padding_mask=key_padding_mask,
        **kwargs)
    attn_index += 1
    identity = query
```

