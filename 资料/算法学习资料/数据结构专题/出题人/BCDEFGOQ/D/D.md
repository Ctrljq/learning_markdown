<!-- page_number: true -->


# <center>D 	Mon panache!Ⅱ</center>

<br/>

### <center>By 黄霖 </center>

### <center>QQ：2649020702</center>

### <center>Blog：[空気力学の詩](https://www.cnblogs.com/cjjsb)</center>

---

# Prob

- 有长为$n$的数组，一共要进行$n$次覆盖操作，每次选择一个还未被覆盖的位置并将该位置覆盖
- 定义一个不含有被覆盖位置的子数组的权值为它的逆序对数量
- 求出在每一次覆盖操作之前，所有合法子数组的权值的最大值
- $n\le 10^5$
---

# Tutorial

- 首先选择一个合法子数组的所有子区间的值一定不会更优，因此我们只要考虑所有极大的子数组即可
- 注意到这题有强制在线，因此我们不能离线之后再倒着当作合并区间来做
- 考虑为什么我们会认为合并区间比分裂区间好做，因为这类问题我们可以把两个子区间的贡献加起来，然后加上两个区间相互影响的部分来得到大的区间的答案，而不需要再遍历整个大区间
- 用启发式合并处理上述过程的话就可以得到一个复杂度比较优秀的做法
---

# Tutorial

- 那么我们可以反过来用这个思路来优化分裂的问题，定义$R(l,r)$为区间$[l,r]$的逆序对个数
- 假设我们已经知道了$R(l,r)$，现在要在$x\in[l,r]$处分裂
- 考虑怎么计算子区间的影响复杂度比较小，一个很自然的想法就是类似于启发式合并，我们可以用启发式分裂，每次暴力遍历长度较小的区间来统计影响
---
# Tutorial

- 具体地，不妨设$[l,x-1]$的长度小于$[x+1,r]$，那么我们可以先重新用树状数组遍历$[l,x-1]$求出$R(l,x-1)$，然后枚举$i\in[l,x]$，求出$j\in[x+1,r]$且$a_j<a_i$的数量，然后就可以反推出$R(x+1,r)$了
- 区间在某个范围内的数的数量可以用可持久化的权值线段树，并用```set```维护下所有未删除的区间，最后用可删除堆维护下所有区间的贡献的最大值即可
- 总复杂度$O(n\log^2 n)$
---
# <center>GL&HF</center>