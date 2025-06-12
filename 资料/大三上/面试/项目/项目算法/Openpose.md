**什么是姿态估计呢？**
得到人体各个关键点位置，将它们按顺序进行拼接

**17个关键点**
脖子可以用肩旁平均值
COCO数据集提供17个。咱们任务17+1=18个

<img src="C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223201736236.png" alt="image-20241223201736236" style="zoom: 33%;" />

> **Top-down方法两步走**
> 1.检测得到所有人的框；2.对每一个框进行姿态估计输出结果
>
> ![image-20241223202213827](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223202213827.png)
>
> 姿态估计做成啥样主要由人体检测所决定，能检测到效果估计也没问题
> 但是如果俩人出现重叠，只检测到一个人，那肯定会丢失一个目标
> ==计算效率有点低，如果一张图像中存在很多人，那姿态估计得相当慢了==
> 能不能==设计一种方法不依赖于人体框而是直接进行预测==呢？

# 一、整体结构

**bottom-up**

1.首先得到所有关键点的位置
2.图中有多个人，我们需要把属于同一个人的拼接到一起

如果得到关键点位置：通过热度图（高斯）得到每一个关键点的预测结果

==得到18个特征图（因为18个关键点）==

![image-20241223202855410](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223202855410.png)

将属于同一个人的不同关键点按顺序拼接

19种连接方式（19*2=38）。2是因为一个是x一个是y

![image-20241223203132193](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223203132193.png)

**模型要完成的任务**

![image-20241223203153894](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223203153894.png)

![image-20241223203744014](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223203744014.png)

stage越多相当于层数越深，模型感受野越大，姿态估计需要更大的感受野

![image-20241223203815623](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223203815623.png)

每个stage都加损失函数，也就是中间过程也得做的好才行

![image-20241223203840103](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223203840103.png)

两个网络结构分别搞定：1.关键点预测；2.姿势的‘亲和力’向量

![image-20241223203944458](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223203944458.png)

# 二、关键点预测

<img src="C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223204116575.png" alt="image-20241223204116575" style="zoom:33%;" />

一口气预测所有关键点的热度图

<img src="C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223204127450.png" alt="image-20241223204127450" style="zoom:33%;" />

# 三、关键点的连接

Part Affinity Fields（部分亲和场）
在标签中，我们还需要设计PAF来表示关键点连接向量（这是GT）

<img src="C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223204716662.png" alt="image-20241223204716662" style="zoom:50%;" />

==现在已知所有关键点位置==（例如头和脖子）
要看==如何连接才能符合PAF向量趋势==，可以这种符合程度当作得分
==对得分结果进行匈牙利匹配==

两个关键点j1与j2之间的权值计算方法
$d_{j1},d_{j2}分别表示j1与j2两点的坐标$
$求j1和j2间各点的PAF在线段j1j2上投影的积分$
其实就是==线段上各点的PAF方向如果与线段的方向越接近权值就越大==

![image-20241223205206162](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223205206162.png)

![image-20241223205211479](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223205211479.png)

<img src="C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223205225971.png" alt="image-20241223205225971" style="zoom:50%;" />

![image-20241223205239273](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223205239273.png)

![image-20241223205405903](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241223205405903.png)

制作PAF与关键点的标签（特征图上的标签）