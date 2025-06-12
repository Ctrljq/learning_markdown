# 问题

求
$$
\prod_{i=1}^n\prod_{j=1}^m f_{\gcd(i,j)}
$$

# 题解

假设$n\leq m$，和式化简：
$$
\begin{aligned}
&\prod_{i=1}^n\prod_{j=1}^m f_{\gcd(i,j)}\\
=&\prod_{d=1}^{n}f_d^{\sum_{i=1}^{\lfloor \frac{n}{d} \rfloor}\sum_{i=1}^{\lfloor \frac{m}{d} \rfloor}[\gcd(i,j)=1]}
\end{aligned}
$$
单独考虑指数部分，指数部分可以如下简化：
$$
\begin{aligned}
&\sum_{i=1}^n\sum_{j=1}^m[\gcd(i,j)=1]\\
=&\sum_{i=1}^n\sum_{j=1}^m\sum_{d|i,d|j}\mu(d)\\
=&\sum_{d=1}^n \mu(d)\sum_{i=1}^{\lfloor \frac{n}{d} \rfloor}\sum_{i=1}^{\lfloor \frac{m}{d} \rfloor} 1\\
=&\sum_{d=1}^n \mu(d)\lfloor \frac{n}{d} \rfloor\lfloor \frac{m}{d} \rfloor
\end{aligned}
$$
带入到最开始的式子，得到：
$$
\begin{aligned}
&\prod_{i=1}^n\prod_{j=1}^m f_{\gcd(i,j)}\\
=&\prod_{d=1}^{n}f_d^{\sum_{i=1}^{\lfloor \frac{n}{d} \rfloor}\sum_{i=1}^{\lfloor \frac{m}{d} \rfloor}[\gcd(i,j)=1]}\\
=&\prod_{d=1}^n f_d^{\sum_{k=1}^{\lfloor\frac{n}{d}\rfloor}\mu(k)\lfloor \frac{n}{kd} \rfloor\lfloor \frac{m}{kd} \rfloor}\\
=&\prod_{d=1}^n\left(\prod_{k|d}f_k^{\mu(\frac{d}{k})} \right)^{\lfloor\frac{n}{d}\rfloor \lfloor\frac{m}{d}\rfloor}
\end{aligned}
$$
其中括号内的式子可以通过$O(n\log n)$在最开始预处理出来。对于每组数据，使用数论分块，时间复杂度为$O(\sqrt n)$，所有数据求答案的时间复杂度为$O(t\sqrt n)$.