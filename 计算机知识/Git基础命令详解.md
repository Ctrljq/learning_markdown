[TOC]

# 🌳 Git 基础命令详解

> 本文详细介绍 `git merge`、`git fetch`、`git log`等基础命令的使用方法和实际应用场景，帮助理解 Git 仓库操作与分支管理流程。

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

### 基本用法

```bash
git checkout main
git merge dev
```

将 `dev` 分支的内容 merge 到 `main`

### 合并类型

#### **1. Fast-forward 合并**

```bash
# 当目标分支直接基于当前分支时
main:    A → B → C
feature: A → B → C → D → E

# 执行 git merge feature 后：
main:    A → B → C → D → E  # 直接移动指针
```

#### **2. 三路合并❤**

```bash
# 当两个分支都有新提交时
main:    A → B → C → F
feature: A → B → C → D → E

# 执行 git merge feature 后：
main:    A → B → C → F → M  # M是新的合并提交
                   ↗ ↗
                  D → E
```

------

## 三、`git fetch` 拉取远程仓库

### 作用

- ==下载远程分支更新，但 **不合并到本地分支**==
- 实现 **分步拉取 + 合并**的精细操控

### 字段解释

**"git fetch"** 用于从远程仓库获取最新数据到本地，但不会自动合并到当前分支

**"origin"** 是远程仓库的默认名称，这里指定要从名为 "origin" 的远程仓库获取数据

**"dev:dev_remote"** 表示将远程仓库中的 "dev" 分支获取到本地，并命名为 "dev_remote"

### 常用命令

#### **1. 获取所有远程分支更新**

```bash
git fetch origin
```

#### **2. 获取特定分支**

```bash
git fetch origin dev:dev_remote
```

把 origin/dev 拉到本地新分支 dev_remote

#### **3. 获取并查看更新**

```bash
git fetch origin
git log --oneline origin/main  # 查看远程main分支的更新
```

### 实际应用场景

#### **如何将main分支的更新应用到你的功能分支：**

```bash
# 确保你在自己的功能分支上
git checkout feature/your-branch

# 获取远程仓库的最新更新
git fetch origin

# 合并main分支的更改到当前功能分支
git merge origin/main
```

当你在自己的分支上执行`git merge origin/main`时，如果有冲突发生，Git **不会自动覆盖**你的更改，而是会暂停合并过程，标记冲突，并等待你手动解决。

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

### 参数说明

| 参数         | 作用                       |
| ------------ | -------------------------- |
| `--oneline`  | 每条提交显示一行           |
| `--graph`    | 显示分支结构树状图         |
| `--all`      | 包括所有分支               |
| `--decorate` | 显示 HEAD、tag、分支等标签 |

### 实用组合命令

#### **1. 查看简洁的分支图**

```bash
git log --oneline --graph --all
```

#### **2. 查看最近N次提交**

```bash
git log -n 5  # 最近5次提交
```

#### **3. 查看特定作者的提交**

```bash
git log --author="张三"
```

#### **4. 查看特定时间范围的提交**

```bash
git log --since="2024-01-01" --until="2024-12-31"
```

### 示例输出：

```bash
$ git log --oneline --graph --all
* 51913ed (HEAD -> main, origin/main) add some files
* 03a364c Initial commit
```

------

## 五、其他常用命令

### 分支相关

| 命令                    | 作用               |
| ----------------------- | ------------------ |
| `git branch`            | 列出本地分支       |
| `git branch -a`         | 包括远程分支       |
| `git branch -r`         | 只显示远程分支     |
| `git checkout <branch>` | 切换分支           |
| `git switch <branch>`   | 更新写法，切换分支 |

### 状态与差异

| 命令                | 作用                      |
| ------------------- | ------------------------- |
| `git status`        | 查看本地状态              |
| `git diff`          | 显示未add的修改详情       |
| `git diff --staged` | 显示已add但未commit的修改 |
| `git diff HEAD`     | 显示所有未commit的修改    |

### 撤销与重置

