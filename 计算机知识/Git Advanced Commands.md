# 🌳 Git 高级命令与统计分析

> 继 Git 基础操作后，本文简明介绍 `git merge`，`git fetch`，`git log`等命令以及其实际使用场景，帮助理解 Git 仓库统计与分支合并流程。

------

## 一、重要概念示意图

```text
           git pull
             ⇓
  +-----------------------+
  |     git fetch         |     ◀️拉取远程仓库
  +-----------------------+
             ⇓
        当前本地分支
             ⇒ git merge
             ⇒ 合并远程分支到本地
```

- `git fetch` ：只下载远程仓库信息
- `git merge` ：合并分支，生成新 commit
- `git pull` ：`fetch + merge`的简写组合

![img](https://i-blog.csdnimg.cn/blog_migrate/84a7a87c9b738213fb4aaf1604d8f889.png)

------

## 二、`git merge` 合并分支

### 作用

将其他分支的提交合并到当前分支，保留历史记录

### 示例

```bash
git checkout main
git merge dev
```

将 `dev` 分支的内容 merge 到 `main`

### 常见冲突

- 两个分支同一个文件同一行有修改
- Git 不知道你想要哪个内容

### 解决方案

- 手动修改冲突文件
- 保存后

```bash
git add .
git commit -m "resolve conflict"
```

------

## 三、`git fetch` 拉取远程仓库

### 作用

- ==下载远程分支更新，但 **不合并到本地分支**==
- 实现 **分步拉取 + 合并**的精精操控

### 字段解释

“git fetch” 用于从远程仓库获取最新数据到本地，但不会自动合并到当前分支

“origin” 是远程仓库的默认名称，这里指定要从名为 “origin” 的远程仓库获取数据

“dev:dev_remote” 表示将远程仓库中的 “dev” 分支获取到本地，并命名为 “dev_remote”

**==例如，若本地项目关联了远程仓库 origin，远程仓库有个 dev 分支，执行此命令后，本地就会有一个基于远程 dev 分支的 “dev_remote” 分支==**

### 示例

```bash
git fetch origin
```

或者

```bash
git fetch origin dev:dev_remote
```

把 origin/dev 拉到本地新分支 dev_remote

------

## 四、`git log` 查看历史

### 基本用法

```bash
git log
```

### 常用参数

```bash
git log --oneline --graph --all --decorate
```

### 说明

| 参数         | 作用                       |
| ------------ | -------------------------- |
| `--oneline`  | 每条提交显示一行           |
| `--graph`    | 显示分支结构树状图         |
| `--all`      | 包括所有分支               |
| `--decorate` | 显示 HEAD、tag、分支等标签 |

### 示例图：

```
* 64df1d2 (HEAD -> main) add doc
|
* 5e8a1b2 (origin/main, origin/HEAD) fix bug
|
* 41f1ac0 init project
```

------

## 五、其他常用命令

| 命令                    | 作用                          |
| ----------------------- | ----------------------------- |
| `git branch`            | 列出本地分支                  |
| `git branch -a`         | 包括远程分支                  |
| `git checkout <branch>` | 切换分支                      |
| `git switch <branch>`   | 更新写法，切换分支            |
| `git status`            | 查看本地状态                  |
| `git diff`              | 显示未 add 或 commit 修改详情 |
| `git reset HEAD <file>` | 移除暂存区的指定文件          |
| `git clean -fd`         | 清理未追踪文件（💀危险）       |

------

## 六、最佳实践

### case1：

1. 使用 `fetch + merge` 而不是直接 `pull`，控制更精细
2. 合并前先 `git log` 查看历史
3. 尽量统一名称，记录添加同步步骤
4. 每次 merge 前先确保本地 clean

------

若需规则化的 Git commit 信息统一风格，我也可以继续补充。

### case2：

**拉取远端仓库最新代码并覆盖原有的本地代码**

1.丢弃本地修改

```bash
# 进入仓库目录

cd ~/code/ddgd_data_pipeline

# 获取最新远程代码

git fetch origin

# 丢弃所有本地修改并重置到远程最新状态

git reset --hard origin/main
```

2.保存本地修改

使用 git stash、git pull 和 git stash pop 这一系列命令时，如果您的本地修改与远程仓库的更新存在冲突，那么在执行 git stash pop 阶段就会出现冲突提示，您需要手动解决这些冲突。

具体流程是这样的：

> [!NOTE]
>
> 1. git stash 会将您的本地修改暂时保存起来
> 2. git pull 会拉取远程最新代码
> 3. git stash pop 尝试将您暂存的修改重新应用到更新后的代码上

如果==暂存的修改与拉取的代码修改了相同文件的相同部分，Git会提示冲突，您需要手动选择保留哪些更改==。解决冲突后，需要手动添加并提交这些更改。

```bash
# 或者如果您想保留本地修改但想更新代码，可以使用

git stash

git pull

git stash pop  # 可能会有冲突需要解决
```

## 七、命令对比

### **两种创建 Git 新分支的方式**

**核心区别：底层机制与适用场景**

#### **1. git fetch**

**`git fetch origin dev:new_branch`**

- **本质**：
  从远程仓库 `origin` 获取 `dev` 分支数据，**直接在本地创建新分支** `new_branch`，指向 `origin/dev` 的最新提交。
- 特点：
  - **不依赖当前分支**：无论当前处于哪个分支，新分支均基于远程 `dev` 创建。
  - **无自动跟踪**：`new_branch` 与 `origin/dev` 无默认跟踪关系（需手动设置）。
  - **轻量级获取**：仅拉取数据并创建分支，**不切换当前工作分支**。
- 适用场景：
  - 快速获取远程分支副本，用于临时查看、对比代码，不影响本地开发流程。
  - 需保留远程分支历史，但无需立即切换开发环境。

#### **2. git checkout**

**`git checkout -b new_branch`**

- **本质**：
  基于**当前所在分支**（或指定分支）创建新分支，并**自动切换到新分支**。
- 特点：
  - **依赖当前分支**：新分支初始提交源于当前分支最新状态。
  - 变种用法：
    - `git checkout -b new_branch origin/dev`
      ✅ 基于远程 `origin/dev` 创建新分支，并**自动跟踪远程分支**。
    - `git checkout -b new_branch dev`
      ✅ 基于本地 `dev` 分支创建新分支（需提前拉取远程 `dev` 最新代码）。
  - **一键切换**：创建后直接进入新分支，立即开始开发。
- 适用场景：
  - 在本地分支基础上创建功能分支（如 `feature/new`）。
  - 需要与远程分支保持同步跟踪，适合团队协作开发。

#### **3.核心区别对比表**

| **维度**         | `git fetch origin dev:new_branch`        | `git checkout -b new_branch`                  |
| ---------------- | ---------------------------------------- | --------------------------------------------- |
| **创建基础**     | ==直接基于远程 `origin/dev` 的最新提交== | ==基于当前分支或指定分支（本地 / 远程均可）== |
| **分支关联**     | 无自动跟踪关系（需手动设置 `--track`）   | 可自动跟踪远程分支（指定 `origin/dev` 时）    |
| **是否切换分支** | 不切换（仍停留在当前分支）               | 自动切换到新分支 `new_branch`                 |
| **典型用途**     | 临时获取远程分支副本，用于代码评审或对比 | 直接开始新功能开发，需与远程保持同步          |

#### **4.示例对比**

**（远程 `origin/dev` 有新提交）**

 **场景 1：使用 `git fetch` 创建独立分支**

```bash
# 当前在 master 分支（未跟踪 dev）  
git fetch origin dev:new_branch  # 创建 new_branch，指向 origin/dev 最新提交  
git branch -vv                   # 结果：仍在 master 分支，new_branch 无跟踪信息  
```

**场景 2：使用 `git checkout` 创建跟踪分支**

```bash
# 当前在 master 分支（需基于远程 dev 开发）  
git checkout -b new_branch origin/dev  # 创建并切换到 new_branch，自动跟踪 origin/dev  
git branch -vv                          # 结果：已在 new_branch，显示 "[origin/dev] 最新提交"  
```

#### **5.总结建议**

- **选 `git fetch`**：
  需快速获取远程分支快照，不影响当前开发进度，或需创建 “只读” 分支用于对比。
- **选 `git checkout -b`**：
  需立即在新分支开发，且希望分支自动与远程关联（尤其适合团队协作场景）。
- **最佳实践**：
  日常开发优先使用 `checkout -b` 系列命令；涉及跨分支对比或历史追溯时，搭配 `fetch` 使用。

**备注**：

- Git 新版本推荐用 `git switch` 替代 `checkout`（如 `git switch -c new_branch origin/dev`），功能等价但语义更清晰。
- 跟踪关系可通过 `git branch --set-upstream-to=origin/dev new_branch` 手动设置。