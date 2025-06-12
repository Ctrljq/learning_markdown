# Python复习笔记-1

## 一、变量与简单的数据类型

### 1、字符串

各首字母大写：.title(),

全大写：.upper(),

全小写：.lower()。

> **拼接字符串方法：**`f"{string_1} hello world   "`     
>
>  #有特殊含义的要用花括弧可将其直接赋值给某一个字符串或直接print(f“       ”)



```python
KB='mamba out'
K='what can i'
print(f'{K.title()} say {KB.upper()}')        #输出   What Can I say MAMBA OUT
```

删除空格：.rstrip()    .lstrip()     .strip()

删除前缀：.removeprefix('https')

```python
KB='    mamba out'
print(KB.lstrip())                                 #mamba out
print(KB)                                          #    mamba out
KB=KB.lstrip()                                     
KB=KB.removeprefix('mamba')
print(KB)                                          # out
```

### 2、数

基本运算规则： **表示乘方；两数相除结果为浮点数；两操作数有浮点数，则结果也为浮点数。

​			可以同时给多个数赋值，用逗号隔开；常量则字母全大写。

```python
num_1,num_2=10**2,3
num_3=num_1/num_2
print(num_3)                 #33.333333333333336
```

## 二、列表（数组）

### 1、列表简介

特点：-1，-2，-3可表示列表倒数第1,2,3个元素

<u>增删改查</u>：

```py
sort()
b=[1,6,2]
b.sort()#这里不能写b=b.sort()
print(b)
以下也是
a.append  #添加的可以是str ，int
a.extend
b.insert
a.remove(10)#尽管a中有多个10，只去一个
```

```python
.append('xxxxx')           #在列表末加
.insert(n,'xxxxx')         #在列表中加，其他元素都后移一位
del listt[n]                #删除第n位
elment=listt.pop()          #删除list最后一位，并把其赋值给elment
listt.remove('xxxxx')       #删除值为xxxxxx的第一个元素           不同于pop（），无返回值
```

```python
num=[4,2,3]
print(num)                             #[4, 2, 3]
arr=['lbj','kobe','mj','kd','pg','ad']
arr.append('RW')
print(arr[-1])                         #RW
arr.insert(8,'magic')
print(arr[-1])                         #magic
arr.remove('mj')
print(arr[2])                          #kd
```

<u>管理列表</u>：

```python
listt.sort()                   #永久升序
listt.sort(reverse=True)       #永久降序 
sorted(listt)                  #临时升序
listt.reverse()                #永久反向
len(listt)                     #算列表长度
```

```python
arr=['lbj','kobe','mj','kd','pg','ad']
print(sorted(arr))                       #['ad', 'kd', 'kobe', 'lbj', 'mj', 'pg']
print(arr)                               #['lbj', 'kobe', 'mj', 'kd', 'pg', 'ad']
arr.reverse()
print(arr)                               #['ad', 'pg', 'kd', 'mj', 'kobe', 'lbj']
arr.sort(reverse=True)
print(arr)                               #['pg', 'mj', 'lbj', 'kobe', 'kd', 'ad']
print(len(arr))                          #6
```

### 2、操作列表

<u>数值操作</u>：

```python
for str(临时变量) in arr(列表):
    operation.........        
print('end')                               #遍历列表

range(m)                                   #从0到m-1
range(n,m)                                 #从n到m-1
range(n,m,x)                               #从n开始n+x,n+2x........到m-1

num=list(range(m))                         #将range结果赋值给num列表

min(num),max(num),sum(num)                 #三种数值函数

nums=[num**2 for num in range(1,11)]       #列表推导式
```

```python
for value in range(2,6,2):
    print(value)                          #2 4
num=list(range(2,12,2))
print(num)                                #[2, 4, 6, 8, 10]
nums=[a**2 for a in range(2,12,2)]  
print(nums)                               #[4, 16, 36, 64, 100]
```

<u>截取列表部分</u>：