| 命令                      | 作用                         |
| ------------------------- | ---------------------------- |
| `git reset HEAD <file>`   | 移除暂存区的指定文件         |
| `git reset --soft HEAD~1` | 撤销最近一次commit，保留修改 |
| `git reset --hard HEAD~1` | 撤销最近一次commit，丢弃修改 |
| `git clean -fd`           | 清理未追踪文件（💀危险）      |

------

## 六、实战案例

### case1: 精细化合并流程

**推荐工作流程：**

1. 使用 `fetch + merge` 而不是直接 `pull`，控制更精细
2. 合并前先 `git log` 查看历史
3. 尽量统一名称，记录添加同步步骤
4. 每次 merge 前先确保本地 clean

```bash
# 1. 获取远程更新
git fetch origin

# 2. 查看远程分支状态
git log --oneline origin/main

# 3. 确保工作区干净
git status

# 4. 执行合并
git merge origin/main

# 5. 查看合并结果
git log --oneline --graph
```

------

### case2: 拉取远端代码覆盖本地改动

#### **方式1：丢弃本地修改**

```bash
# 进入仓库目录
cd ~/code/your-project

# 获取最新远程代码
git fetch origin

# 丢弃所有本地修改并重置到远程最新状态
git reset --hard origin/main
```

#### **方式2：保存本地修改**

使用 git stash、git pull 和 git stash pop 这一系列命令时，如果您的本地修改与远程仓库的更新存在冲突，那么在执行 git stash pop 阶段就会出现冲突提示，您需要手动解决这些冲突。

具体流程是这样的：

> [!NOTE]
>
> 1. git stash 会将您的本地修改暂时保存起来
> 2. git pull 会拉取远程最新代码
> 3. git stash pop 尝试将您暂存的修改重新应用到更新后的代码上

如果==暂存的修改与拉取的代码修改了相同文件的相同部分，Git会提示冲突，您需要手动选择保留哪些更改==。解决冲突后，需要手动添加并提交这些更改。

```bash
# 暂存当前修改
git stash

# 拉取远程最新代码
git pull

# 恢复暂存的修改（可能会有冲突需要解决）
git stash pop
```

### case3: 撤销已add但未push的提交

**使用git add，git commit的文件，不想push了，怎么撤回**

当你使用 `git reset --soft HEAD~1` 命令后，**只有提交 (commit) 会被撤销**，而不会影响暂存区 (staging area) 和工作目录 (working directory) 中的内容。具体来说：

1. **提交被撤销**：最后一次的 commit 会被移除，HEAD 指针会回退到上一个提交
2. **暂存区保持不变**：之前通过 `git add` 添加到暂存区的文件仍然在暂存区中
3. **工作目录保持不变**：所有修改的文件内容都不会改变

```bash
# 撤销最近的commit，保留修改在暂存区
git reset --soft HEAD~1

# 如果想撤销暂存区的内容
git reset HEAD <file>

# 或者撤销所有暂存区内容
git reset HEAD .
```

#### **与其他模式的对比**

- `git reset --soft`：只撤销提交，保留暂存区和工作目录
- `git reset --mixed`（默认模式）：撤销提交和暂存区，保留工作目录
- `git reset --hard`：撤销提交、暂存区和工作目录，彻底删除所有更改

### case4: 推送到远端分支的注意事项

在执行 `git merge` 操作之前，**总是先进行 `git pull`** 是一个非常好的习惯。这是Git工作流程中的最佳实践。

#### **为什么要先 pull？**

1. **避免复杂冲突**：基于最新代码进行合并可以减少冲突的数量和复杂性
2. **防止重复工作**：确保你不会合并已经被其他人解决的问题
3. **保持历史清晰**：避免创建不必要的"合并的合并"提交
4. **避免推送被拒绝**：如你之前遇到的`non-fast-forward`错误

#### **当你在特性分支上工作时：**

```bash
# 确保当前修改已提交
git add .
git commit -m "你的提交信息"

# 先更新特性分支
git pull origin your-feature-branch

# 然后从main分支合并最新更改
git pull origin main
# 或
git fetch origin
git merge origin/main
```

