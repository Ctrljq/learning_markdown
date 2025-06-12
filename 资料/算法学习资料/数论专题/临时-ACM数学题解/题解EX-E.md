# 问题

求有多少个小于等于$\lfloor\frac{n}{m}\rfloor$的数，满足其最大质因子不大于$m$的最小质因子。

# 解法

假设$N=\lfloor\frac{n}{m}\rfloor,d=\lfloor\sqrt N\rfloor$，$m$的最小质因子为$p$.

## case 1

若$p>d$，那么$N$以内的数最多只会有一个大于等于$p$的质因子，因此答案为：
$$
\sum_{i>p}[i\text{是质数}]\lfloor\frac{N}{i}\rfloor
$$
考虑容斥原理，记$f(n)=\sum_{i=2}^n[i\text{是质数}]\lfloor\frac{N}{i}\rfloor$（注意是$\frac{N}{i}$），答案为$f(N)-f(p)$.

考虑求解$f(n)$，显然可以通过数论分块解决。假设我们有块$[l,r]$，那么这个块的答案为$(g(r)-g(l-1))\lfloor\frac{N}{r}\rfloor$，其中$g(n)$表示$n$以内的质数个数，可以通过高级筛求解(min25，洲阁筛...)

## case 2

若$p\leq d$，爆搜即可通过本题，可能需要一点点剪枝，~~也可能不需要~~。