```python
nums=[a**2 for a in range(2,18,2)]
print(nums)                               #[4, 16, 36, 64, 100, 144, 196, 256]
print(nums[0:3])                          #[4, 16, 36]
print(nums[2:])                           #[36, 64, 100, 144, 196, 256]
print(nums[2::2])                         #[36, 100, 196]

#复制列表
integer=nums[0:-1]
print(integer)                            #[4, 16, 36, 64, 100, 144, 196]
integer=nums[:]
print(integer)                            #[4, 16, 36, 64, 100, 144, 196, 256]
```

<u>元组</u>：

![f6813c6a540d0ff350d08d756944bf84](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\f6813c6a540d0ff350d08d756944bf84.png)

不能直接print(dimensions)。

## 三、IF语句

### 1、条件测试

检查多个条件：and，or

检查特定值是否在列表中：in

检查特定值是否不在列表中：not in

```python
MY=[a**2 for a in range(2,18,2)]
var = 4 in MY
var_1=(4 in MY) or (17 in MY)
print(var)                            #True
print(var_1)                          #True
```

<u>两种循环</u>

```py
i=0
a=(lambda i:2*i)
while i<=a(i) and i<=10:
    print(i)
    i+=1
  
for j in range(0,10):
    print(f'{j}比{j-1}大1')
    
    
while，if，for与in not in 搭配
```



### 2、if语句

```
if                    执行一次或零次
if...else...          执行一次
if...elif...else      执行一次  
if.....if.....if..    执行零次~无穷次
```

例1![f326b9ca157965a42bb112b8fad2cdce](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\f326b9ca157965a42bb112b8fad2cdce.png)例2![fecb9bac38bbd7f5c1cc042fe08e1167](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\fecb9bac38bbd7f5c1cc042fe08e1167.png)

## 四、字典（结构体）

### 1、使用字典

![6632b1a3c83b1ea9c6f7fb9ce6a791fe](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\6632b1a3c83b1ea9c6f7fb9ce6a791fe.png)

==字典用的是花括号==

<u>字典基本操作</u>

```python
alien={'color':'blue','grade':'90'}

#添加键对值
alien['planet']='earth'
#修改键对值
alien['color']='red'
#删除键对值
del alien['grade']

#使用.get()的访问值             
m=alien.get('color')
h=alien.get('grade','不存在')
print(m)                               #red
print(h)                               #不存在


#遍历所有键对值
for k,v in alien.items():
    print(k+':'+v)                     #color:red
#遍历所有键                              #planet:earth
for n in alien.keys():
    print(n)                           #color
                                       #planet
for n in sorted(alien.keys())   #按照特定顺序

#遍历所有值

```

<u>**字典也是''使用很好的典范**</u>

![6756fd1c0a5feaaa601b85fc6ea9cbe7](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\6756fd1c0a5feaaa601b85fc6ea9cbe7.png)

![83e5206764e0800f9244fe9a7b998341](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\83e5206764e0800f9244fe9a7b998341.png)

```python
language={'lbj':'c',"kd":'java','rw':'python','sc':'html','mj':'java'}
for value in language.values():
    print(value)
print('****************************')
for value in set(language.values()):           #set()   相当于是集合操作，可以将重复项剔除
    print(value)                                
输出
c
java
python
html
java
****************************
java
html
python
c
```

#### 关于列表，字典，集合

|          | 列表           | 字典           | 集合      |
| -------- | -------------- | -------------- | --------- |
| 添加元素 | List.append.() | Dic[key]=value | Set.add() |
| 初始化   | List=[]        | dic={}         | Set=set() |
|          |                |                |           |



### 2、字典列表

即许多个字典存储在一个列表里面。

![54acdd1d29ac472fac814538c6991dbc](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\54acdd1d29ac472fac814538c6991dbc.png)

### 3、列表字典

即字典中一个键关联着一个列表

![6e9c96d83a8ef84ceebabdb2ba02a930](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\6e9c96d83a8ef84ceebabdb2ba02a930.png)![79b89643932189f02c1bba454673d2cb](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\79b89643932189f02c1bba454673d2cb.png)

### 4、字典字典

![fcb22f33d88968f8ae39e13d1ad28f14](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\fcb22f33d88968f8ae39e13d1ad28f14.png)

## 五、用户输入与while循环

### 1、用户输入

```python
age=input("请输入一个数字：")
print(age)             #此时的age是字符串22
age=int(age)
print(age)
请输入一个数字：22
22
22
```

