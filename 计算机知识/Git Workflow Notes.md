# 🌿 Git 基础命令与工作流详解笔记

> 基于实际开发中遇到的分支管理、代码冲突、stash 等问题，详细整理 Git 的工作流程、命令解释与实际应用场景。

------

## 一、Git 常用工作区结构图

```text
工作目录（Working Directory）
       ↓ git add
暂存区（Staging Area）
       ↓ git commit
本地仓库（Local Repository）
       ↓ git push
远程仓库（Remote Repository）
```

还有一个额外的结构：

```text
📃 储藏区（Stash））——用于临时保存环境
```

------

## 二、核心命令对比与解释

| 命令         | 操作对象               | 存放位置          | 用途                 |
| ------------ | ---------------------- | ----------------- | -------------------- |
| `git add`    | 工作目录中**指定修改** | 暂存区（Staging） | 为 `commit` 做准备   |
| `git commit` | 暂存区所有文件         | 本地仓库          | 创建提交记录（快照） |
| `git push`   | 本地提交               | 推送到远程仓库    | 同步共享             |
| `git stash`  | 所有**未提交**的内容   | 储藏区（Stash）   | 临时保存，清空环境   |

------

## 三、实战场景讲解

### ☑️ 场景一：`git pull` 拉代码失败的典型场景

**报错启示：**

```bash
error: Your local changes to the following files would be overwritten by merge:
```

**本质问题：**本地文件有修改，同时远程也发生了修改。Git 为了保护本地未 commit 修改，阻止 pull 操作。

**冲突文件示例：**

```
data_collect_tools/pcar_fps/config.py
...
```

------

## 四、解决方案

### ☑️ 方案一：保留本地修改

```bash
git add .
git commit -m "描述本次修改"
git pull
```

可能会有冲突，需要手动解决。

------

### ☑️ 方案二：临时放下修改，先拉代码

```bash
git stash
git pull
git stash pop
```

可能也会有冲突，需要手动解决。

------

## 五、`git add` vs `git stash`

| 比较点   | `git add`                | `git stash`                          |
| -------- | ------------------------ | ------------------------------------ |
| 操作范围 | 指定文件                 | 所有未提交的修改（工作区 + 暂存区）  |
| 存放位置 | 暂存区（staging/index）  | 储藏区（stash stack）                |
| 用途     | 为下一次 `commit` 做准备 | 临时保存工作环境                     |
| 适用场景 | 正常开发流程中准备提交   | 切换任务、拉取远程代码等临时保存场景 |

------

## 六、`git push` 详解

### 🌟 概念：把本地提交的更改“发布”到远程仓库

```bash
git push origin main
```

解释：

- `origin`：远程仓库名
- `main`：本地分支名

------

## 七、首次推送分支：建立跟踪关系

### 推荐命令：

```bash
git push -u origin zz/dev
```

作用：

- 推送分支
- 建立本地与远程分支的关联

一旦建立，后续可以直接用 `git push`，`git pull`等简单命令。

------

## 八、分支使用小结

| 场景           | 推荐命令                    |
| -------------- | --------------------------- |
| 创建并切换分支 | `git checkout -b zz/dev`    |
| 推送并建立关联 | `git push -u origin zz/dev` |
| 后续推送简写   | `git push`                  |
| 未建立关联时   | `git push origin zz/dev`    |

------

## 九、命令速查总结

| 操作               | 命令                                    |
| ------------------ | --------------------------------------- |
| 添加文件到暂存区   | `git add .` 或 `git add <file>`         |
| 提交代码           | `git commit -m "提交信息"`              |
| 拉取远程代码       | `git pull`                              |
| 推送代码到远程仓库 | `git push` / `git push origin <branch>` |
| 推送并建立跟踪     | `git push -u origin <branch>`           |
| 临时保存工作环境   | `git stash`                             |
| 恢复保存的工作环境 | `git stash pop`                         |
| 查看 stash 列表    | `git stash list`                        |
| 丢弃 stash 修改    | `git stash drop` / `git stash clear`    |

------

## 🔺 总结建议

1. **开发流程建议**：
   - 编写 → `add` → `commit` → `push`
   - 不要在未 commit 状态下频繁切换分支或 pull
2. **stash 场景**：
   - 急需切换任务
   - 远程有更新无法直接 pull
3. **第一次推送分支一定用 `-u`**，后面就省心了。