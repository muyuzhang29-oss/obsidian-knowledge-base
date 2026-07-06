---
aliases: [Git同步配置指南, Obsidian Git同步, Git同步]
tags: [Environment, Git, Obsidian, Sync]
created: 2026-06-04
updated: 2026-06-10
---

# Git同步配置指南

## 概述

本文档介绍如何在Windows和iPad上配置Obsidian Git同步功能。

---

## 一、Windows配置步骤

### 1. 安装Git

1. 访问 https://git-scm.com/download/win
2. 下载Windows版本的Git安装程序
3. 运行安装程序，使用默认选项即可
4. 安装完成后，打开PowerShell或命令提示符，输入 `git --version` 验证安装

### 2. 配置Git用户信息

```powershell
git config --global user.name "你的用户名"
git config --global user.email "你的邮箱@example.com"
```

### 3. 克隆仓库

```powershell
cd D:\obsidian
git clone https://github.com/muyuzhang29-oss/obsidian-knowledge-base.git knowledge-base
```

### 4. 安装Obsidian Git插件

1. 打开Obsidian
2. 进入 设置 → 第三方插件 → 浏览
3. 搜索 "Git" 并安装 "Obsidian Git" 插件
4. 启用插件

### 5. 配置插件

插件配置文件位于 `.obsidian/plugins/obsidian-git/data.json`，主要配置项：

- **自动同步间隔**: 5分钟（300秒）
- **自动pull**: 启用
- **自动push**: 启用
- **提交信息模板**: `vault backup: {{date}}`

---

## 二、iPad配置步骤

### 1. 安装Working Copy

1. 在App Store搜索 "Working Copy"
2. 下载并安装（需要付费解锁推送功能）

### 2. 克隆仓库

1. 打开Working Copy
2. 点击右上角 "+" 按钮
3. 选择 "Clone Repository"
4. 输入仓库地址：`https://github.com/muyuzhang29-oss/obsidian-knowledge-base.git`
5. 选择克隆位置

### 3. 配置Obsidian

1. 打开Obsidian
2. 打开仓库所在的文件夹
3. 安装并启用Obsidian Git插件
4. 配置自动同步

### 4. 同步流程

在iPad上，需要手动触发同步：

1. 在Obsidian中使用命令面板（Ctrl/Cmd + P）
2. 输入 "Git: Pull" 拉取最新更改
3. 编辑完成后，输入 "Git: Commit all" 提交更改
4. 输入 "Git: Push" 推送到GitHub

---

## 三、常见问题解答

### Q1: 提示 "Permission denied" 怎么办？

**A**: 需要配置SSH密钥或使用个人访问令牌（PAT）。

使用HTTPS + PAT方式：
1. 访问 GitHub → Settings → Developer settings → Personal access tokens
2. 生成新令牌，勾选 `repo` 权限
3. 在推送时使用令牌作为密码

### Q2: 如何解决合并冲突？

**A**: 
1. 打开有冲突的文件
2. 找到 `<<<<<<<` 和 `>>>>>>>` 标记
3. 手动选择要保留的内容
4. 删除冲突标记
5. 提交更改

### Q3: 同步速度很慢怎么办？

**A**:
- 检查网络连接
- 减少大型二进制文件（图片、PDF等）
- 使用 `.gitignore` 排除不需要同步的文件

### Q4: 如何查看同步历史？

**A**: 
- 在Obsidian中使用命令 "Git: View history"
- 或在命令行执行 `git log --oneline`

### Q5: 误删了文件怎么办？

**A**:
```powershell
git checkout -- 文件名  # 恢复单个文件
git checkout .  # 恢复所有文件
```

---

## 四、日常使用说明

### 推荐工作流程

1. **开始工作前**: 先拉取最新更改
   - Obsidian命令: `Git: Pull`
   - 命令行: `git pull`

2. **工作过程中**: 定期提交（建议每完成一个主题就提交）
   - Obsidian命令: `Git: Commit all`
   - 命令行: `git add . && git commit -m "描述"`

3. **工作结束后**: 推送到远程仓库
   - Obsidian命令: `Git: Push`
   - 命令行: `git push`

### 快捷键设置

建议在Obsidian中为常用Git操作设置快捷键：

1. 进入 设置 → 快捷键
2. 搜索 "Git"
3. 为以下命令设置快捷键：
   - Git: Pull → `Ctrl+Shift+P`
   - Git: Commit all → `Ctrl+Shift+C`
   - Git: Push → `Ctrl+Shift+U`

---

## 五、配置文件参考

### .gitignore 文件内容

```
# Obsidian工作区文件
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/workspace

# 系统文件
desktop.ini
Thumbs.db
.DS_Store

# 临时文件
*.tmp
*.bak
*.swp
```

### Obsidian Git 插件配置

文件位置：`.obsidian/plugins/obsidian-git/data.json`

```json
{
  "autoSaveInterval": 300,
  "autoPullInterval": 300,
  "autoPullOnBoot": true,
  "autoCommitMessage": "vault backup: {{date}}",
  "autoCommitOnFileChange": false,
  "syncOnSave": false
}
```

---

*最后更新: 2026-06-02*
