# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 功能

这是一个 Claude 项目快速启动器，通过交互式菜单选择 `D:\0_系统文件夹\桌面\web` 下的项目并启动 Claude Code。

## 核心文件

- `start-claude.bat` - 主启动脚本（Windows Batch）
- `last_project.txt` - 记录上次启动的目录路径

## 启动流程

1. 扫描 `D:\0_系统文件夹\桌面\web` 下以"英文-"开头的目录作为项目列表
2. 支持多级子目录导航（进入子文件夹或返回上级）
3. 选择后保存路径到 `last_project.txt`
4. 执行 `claude --dangerously-skip-permissions <path>` 启动

## 快捷操作

- 输入编号 - 选择对应项目
- 按 `R` - 打开上次项目（从 last_project.txt 读取）
- 按 `00` - 退出

## 修改说明

如需添加新项目，直接在 `D:\0_系统文件夹\桌面\web` 下创建以"英文-"开头的目录即可自动识别。
