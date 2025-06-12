# 问题

求
$$
a_n=\sum_{i=0}^{n-1}a_ia_{n-1-i}\\
a_0=a_1=1
$$
的通项公式。

# 方法一

瞪眼法。一眼卡特兰数：
$$
a_n=\frac{1}{n+1}\binom{2n}{n}
$$


# 方法二

打表找规律：
$$
a_0=1,a_1=1,a_2=2,a_3=5,a_4=14,\dots
$$
卡特兰数！



# 方法三

联系括号序列。

一共有$n$对括号需要匹配，枚举匹配第1个左括号'('的右括号位置，一共有$n$个选择的位置。

这样就将括号匹配拆成了两个区间的子问题，假设第1对括号之间还有$i$对括号，那么方案数为$a_i$，第1对括号之外还有$n-1-i$对括号，方案数为$a_{n-1-i}$.根据乘法原理，总的括号匹配方案数为$a_ia_{n-1-i}$.再根据加法原理，将所有的情况相加，就得到了题目里给出的公式。

new question:怎么求合法括号序列的方案数呢？

折线法。

![折线法](https://cdn.luogu.com.cn/upload/image_hosting/ckajgdyv.png)

假设左括号为+1，右括号为-1，那么终点肯定在0.

由于不合法的路径一定会经过-1，因此将第一次经过-1后的操作以-1为对称轴对称，终点便变为了-2。可以证明，对于任何一种终点为0的非法路径，都可以通过翻转第一次经过-1后的路径映射到终点为-2的路径。那么选择$n-1$的左括号，$n+1$个右括号，就可以找出所有终点为-2的路径。

因此通项公式为$C_{2n}^n-C_{2n}^{n-1}$.

折线法链接：[卡特兰数的折线法证明](https://www.cnblogs.com/daemon94011/p/8831697.html)

相关练习：[2023年暑假前集训数学专题 不完全括号匹配](https://acm-uestc-edu-cn-s.vpn.uestc.edu.cn:8118/contest/203/problem/B)



# 方法四

直接从公式入手。

构造普通生成函数：
$$
f(x)=a_0+a_1x+\dots+a_nx^n+\dots
$$
想要得到形如$\sum_{i=0}^{n-1}a_ia_{n-1-i}$的式子，需要做乘法：
$$
[x^n]f^2(x)=\sum_{i=0}^na_ia_{n-i}=a_{n+1}
$$
目前我们便构造出了表达式，因此可以写出等式：
$$
xf^2(x)+1=f(x)
$$
解得：
$$
f(x)=\frac{1\pm \sqrt{1-4x}}{2x}
$$
由于$xf(x)=\frac{1\pm\sqrt{1-4x}}{2}$，代入$x=0$，得到
$$
f(x)=\frac{1- \sqrt{1-4x}}{2x}
$$
我们来推一下$\sqrt{1+z}​$的展开式：
$$
\begin{aligned}
\sqrt{1+z}&=(1+z)^{\frac{1}{2}}\\
&=1+\sum_{n=1}^{\infin}\binom{\frac{1}{2}}{n}z^n
\end{aligned}
$$
其中
$$
\begin{aligned}
\binom{\frac{1}{2}}{n}&=\frac{(\frac{1}{2})^{\underline{n}}}{n!}\\
&=\frac{(\frac{1}{2})(-\frac{1}{2})\dots(-\frac{2n-3}{2})}{n!}\\
&=\frac{(-1)^{n-1}}{n!}\left(\frac{1}{2}\right)^{n}\frac{1\times2\times3\times\dots\times(2n-3)\times(2n-2)}{2\times4\times\dots\times(2n-2)}\\
&=\frac{(-1)^{n-1}}{n!}\left(\frac{1}{2}\right)^{n}\frac{(2n-2)!}{2^{n-1}(n-1)!}\\
&=\frac{(-1)^{n-1}}{n\cdot2^{2n-1}}\cdot \frac{(2n-2)!}{(n-1)!(n-1)!}\\
&=\frac{(-1)^{n-1}}{n\cdot2^{2n-1}}\cdot \binom{2n-2}{n-1}\\
\end{aligned}
$$
因此
$$
\sqrt{1+z}=1+\sum_{n=1}^{\infin}\frac{(-1)^{n-1}}{n\cdot2^{2n-1}}\cdot \binom{2n-2}{n-1}z^n
$$


代入$z=-4x$
$$
\begin{aligned}
f(x)&=\frac{1}{2x}-\frac{1}{2x}\left(1+\sum_{n=1}^{\infin}\frac{(-1)^{n-1}}{n\cdot2^{2n-1}}\cdot \binom{2n-2}{n-1}(-1)^n2^{2n}x^n\right)\\
&=\frac{1}{2x}-\frac{1}{2x}\left(1-\sum_{n=1}^{\infin}\frac{2}{n}\cdot \binom{2n-2}{n-1}x^n\right)\\
&=\sum_{n=1}^{\infin}\frac{1}{n}\cdot \binom{2n-2}{n-1}x^{n-1}\\
&=\sum_{n=0}^{\infin}\frac{1}{n+1}\cdot \binom{2n}{n}x^{n}\\
\end{aligned}
$$
至此我们便得到了
$$
a_n=\frac{1}{n+1}\binom{2n}{n}
$$
