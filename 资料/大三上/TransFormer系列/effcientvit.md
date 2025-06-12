![image-20241204133130012](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241204133130012.png)

![image-20241204133011611](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241204133011611.png)

多头：

```py
def forward(self, x):  # x (B,C,H,W)
    B, C, H, W = x.shape  # （8,128,7,7）
    trainingab = self.attention_biases[:, self.attention_bias_idxs]
    feats_in = x.chunk(len(self.qkvs), dim=1)  # IMP：多头。将128切分为4份，每份32个通道.4*（8，32，7，7）
    feats_out = []
    feat = feats_in[0]
    for i, qkv in enumerate(self.qkvs):
        if i > 0: # add the previous output to the input
            feat = feat + feats_in[i]
            feat = qkv(feat)  # 1*1卷积（8，64，7，7）
            q, k, v = feat.view(B, -1, H, W).split(
                [self.key_dim, self.key_dim, self.d], dim=1) # self.key_dim=16，self.d=32
            q = self.dws[i](q)  # q再分组卷积
            q, k, v = q.flatten(2), k.flatten(2), v.flatten(2) 
            # B, C/h, N（8，16，49）（8，16，49）（8，32，49）
            attn = (
                (q.transpose(-2, -1) @ k) * self.scale  
                # [B,num_heads,N,C//num_heads][B,num_heads,C//num_heads,N]=[B,num_heads,N,N]
                +
                (trainingab[i] if self.training else self.ab[i])
            )
            attn = attn.softmax(dim=-1)  # BNN
            feat = (v @ attn.transpose(-2, -1)).view(B, self.d, H, W)  # BCHW
            feats_out.append(feat)
            x = self.proj(torch.cat(feats_out, 1))
            return x
```