### 2、while循环

<u>while循环处理列表和字典（for难以跟踪元素）</u>

①.在列表间移动元素

![aaece890b9bfcc6c0ebe241c05b628d9](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\aaece890b9bfcc6c0ebe241c05b628d9.png)![3c51dbefece4b5c80dfd4ded74523807](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\3c51dbefece4b5c80dfd4ded74523807.png)

②.删除特定的所有元素

![842ecaddf609b2556625bacdc1ed10d0](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Ori\842ecaddf609b2556625bacdc1ed10d0.png)



③.使用用户输入填充字典

![2f9fa01d55a4563f98a502deda3b1194_720](C:\Users\HUAWEI\Documents\Tencent Files\1436941594\nt_qq\nt_data\Pic\2024-04\Thumb\2f9fa01d55a4563f98a502deda3b1194_720.png)

## 六、函数

### 1、自定义函数-1

python中函数定义以def关键字开始，其后空一格跟函数名

括号中的参数可有可无，小括号后面的冒号“:”是python函数的基本格式要求，不能省略。这里的参数传递对象包括数字、字符串、元组、列表、字典以及类对象。

```python
def find_factor(nums):
    i=1
    str1=""
    print("%d的因数是："%nums)
    while i<=nums:
        if nums%i==0:
            str1 = str1+" "+str(i)               #若题目要求以某种格式输出
        i += 1
    print(str1)


num_L=[10,15,18,20]
i = 0
num_len=len(num_L)
while i<num_len:
    find_factor(num_L[i])
    i+=1

'''10的因数是：
 1 2 5 10
15的因数是：
 1 3 5 15
18的因数是：
 1 2 3 6 9 18
20的因数是：
 1 2 4 5 10 20'''

```

<u>带返回值的函数</u>

自定义函数编写完成后，需要考虑到使用的方便性，如编程人员过了几个月或者几年后都能轻易地知道函数的功能及如何使用。由此，需要对自定义函数建立相应的函数文档。函数文档在函数中通常用三引号（’’’）来表示。

```python
def find_factor(nums):
    '''
    find_factor  自定义函数
    nums 传递一个正整数的参数
    以字符串形式返回一个正整数的所有因数

    '''
    i=1
    str1=""
    print("%d的因数是："%nums)
    while i<=nums:
        if nums%i==0:
            str1 = str1+" "+str(i)
        i += 1
    return str1


num_L=[10,15,18,20]
i = 0
num_len=len(num_L)
return_str=''
while i<num_len:
    return_str=find_factor(num_L[i])
    print("%d的因数是：%s"%(num_L[i],return_str))
    i+=1

'''10的因数是：
10的因数是： 1 2 5 10
15的因数是：
15的因数是： 1 3 5 15
18的因数是：
18的因数是： 1 2 3 6 9 18
20的因数是：
20的因数是： 1 2 4 5 10 20
'''

```

```python
def find_factor(nums):
    '''
    find_factor  自定义函数
    nums 传递一个正整数的参数
    以字符串形式返回一个正整数的所有因数

    '''
    if type(nums) != int:
        print("输入值类型错误，必须是整数")
        return
    elif nums<=0:
        print("输入值的范围出错，必须是整数！")
        return                                    #直接退出函数体
    
    i=1
    str1=""
    print("%d的因数是："%nums)
    while i<=nums:
        if nums%i==0:
            str1 = str1+" "+str(i)
        i += 1
    return str1


find_factor('a')
find_factor(-1)
hhh=find_factor(4)
print(hhh)                  #4的因数是：
                            #1 2 4


```

### 2、import函数

```python
#用import语句导入整个函数模块
import test_function
print(test_function.find_factor(8))
'''导入格式：import 函数模块名
调用模块文件中的函数格式：模块名.函数名'''

#用import语句导入指定函数
from test_function import find_factor
print(find_factor(8))
'''from 模块名 import 函数名1[，函数名2,…]'''

#用import语句导入所有函数
from test_function import *
print(find_factor(8))
say_ok()
'''from 模块名 import *'''

#模块名、函数别名方式
>>> import test_function as t1
>>> t1.find_factor(8)
8的因数是：
' 1 2 4 8'
>>> from test_function import find_factor as f1
>>> f1(8)
8的因数是：
' 1 2 4 8'
>>> 
#模块名[函数名] as 别名


```

