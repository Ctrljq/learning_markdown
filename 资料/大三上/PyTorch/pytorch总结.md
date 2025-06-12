## 1、神经网络分类任务

导入数据

数据预处理：转换格式为tensor。初始化权重，偏置。选择损失函数。确定一次训练个数

**定义训练模型**：init：多少层，输出维度，dropout。forward：细化训练步骤

<img src="C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241012123701266.png" alt="image-20241012123701266" style="zoom: 80%;" />

数据源定义：dataset组合数据，dataloader按照规定大小分批次打包数据

训练模块：

<img src="C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241012124329653.png" alt="image-20241012124329653" style="zoom:150%;" />

损失与训练模块：

![image-20241012124407386](C:/Users/HUAWEI/AppData/Roaming/Typora/typora-user-images/image-20241012124407386.png)

总结：

数据预处理（tensor形式，打包为dataset，dataloader（是否需要数据增强transform））。

前向传播（模型的`__init__`（初始化w，b）forward，每一层向量，BN，dropout，非线性函数，输出层），

​           【如果用预训练模型，哪些参数要更新，哪些不更新】

反向传播（损失函数，梯度&优化，学习率及学习率调度器）

三步走。

2、

句子->分字->得到ID->转换为向量

3、

