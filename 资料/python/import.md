## 1、collections

在Python的`collections`模块中，`Counter`和`defaultdict`是两种非常有用的数据结构，它们提供了一些标准的字典不支持的功能。

### （1）`Counter`

`Counter`是一个特殊的字典，用于计数可哈希对象。它是字典的一个子类，提供了帮助我们对数据进行快速统计的工具。常用于计算各个元素出现的次数。

```py
from collections import Counter

# 示例：计算列表中元素的频率
words = ['apple', 'banana', 'apple', 'orange', 'banana', 'apple']
counter = Counter(words)

print(counter)  # 输出 Counter({'apple': 3, 'banana': 2, 'orange': 1})

```

### （2）`defaultdict`

`defaultdict`也是一个字典的子类，它提供了一个默认值，用于字典访问时键不存在的情况。这意味着使用`defaultdict`时，如果你尝试访问字典中不存在的键，字典会自动为该键赋予一个默认值，而不是抛出一个`KeyError`。

```py
from collections import defaultdict

# 示例：用defaultdict来存储键的出现次数
word_counts = defaultdict(int)  # 默认值是int，即0

for word in words:
    word_counts[word] += 1

print(dict(word_counts))  # 输出 {'apple': 3, 'banana': 2, 'orange': 1}

```

- **使用`Counter`时**，最适合的场景是你需要计数的任务。它已经为你优化了计数操作，并提供了额外的计数相关方法，如`most_common()`等。
- **使用`defaultdict`时**，它更灵活，你可以指定任何默认工厂函数，如`list`、`int`等，这在你需要集合中的元素初始化为特定类型（如列表或集合）时特别有用。