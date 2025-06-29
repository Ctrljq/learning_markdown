<!-- page_number: true -->


# <center>B Witch On The Holy Night</center>

<br/>

### <center>By 黄霖 </center>

### <center>QQ：2649020702</center>

### <center>Blog：[空気力学の詩](https://www.cnblogs.com/cjjsb)</center>

---

# Prob

- 给定一个$n$个点，$m$条边的无向图，每个点$i$存在激活区间$[l_i,r_i]$
- 频率$x$能激活点$i$，当且仅当$x\in[l_i,r_i]$
- 点$a$能到达点$b$，当且仅当存在一条$a\to b$的路径，且选定某个频率$x$使得路径上所有点都处于激活状态
- 求从$1$号点能到达的所有点的编号
- $n\le 2\times 10^5,m\le 4\times 10^5$
---

# Tutorial

- 首先考虑把点的激活区间转化到边上
- 具体地，对于一条边$u\leftrightarrow v$，它的存在时间可以看作区间$[\max(l_u,l_v),\min(r_u,r_v)]$
- 问题转化为一个无向图，每条边有一个存在时间的区间，询问某个时刻的连通性问题
---

# Tutorial

- 这类问题的经典处理方法就是线段树分治，建立以时间为下标的线段树，这样每条边只会出现在$O(\log n)$个线段树节点上
- 而连通性问题不难想到用可撤销并查集来维护（事实上，这两者一同出现几乎是这类题目的定式）
- 递归遍历线段树的过程中，先将当前节点上存在的边合并，然后递归子树，回溯的时候撤销当前节点上的合并操作即可
- 但现在的问题是在线段树的叶子节点我们怎么快速地把所有和$1$号点在一个连通块内的点加入答案
---
# Tutorial

- 注意到按秩合并的并查集在撤销时，一定是把原来的祖先关系树从根开始向下拆解的
- 因此我们可以通过在$1$号点所在的连通块的根位置打上标记，然后在撤销过程中把标记下传即可
- 注意一个实现细节：在合并两个节点时，可能父节点的方向本来已经有标记了，此时子节点需要先减去已有的标记来消除影响
- 总复杂度$O(m\log^2 n)$

---
# <center>GL&HF</center>