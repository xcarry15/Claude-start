# Claude Project Launcher

<div align="center">

![Claude Logo](https://img.shields.io/badge/Claude-Code-black?style=for-the-badge&logo=anthropic)
![Windows](https://img.shields.io/badge/Windows-11-00A4EF?style=for-the-badge&logo=windows)
![Batch](https://img.shields.io/badge/Batch-Script-4D4D4D?style=for-the-badge)

**一个高效的 Claude Code 项目启动器，支持项目搜索、最近使用和快速恢复**

[English](README_EN.md) | 简体中文

</div>

---

## ✨ 特性

### 🚀 极速启动
- 输入项目名关键字，0.1秒定位目标项目
- 无需记住项目编号，输入即搜索

### 📂 多级目录支持
- 支持任意深度的子目录导航
- 自动检测并列出所有子目录

### 📊 使用统计
- 自动记录项目使用频率
- 启动器显示最近使用的项目
- 一键恢复上次工作目录

### ⚡ 快速恢复
- 直接回车启动上次项目
- 按 `R` 恢复上一次 Claude 会话
- 退出后下次打开自动定位到上次位置

---

## 🎬 演示

```
========================================
  Claude Project Launcher
========================================

最近使用:
  [0]  T-2026.tstwg.cn-进度追踪看板

----------------------------------------
  [Enter] 启动上次项目  [R] 恢复会话  [00] 退出
----------------------------------------
   [1]  A-api.tstwg.cn
   [2]  C-lat.tstwg.cn-经纬度计算工具
   [3]  C-map.tstwg.cn-地图可视化
   ...

选择项目编号或输入关键字搜索: 地图
搜索 "地图" 的结果:
   [1]  C-map.tstwg.cn-地图可视化
   [0]  取消
选择编号(Enter=0): 1

当前: D:\...\C-map.tstwg.cn-地图可视化

子目录:
   [0]  使用当前目录
   [B]  返回上级
   [1]  src
   [2]  dist
选择编号(Enter=0): 0

启动目录:
   D:\...\C-map.tstwg.cn-地图可视化

✓ 正在启动 Claude Code...
```

---

## 📥 安装

### 方式一：下载即用（推荐）

1. 下载 [`start-claude.bat`](start-claude.bat) 文件
2. 双击运行

### 方式二：克隆仓库

```bash
git clone https://github.com/yourusername/claude-project-launcher.git
cd claude-project-launcher
start-claude.bat
```

---

## 🔧 配置

### 修改项目根目录

编辑 `start-claude.bat` 第 7 行：

```batch
set "ROOT_DIR=D:\你的项目目录"
```

### 默认项目扫描规则

只扫描以**英文字母 + 连字符**开头的目录：

| 前缀 | 用途 |
|------|------|
| `A-xxx` | API 相关项目 |
| `C-xxx` | 坐标/地图工具 |
| `D-xxx` | 数据分析 |
| `G-xxx` | 高德 POI |
| `P-xxx` | 行政区划数据 |
| `S-xxx` | 统计分析 |
| `T-xxx` | 业务工具 |
| `Y-xxx` | Excel 处理 |
| `Z-xxx` | 系统配置 |

> 目录名示例：`T-2026.tstwg.cn-进度追踪看板`

---

## ⌨️ 操作指南

| 操作 | 说明 |
|------|------|
| 直接回车 | 启动上次项目 |
| 输入数字 | 选择对应项目 |
| 输入关键字 | 模糊搜索匹配项目 |
| 按 `R` | 恢复上次会话 |
| 按 `00` | 退出启动器 |

---

## 🔄 工作流程

```
┌─────────────────────────────────────┐
│      Claude Project Launcher        │
└─────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│   显示最近使用 + 项目列表            │
└─────────────────────────────────────┘
                │
                ▼
    ┌───────────┴───────────┐
    │                       │
    ▼                       ▼
 输入关键字               输入数字
    │                       │
    ▼                       ▼
 模糊搜索匹配           进入项目目录
    │                       │
    └───────────┬───────────┘
                ▼
┌─────────────────────────────────────┐
│      多级子目录导航（如有）          │
└─────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│   claude --dangerously-skip-        │
│          permissions <path>         │
└─────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│       启动 Claude Code！            │
└─────────────────────────────────────┘
```

---

## 🆚 对比

| 功能 | 本工具 | 原生方式 |
|------|--------|----------|
| 启动速度 | 1-2 次按键 | 5-10 次按键 |
| 项目搜索 | ✅ 输入即搜 | ❌ 需要记住路径 |
| 最近使用 | ✅ 自动记录 | ❌ 手动 cd |
| 多级目录 | ✅ 支持 | ❌ 需手动 cd |

---

## 📁 项目结构

```
Z-Claude/
├── 1-Start/
│   ├── start-claude.bat      # 主启动脚本
│   ├── last_project.txt      # 上次项目记录
│   ├── project_stats.txt     # 使用统计
│   └── README.md             # 本文件
└── CLAUDE.md                  # Claude Code 开发指南
```

---

## ⚠️ 依赖

- Windows 10/11
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 已安装并可在 PATH 中调用
- PowerShell 或 CMD

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing`)
5. 创建 Pull Request

---

## 📜 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## ⭐ 如果喜欢

如果这个项目对你有帮助，请给我一个 Star！

[![Star](https://img.shields.io/github/stars/yourusername/claude-project-launcher?style=social)](https://github.com/yourusername/claude-project-launcher)

---

<div align="center">

**用 Claude Code 高效工作，从这里开始 🚀**

</div>