### 3、自定义函数-2

<u>参数变换</u>

```python
def test(name,age):
    print("姓名%s,年龄%s"%(name,age))

test(name='wky',age=20)
test(wky,20)
test(age=20,name='lyj')
test('wky',age=20)    #部分指定时，左边可以不指定，从右边指定开始


'''姓名wky,年龄20
姓名wky,年龄20
姓名lyj,年龄20
姓名wky,年龄20'''

#说明：
test(name='wky',20)  #调用会出错，不支持左边指定，右边不指定方式


```

为参数预先设置默认值，当没有传递参数值时，该参数自动选自默认值。

```python
def test(name='lyj',age=18):

    print("姓名%s,年龄%s"%(name,age))
    
#函数调用
test(18)
test()
test('wky',20)

'''#结果：
姓名18,年龄18     #函数默认输入一个值的情况下，把值赋给第一个参数
姓名lyj,年龄18
姓名wky,年龄20'''

```

<u>不定长参数</u>

使用格式：**函数名([param1,param2,…]\*paramX)**
带“*”的paramX参数，可以以接收任意数量的值，但是一个自定义函数只能有一个带"*"的参数，而且只能放置最右边的参数中，否则自定义函数执行时报语法错误。

```py
def watermelon(name,*attributes):
    print(name)
    print(type(attributes))
    description=''
    for get_t in attributes:
        description += ' ' +get_t

    print(description)

watermelon('西瓜','甜','圆形','绿色')
print('-'*30)
watermelon('西瓜','甜','圆形','绿色','红瓤','无籽')

'''西瓜
<class 'tuple'>
 甜 圆形 绿色
------------------------------
西瓜
<class 'tuple'>
 甜 圆形 绿色 红瓤 无籽'''

```

使用格式：**函数名([param1,param2,…]\**paramX)**
带“**”paramX参数用法和带“*”用法类似，区别：传递的是键值对。

```py
def watermelon(name,**attributes):
    print(name)
    print(type(attributes))
    return attributes

print(watermelon('西瓜',taste='甜',shape='圆形',colour='绿色'))

'''西瓜
<class 'dict'>
{'taste': '甜', 'shape': '圆形', 'colour': '绿色'}'''

```

<u>传递元组</u>

```py
#传递元组
def watermelon(name,attributes):
    print(name)
    print(type(attributes))
    return attributes

##get_t = watermelon('西瓜',('甜','圆形','绿色'))
##print(get_t)
print(watermelon('西瓜',('甜','圆形','绿色')))

#传递列表
def watermelon(name,attributes):
    print(name)
    print(type(attributes))
    return attributes

##get_t = watermelon('西瓜',['甜','圆形','绿色'])
##print(get_t)
print(watermelon('西瓜',['甜','圆形','绿色']))

#传递字典
def watermelon(name,attributes):
    print(name)
    print(type(attributes))
    return attributes

attri={'taste':"甜",'shape':"圆形",'colour':"绿色"}
print(watermelon('西瓜',attri))
'''西瓜
<class 'dict'>
{'taste': '甜', 'shape': '圆形', 'colour': '绿色'}'''


```

<u>注意</u>

​	在自定义函数内获取从参数传递过来的**==列表、字典==**对象后，若在函数内部对它们的元素进行变动，则会同步影响外部传递的变量的元素。

```python
def EditFrult(name,attributes):
    attributes[0]=attributes[0]*0.9    #修改元素
    return attributes

#调用函数
attri_L=[2,"甜","圆形","绿色"]
get_t = EditFrult("西瓜",attri_L)    #get_t = EditFrult("西瓜",attri_L.copy())  则不会修改原值
print(get_t)
print(attri_L)

'''[1.8, '甜', '圆形', '绿色']
[1.8, '甜', '圆形', '绿色']'''

```

- **不可变对象：在函数里进行值修改，会变成新的对象（在内存产生新的地址），包括：数字、字符串、元组**
- **可变对象：在函数里进值修改，函数内外还是同一对象，但是值同步发生变化。包括：列表、字典**