#### **当你在main分支上工作时：**

```bash
# 切换到main分支
git checkout main

# 更新main到最新版本
git pull origin main

# 然后合并你的特性分支
git merge your-feature-branch
```

> [!NOTE]
>
> - `git pull` 实际上是 `git fetch` + `git merge` 的组合操作
> - 养成定期更新分支的习惯，不仅在合并前，也在开始新工作前
> - 在团队协作中，频繁的小更新比罕见的大合并更容易管理
>
> 遵循这个工作流程会让你的Git体验更顺畅，减少合并冲突和推送问题！

------

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
    - 那么第一次git push就需要==git push --set-upstream origin ddgd/dev==
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
  需快速获取远程分支快照，不影响当前开发进度，或需创建 "只读" 分支用于对比。
- **选 `git checkout -b`**：
  需立即在新分支开发，且希望分支自动与远程关联（尤其适合团队协作场景）。
- **最佳实践**：
  日常开发优先使用 `checkout -b` 系列命令；涉及跨分支对比或历史追溯时，搭配 `fetch` 使用。

**备注**：

- Git 新版本推荐用 `git switch` 替代 `checkout`（如 `git switch -c new_branch origin/dev`），功能等价但语义更清晰。
- 跟踪关系可通过 `git branch --set-upstream-to=origin/dev new_branch` 手动设置。

------

## 八、现代Git工作流程最佳实践

### **🎯 Feature Branch Workflow（特性分支工作流）**

#### **📋 标准开发流程：**

```text
main分支（受保护）    ←── 只接收合并，不直接开发
     ↑
feature/user-auth    ←── 在这里开发新功能
feature/payment      ←── 每个功能独立分支
feature/ui-update    ←── 团队成员各自分支
```

### **🔄 完整工作流程详解**

#### **第1步：创建功能分支开始开发**

```bash
# 从最新的main分支创建功能分支
git checkout main
git pull origin main                    # 确保main是最新的
git checkout -b feature/user-login      # 创建并切换到功能分支

# 在功能分支上开发
# ... 编写代码 ...
git add .
git commit -m "add user login functionality"
git push origin feature/user-login     # 推送到远程
```

#### **第2步：同步main分支的最新更新**

```bash
# 当main分支有其他人的新功能时
git checkout main                       # 切换到main分支
git pull origin main                    # 更新本地main分支

git checkout feature/user-login         # 切换回功能分支
git merge main                          # 将main的更新合并到功能分支
# 或者使用 rebase（保持线性历史）
git rebase main
```

#### **第3步：将功能合并回main分支**

```bash
# 方式一：通过Pull Request（推荐）
git push origin feature/user-login
# 然后在GitHub/GitLab创建PR/MR

# 方式二：直接合并（本地操作）
git checkout main
git pull origin main                    # 确保main最新
git merge feature/user-login            # 合并功能分支
git push origin main                    # 推送到远程main
git branch -d feature/user-login        # 删除本地功能分支
```

### **🌈 工作流程优势**

| 优势             | 说明                              |
| ---------------- | --------------------------------- |
| **🛡️ 保护主分支** | main分支始终保持稳定，可随时发布  |
| **🔄 并行开发**   | 多人可同时开发不同功能，互不干扰  |
| **🎯 功能隔离**   | 每个功能独立开发，便于测试和回滚  |
| **📝 代码审查**   | 通过PR进行代码review，提高质量    |
| **📊 清晰历史**   | Git历史记录清晰，便于追踪功能开发 |

### **💡 最佳实践建议**

1. **🔒 保护main分支** - 设置分支保护规则，要求PR才能合并
2. **🏷️ 命名规范** - 使用 `feature/功能名`、`bugfix/问题描述` 等
3. **📝 定期同步** - 每天开始工作前更新main分支
4. **🧹 清理分支** - 功能合并后及时删除feature分支
5. **💬 代码审查** - 所有代码变更都通过PR进行review

**这套工作流程完全符合现代软件开发的最佳实践！** 🎉 