# Python常用函数

### 1、reduce()

reduce() 函数将可迭代对象中的前两个元素传递给指定的函数进行处理，然后将处理结果与可迭代对象中的下一个元素进行处理，直到处理完所有元素，最终返回累积结果。

reduce(function, iterable[, initializer])
其中，function 是一个需要接受两个参数的函数，用于对可迭代对象中的元素进行处理。
iterable 是一个可迭代对象，包含要处理的元素。initializer 是可选的初始值，用于指定累积结果的初始值。

```py
下面是一个使用 reduce() 函数计算阶乘的示例：
from functools import reduce
def factorial(n):
    return reduce(lambda x, y: x * y, range(1, n+1))
print(factorial(5)) # 输出 120

```

```py
# 创建函数
def add(a, b):
    result = a + b
    print(f"{a} + {b} = {result}")
    return result


from functools import reduce

result = reduce(add, [1, 2, 3, 4])
print("结果：", result)

'''
1 + 2 = 3
3 + 3 = 6
6 + 4 = 10
结果： 10
'''

```



### 2、lambda()

Lambda函数是一种匿名函数，也就是没有名字的函数。它通常被用来作为参数传递给其他函数，或者在需要一个简短的函数时使用。Lambda函数通常只有一行代码，并且可以使用简洁的语法来定义。

我们可以将Lambda函数看作是一个可执行的表达式，它接受一些输入参数并返回一个结果。**Lambda函数可以接受任意数量的参数，但是**只能<u>返回一个结果</u>。

```
lambda arguments: expression
其中，arguments是Lambda函数的输入参数
，expression是Lambda函数的执行体，它会被执行并返回结果。
lambda函数可以使用常规的函数功能，例如控制流语句、条件语句等。

```

```python
lambda x: x + 5
这个Lambda函数可以像下面这样使用：
add_five = lambda x: x + 5
result = add_five(10)
print(result)   # 输出 15

```



### 3、all(),any()

all(iterable)：如果可迭代对象中的所有元素都为True，<u>则返回True，否则</u><u>返回False</u>。如果可迭代对象为空，则返回True。
any(iterable)：如果可迭代对象中的至少一个元素为True，<u>则返回True，否则返回False</u>。如果可迭代对象为空，则返回False。

```python
numbers = [1, 2, 3, 4, 5]
if all(num > 0 for num in numbers):
    print("All numbers are positive")
else:
    print("There are some non-positive numbers")

if any(num > 4 for num in numbers):
    print("At least one number is greater than 4")
else:
    print("No number is greater than 4")
    
'''在上面的列子中，第一个if语句使用all()函数判断列表中的所有元素是否为正数，如果是，则输出"All numbers are positive"，否则输出"There are some non-positive numbers"。第二个if语句使用any()函数判断列表中是否有元素大于4，如果有，则输出"At least one number is greater than 4"，否则输出"No number is greater than 4"。'''

```

### 4、sorted()

​					**sorted(iterable, key=None, reverse=False)**
iterable: 需要排序的可迭代对象，例如列表、元组、集合、字典等。
key（可选参数）: **用于指定排序的关键字(排序依据，看哪个)**。key是一个函数，它将作用于iterable中的每个元素，并返回一个用于排序的关键字。默认为None，表示按照元素的大小进行排序。key可以等于某个值，可以等于某个函数。
reverse（可选参数）: 用于指定排序的顺序。<u>如果设置为True，则按照逆序排序</u>。默认<u>为False，表示按照正序排序</u>。

```python
numbers = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
sorted_numbers = sorted(numbers)
print(sorted_numbers)  # 输出结果为 [1, 1, 2, 3, 3, 4, 5, 5, 5, 6, 9]

words = ["apple", "banana", "cherry", "date"]
sorted_words = sorted(words, key=len)
print(sorted_words)  # 输出结果为 ["date", "apple", "banana", "cherry"]

numbers = [(1, 2), (3, 4), (2, 1), (4, 3)]
sorted_numbers = sorted(numbers, key=lambda x: x[1])
print(sorted_numbers) 				# 输出结果为 [(2, 1), (1, 2), (4, 3), (3, 4)]

#在上面的示例中，第一个示例对一个整数列表进行排序，第二个示例对一个字符串列表按照字符串长度进行排序，
#第三个示例对一个元组列表按照元组中第二个元素进行排序，其中使用了lambda表达式作为key参数来指定排序方式。

```



