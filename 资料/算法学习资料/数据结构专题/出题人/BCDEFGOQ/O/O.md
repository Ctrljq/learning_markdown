<!-- page_number: true -->


# <center>O Powder Snow</center>

<br/>

### <center>By 黄霖 </center>

### <center>QQ：2649020702</center>

### <center>Blog：[空気力学の詩](https://www.cnblogs.com/cjjsb)</center>

---

# Prob

- 给定一个长为$n$的序列$\{a_n\}$，需要处理如下$k$次操作
	- ```1 l r x```：对于所有的 $i\in[l,r]$ ，将 $a_i$ 的值改为 $x$ 。

	- ```2 l r```：求出 $\min_{l\le i\le r} \frac{\text{lcm}(a_i,b_i)}{\gcd(a_i,b_i)}$ 的值

- 输入的所有数均$\le 5\times 10^4$

---

# Tutorial

- 以下分析时为了简便将所有数的值域大小都记为$N$
- 这个数据范围和时限很容易想到分块
- 分块的修改操作很trivial，直接散块暴力，整块打标记即可
- 查询的散块也是可以直接暴力，难点就在于怎么算整块的答案
---

# Tutorial

- 注意到此时整块内所有的$a_i$一定都相同，不妨记为$x$
- 考虑$\frac{\text{lcm}(x,b_i)}{\gcd(x,b_i)}=\frac{x\times b_i}{\gcd^2(x,b_i)}$，而关于$\gcd$的问题很经典的做法就是直接枚举它的值
- 不妨枚举$y\mid x$作为$\gcd(x,b_i)$的值，此时需要找到满足$y\mid b_i$且最小的$b_i$来计算贡献
- 注意虽然$y$不一定恰好是$\gcd(x,b_i)$，但这样只会导致算出的答案偏大
- 而正确的答案一定可以被枚举到，因此正确性是有保证的
---
# Tutorial

- 此时块内的复杂度是$\sigma(N)$级别的，再加一个记忆化即可保证总复杂度可控
- 设块长为$S$，理论时间复杂度为$O(N\times \sigma(N)+N\times (\frac{N}{S}\times \sigma(N)+S\times \log N))$
- 在数据范围内因数最多的数大约有$100$个因子，因此tradeoff后得到$S$取得略大于$\sqrt N$会比较快
- 如果你被卡常了，可以试试[$O(1)\gcd$的科技](https://www.cnblogs.com/cjjsb/p/16852535.html)

---
# <center>GL&HF</center>