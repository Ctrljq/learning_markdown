<!-- page_number: true -->


# <center>C 	Mon panache!Ⅰ</center>

<br/>

### <center>By 黄霖 </center>

### <center>QQ：2649020702</center>

### <center>Blog：[空気力学の詩](https://www.cnblogs.com/cjjsb)</center>

---

# Prob

- 有一个长为$n$的序列$A$，对于正整数 $k$ ，按照以下方式得到序列 $A'_k$ ：
	- 将 $A$ 划分为 $\lceil\frac{n}{k}\rceil$ 段，第 $i$ 段为 $a_{k\times (i-1)+1},a_{k\times (i-1)+2},\cdots,a_{\min(k\times i,n)}$ 
	- 每一段升序排序后依次连接得到 $A'_k$

- 求有多少个$k\in[1,n]$，使得$A'_k$单调不降
- $n\le 10^6$
---

# Tutorial

- 如果大力枚举$k$的值，所需要检验的段数就是$O(\lceil\frac{n}{k}\rceil)$的
- 显然每一段内天然满足要求，因此只要考虑相邻两段间是否满足单调性关系
- 这个问题等价于判断前面一段的最大值和后面一段的最小值之间的大小关系，因此我们只要用能快速求区间最值的数据结构维护一下即可
- 用[ST表](https://oi-wiki.org/ds/sparse-table/)可以在$O(n\log n)$的预处理时间下，$O(1)$回答单次询问
- 由调和级数可知总复杂度为$O(n\log n)$

---
# <center>GL&HF</center>