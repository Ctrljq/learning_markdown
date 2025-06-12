### 题解

容斥，考虑钦定一些位置前缀最大值等于 $\{p\}$。

令 $\{p\}$ 的前缀最大值为 $mxp$，同理有 $mxq$。

设 $f_i$ 表示考虑前 $i$ 个位置且 $mxq_{i}=mxp_i$ 时的方案数，带上容斥系数。

答案就是 $-f_n$。

转移对于 $f_i$ 分两种情况讨论：

若 $mxp_j=mxp_i$：
$$
f_i\leftarrow-f_j\binom{mxp_i-j}{i-j}(i-j)!=-f_j\frac{(mxp_i-j)!}{(mxp_i-i)!}
$$
否则 $mxp_j < mxp_i$：
$$
f_i\leftarrow -f_j(i-j)!\binom{mxp_i-j-1}{i-j-1}=-f_j(i-j)\frac{(mxp_i-j-1)!}{(mxp_i-i)!}
$$
暴力是 $O(n^2)$ 的。

注意到随机排列的不同 $mxp$ 期望只有 $1+\frac{1}{2}+\frac{1}{3}+\dots+\frac{1}{n}=O(\log n)$ 个。

所以对不同的 $mxp$，我们令  $g_j=f_j(mxp_i-j)!$ 或  $g_j=f_j(mxp_i-j-1)!$。

转移就可以前缀和优化，复杂度 $O(n\log n)$。

写到这里，我突然发现可以更精细的分析：

实际上，我们的一次改变 $mxp$，只会更改前缀的所有 $j$，那么这个期望复杂度实际上变为 $O(\sum_{i=1}^n \frac{1}{i}\times i) = O(n)$。

转移前缀和优化是每次 $O(1)$ 总共 $O(n)$。

所以总复杂度实际上是 $O(n)$ 的。
