# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概览

- 这是一个基于 AutoHotkey v2 的 Windows 音量快捷控制工具。
- 主功能：鼠标位于屏幕左上角时，滚轮调节系统音量，中键切换静音。
- 核心实现集中在 `VolumeHotkey.ahk`，CI 发布流程在 `.github/workflows/release.yml`。

## 常用开发命令

> 本仓库没有 Node/Python/Go/Rust 构建系统，也没有现成的 lint/test 脚本。

### 本地运行（开发调试）

```bash
"C:/Program Files/AutoHotkey/v2/AutoHotkey64.exe" "./VolumeHotkey.ahk"
```

如果本机未安装 AutoHotkey，请先安装 AutoHotkey v2（README 要求 v2.0+）。

### 本地编译 EXE（与 CI 一致）

```bash
"C:/Program Files/AutoHotkey/Compiler/Ahk2Exe.exe" /in "VolumeHotkey.ahk" /out "VolumeHotkey.exe"
```

若上述路径不存在，可尝试：

```bash
"C:/Program Files (x86)/AutoHotkey/Compiler/Ahk2Exe.exe" /in "VolumeHotkey.ahk" /out "VolumeHotkey.exe"
```

### 单项验证（替代“单测”）

本项目无自动化测试框架。建议把“单测”理解为单功能手工验证：

1. 启动脚本。
2. 将鼠标移动到屏幕左上角（20x20 热区）。
3. 仅验证一个行为（例如滚轮上滑增大音量）。

## 代码架构（高层）

### 1) 输入门控层（热区判定）

- `IsInTopLeftCorner()`：统一判定是否允许触发热键（左上角热区）。
- 这是“是否响应输入”的第一道门，直接决定热键是否生效。

### 2) 音量控制层（按键驱动）

- `AdjustVolume(direction)`：滚轮事件进入音量系统的统一入口。
- 通过发送系统按键 `{Volume_Up}` / `{Volume_Down}` 调整音量。
- 内置 50ms 防抖，避免滚轮高频触发导致调节过快。

### 3) 交互与生命周期层（托盘 + 首次运行 + 热键绑定）

- `InitTrayMenu()` / `ToggleAutoStart()` / `SetStartup(...)`：托盘菜单和开机启动入口。
- `CheckFirstRun()`：通过检查启动项快捷方式是否存在来决定是否弹出首次询问，符合“无额外配置残留”的设计。
- `#HotIf IsInTopLeftCorner()` 下绑定 `WheelUp/WheelDown/MButton`，将输入层和音量层连接起来。

## CI / 发布流程要点

- 工作流：`.github/workflows/release.yml`
- 触发条件：推送到 `main/master` 或推送 `v*` 标签。
- 发布流水线：
  1. 检出代码并生成发布元数据（日期、标签名、变更记录）。
  2. 在 CI 中安装 AutoHotkey v2 后，使用 Ahk2Exe 编译 `VolumeHotkey.ahk` -> `VolumeHotkey.exe`。
  3. 使用 `softprops/action-gh-release` 上传 `VolumeHotkey.exe` 并创建 Release。
  4. 标签触发时复用触发标签；分支触发时生成唯一标签，避免同名冲突。

## 仓库约定与注意事项

- `.gitignore` 已包含 `.env`、`VolumeHotkey.exe`、常见临时文件和本地 IDE 目录；新增本地产物时按需补充。
- 修改热区逻辑时，优先调整文件顶部全局常量 `CORNER_SIZE`；修改滚轮调节节奏时调整 `AdjustVolume` 中的防抖间隔。