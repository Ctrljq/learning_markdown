==对不同层级做不同处理==

```py
def fuse(self):  # fuse model Conv2d() + BatchNorm2d() layers
    print('Fusing layers... ')
    for m in self.model.modules():
        if isinstance(m, RepConv):
            #print(f" fuse_repvgg_block")
            m.fuse_repvgg_block()
        elif isinstance(m, RepConv_OREPA):
            #print(f" switch_to_deploy")
            m.switch_to_deploy()
        elif type(m) is Conv and hasattr(m, 'bn'):
            m.conv = fuse_conv_and_bn(m.conv, m.bn)  # update conv
            delattr(m, 'bn')  # remove batchnorm
            m.forward = m.fuseforward  # update forward
        elif isinstance(m, (IDetect, IAuxDetect)):
            m.fuse()
            m.forward = m.fuseforward
            self.info()
    return self
```

# 一、合并卷积与BN

<img src="C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241130155139861.png" alt="image-20241130155139861" style="zoom:67%;" />

<img src="C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241130155305868.png" alt="image-20241130155305868" style="zoom: 80%;" />

![image-20241130155156992](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241130155156992.png)

```py
def fuse_conv_and_bn(conv, bn):
    # Fuse convolution and batchnorm layers https://tehnokv.com/posts/fusing-batchnorm-and-conv/
    fusedconv = nn.Conv2d(conv.in_channels,
                          conv.out_channels,
                          kernel_size=conv.kernel_size,
                          stride=conv.stride,
                          padding=conv.padding,
                          groups=conv.groups,
                          bias=True).requires_grad_(False).to(conv.weight.device)

    # prepare filters bn.weight 对应论文中的gamma   bn.bias对应论文中的β bn.running_mean则是对于当前batch size的数据所统计出来的平均值 bn.running_var是对于当前batch size的数据所统计出来的方差
    w_conv = conv.weight.clone().view(conv.out_channels, -1)  # （32，3，3，3）->（32，27）
    w_bn = torch.diag(bn.weight.div(torch.sqrt(bn.eps + bn.running_var)))  # bn/(sqrt(var+eps))  BatchNorm2d(32, eps=0.001, momentum=0.03, affine=True, track_running_stats=True)。var：（32，），eps=0.001
    fusedconv.weight.copy_(torch.mm(w_bn, w_conv).view(fusedconv.weight.shape))  # IMP：赋值给新的卷积核W

    # prepare spatial bias
    b_conv = torch.zeros(conv.weight.size(0), device=conv.weight.device) if conv.bias is None else conv.bias
    b_bn = bn.bias - bn.weight.mul(bn.running_mean).div(torch.sqrt(bn.running_var + bn.eps))
    fusedconv.bias.copy_(torch.mm(w_bn, b_conv.reshape(-1, 1)).reshape(-1) + b_bn)  # IMP：赋值给新的卷积核的偏置项B

    return fusedconv
```

WB：

```
tensor([[17.90986,  0.00000,  0.00000,  ...,  0.00000,  0.00000,  0.00000],
        [ 0.00000, 12.54014,  0.00000,  ...,  0.00000,  0.00000,  0.00000],
        [ 0.00000,  0.00000, 52.63450,  ...,  0.00000,  0.00000,  0.00000],
        ...,
        [ 0.00000,  0.00000,  0.00000,  ..., 28.04910,  0.00000,  0.00000],
        [ 0.00000,  0.00000,  0.00000,  ...,  0.00000, 31.87202,  0.00000],
        [ 0.00000,  0.00000,  0.00000,  ...,  0.00000,  0.00000, 16.18073]])
```

## 前后对比

```yaml
  (0): Conv(
    (conv): Conv2d(3, 32, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
    (act): SiLU()
  )
  (1): Conv(
    (conv): Conv2d(32, 64, kernel_size=(3, 3), stride=(2, 2), padding=(1, 1), bias=False)
    (bn): BatchNorm2d(64, eps=0.001, momentum=0.03, affine=True, track_running_stats=True)
    (act): SiLU()
  )
```

# 二、统一为3✖3卷积



```
(102): RepConv(
    (act): SiLU()
    (rbr_dense): Sequential(
      (0): Conv2d(128, 256, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1), bias=False)
      (1): BatchNorm2d(256, eps=0.001, momentum=0.03, affine=True, track_running_stats=True)
    )
    (rbr_1x1): Sequential(
      (0): Conv2d(128, 256, kernel_size=(1, 1), stride=(1, 1), bias=False)
      (1): BatchNorm2d(256, eps=0.001, momentum=0.03, affine=True, track_running_stats=True)
    )
  )
```

合并`（1*1） （3*3）`卷积

先把各自的卷积与偏执先融合。再统一为3*3卷积。

对1*1进行pad即可

<img src="C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241130161307941.png" alt="image-20241130161307941" style="zoom:80%;" />

![image-20241130161322251](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241130161322251.png)

 

<img src="C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241130161824346.png" alt="image-20241130161824346" style="zoom: 50%;" />

最后把几个分支加在一起

## 前后对比

```yaml
(102): RepConv(
    (act): SiLU()
    (rbr_reparam): Conv2d(128, 256, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
  )
  (103): RepConv(
    (act): SiLU()
    (rbr_dense): Sequential(
      (0): Conv2d(256, 512, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1), bias=False)
      (1): BatchNorm2d(512, eps=0.001, momentum=0.03, affine=True, track_running_stats=True)
    )
    (rbr_1x1): Sequential(
      (0): Conv2d(256, 512, kernel_size=(1, 1), stride=(1, 1), bias=False)
      (1): BatchNorm2d(512, eps=0.001, momentum=0.03, affine=True, track_running_stats=True)
    )
  )
```