### 5、map()

map函数<u>返回的是一个迭代器对象</u>，因此如果要使用它的结果，需要将它转换为一个列表list()、元组tuple()或集合set()和其他可迭代对象。

```python
'''
map(函数名，可迭代对象) 是函数名不用加()
map函数是一种高阶函数，它接受一个函数和一个可迭代对象作为参数，返回一个新的可迭代对象，
其中每个元素都是将原可迭代对象中的元素应用给定函数后的结果。
可以简单理解为对可迭代对象中的每个元素都执行同一个操作，返回一个新的结果集合。
需要注意的是，

map函数返回的是一个迭代器对象，因此如果要使用它的结果，需要将它转换为一个列表list()、元组tuple()或集合set()和其他可迭代对象。
'''

map函数的一些应用
1.用来批量接收变量
n,m = map(int,input().split())        #此处int（）是类型转换函数     .split()方法

2.对可迭代对象进行批量处理返回列表map
m = map("  ".join,[["a","b","c"],["d","e","f"]])                 #.join方法
k=list(m)
print(k)                  #['a  b  c', 'd  e  f']

3.配合lambda函数达到自己想要的效果
numbers = [1, 2, 3, 4, 5]
doubled_numbers = map(lambda x: x * 2, numbers)
print(list(doubled_numbers))  # [2, 4, 6, 8, 10]

4.此外，map 函数还可以接受多个列表参数，使得多个列表合并为一个列表成为可能，例如，将两个列表相同位置的元素相加得到一个新的列表
def merge(x, y):
    return x + y

result = map(merge, [1, 2, 3], [3, 2, 1])
print(list(result))            #[4,4,4]

```

![请添加图片描述](https://img-blog.csdnimg.cn/335004bd71b8417c9e6616d0f8b0c815.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L20wXzQ2MjA0MjI0,size_16,color_FFFFFF,t_70)

#### ①.split()方法

split 接收一个参数（以什么为间隔），**字符串序列.split(分割字符，num)**用于将字符串切割成列表，比如一段英文字符串按照空格切割就可以统计出单词的个数，

```py
text = "apple,banana,cherry"
parts = text.split(',')  # 指定逗号为分隔符,默认为空格
print(parts)  # 输出: ['apple', 'banana', 'cherry']

mystr='hello world and itcast and itheima and Python'
 
print(mystr.split('and')) #默认全分
 
print(mystr.split('and',2)) #分割两次
 
print(mystr.split(' '))
 
```

#### ②.join方法

它可以将列表对象用指定的字符作为元素之间的连接，转换为字符串。

```py
words = ['python', 'is', 'the', 'best', 'programming', 'language']

print(" ".join(words)) # 用空格连接 python is the best programming language

```

```python
s = "ABCDEF"
s1 = '.'.join(s)
# 输出：A.B.C.D.E.F

#或者
s2 = '_'.join(s)
#输出：A_B_C_D_E_F

#或者
s3 = '/'.join(s)
#输出 A/B/C/D/E/F

#或者
symbol = ','
s4 = symbol.join(s)
#输出：A,B,C,D,E,F


```



### 6、filer()

filter(function, iterable)

其中，function 是一个函数，接受一个参数，并返回 True 或 False。iterable 是一个序列，可以是列表、元组、集合、字符串等。

filter() 函数的工作原理是对序列 iterable 中的每个元素，都调用函数 function 进行判断，如果 function 返回 True，则将该元素添加到结果序列中，否则丢弃该元素。最后，<u>filter() 函数返回结果迭代器对象</u>。

```py
my_list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
result = filter(lambda x: x % 2 == 0, my_list)
print(list(result))  # 输出 [2, 4, 6, 8, 10]
在这个例子中，lambda x: x % 2 == 0 是一个 lambda 函数，用于判断一个数是否为偶数。filter() 函数将这个 lambda 函数作为参数，对列表 my_list 进行过滤，最后返回一个新列表，其中包含 my_list 中所有的偶数。

```

### 7、zip()

zip()用于将多个可迭代对象中对应位置的元素打包成一个元组，并返回一个新的可迭代对象。

```py
list1 = [1, 2, 3]
list2 = ['a', 'b', 'c']
zipped = zip(list1, list2)
print(list(zipped))

# Output: [(1, 'a'), (2, 'b'), (3, 'c')]
在第一个示例中，我们使用zip()函数将两个列表中对应位置上的元素打包成一个元组，并遍历输出每个人的姓名和年龄。
在第二个示例中，我们将两个列表中的元素打包成一个新的列表，并输出结果。

```

### 8、python推导式

```
在Python中，推导式是一种方便的语法结构，用于根据一些规则来构建新的序列对象。Python支持以下几种类型的推导式：
								列表推导式
列表推导式允许您根据一些规则来创建一个新的列表。它的语法为：
css
[表达式 for 变量 in 序列对象 if 条件]
其中，表达式是根据变量计算的值，变量是迭代序列对象的每个元素，并且如果条件为真，则包含在生成的列表中。
例如，以下列表推导式生成一个由1到10的偶数构成的列表：
even_numbers = [x for x in range(1, 11) if x % 2 == 0]print(even_numbers)  # 输出 [2, 4, 6, 8, 10]

								字典推导式
字典推导式允许您根据一些规则创建一个新的字典。它的语法为：
css
{键表达式: 值表达式 for 变量 in 序列对象 if 条件}
其中，键表达式和值表达式是根据变量计算的值，变量是迭代序列对象的每个元素，并且如果条件为真，则包含在生成的字典中。
例如，以下字典推导式生成一个由1到5的整数平方组成的字典：
squares = {x: x ** 2 for x in range(1, 6)}print(squares)  # 输出 {1: 1, 2: 4, 3: 9, 4: 16, 5: 25}

									集合推导式
集合推导式允许您根据一些规则创建一个新的集合。它的语法与列表推导式类似，只是用花括号替代了方括号。
例如，以下集合推导式生成一个由1到10的奇数组成的集合：
odd_numbers = {x for x in range(1, 11) if x % 2 == 1}print(odd_numbers)  # 输出 {1, 3, 5, 7, 9}

										生成器表达式
生成器表达式与列表推导式类似，但是它生成一个生成器对象，而不是一个列表对象。它的语法与列表推导式类似，只是用圆括号替代了方括号。例如，以下生成器表达式生成一个由1到10的偶数构成的生成器对象：
even_numbers = (x for x in range(1, 11) if x % 2 == 0)for num in even_numbers:    print(num)  # 输出 2, 4, 6, 8, 10hello

```

```py
[i + j + k for i in "ABCD" for j in "ABCD" if i != j for k in "ABCD" if k not in j + i]
>>>['ABC', 'ABD', 'ACB', 'ACD', 'ADB', 'ADC', 'BAC', 'BAD', 'BCA', 'BCD', 'BDA', 'BDC', 'CAB', 'CAD', 'CBA', 'CBD', 'CDA', 'CDB', 'DAB', 'DAC', 'DBA', 'DBC', 'DCA', 'DCB']

# 创建一个包含100万个相同字符串的列表
large_list = ['example'] * 1000000

# 创建一个包含100万个不同字符串的列表，每个字符串都是其索引的字符串表示
large_list = [str(i) for i in range(1000000)]


```

### 9、enumerate()

enumerate 函数用于迭代列表等可迭代对象，它的使用场景一般出现在你需要获取列表的下标位置时，我们知道直接用`for`循环去迭代列表时，是拿不到元素下标位置的，而 enumerate 就可以获取，否则你还得自己去定义一个索引变量。

```py
for index, w in enumerate(words):
    print(index, w)

```

### X、组合使用

```py
T = [(1,2,3,4,5),(5,9,4,3,4,6),(7,3,4,5,6)]
a = map(lambda x:sorted(x,reverse=True),T)
print(list(a))
>>[[5, 4, 3, 2, 1], [9, 6, 5, 4, 4, 3], [7, 6, 5, 4, 3]]
```

```py
reduce(lambda x, y: x ^ y, nums)
```

