# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概览

- 基于 AutoHotkey v2 的 Windows 音量快捷控制工具。
- 鼠标位于左上角热区（默认 `20x20`）时：
  - `WheelUp` / `WheelDown` 调整系统音量
  - `MButton` 切换静音
- 核心代码：`VolumeHotkey.ahk`
- 发布流程：`.github/workflows/release.yml`

## 常用命令

> 本仓库无 Node/Python/Go/Rust 构建系统，无 lint 与自动化测试脚本。

### 本地运行

```bash
"C:/Program Files/AutoHotkey/v2/AutoHotkey64.exe" "./VolumeHotkey.ahk"
```

### 本地编译

```bash
"C:/Program Files/AutoHotkey/Compiler/Ahk2Exe.exe" /in "VolumeHotkey.ahk" /out "VolumeHotkey.exe"
```

备用路径：

```bash
"C:/Program Files (x86)/AutoHotkey/Compiler/Ahk2Exe.exe" /in "VolumeHotkey.ahk" /out "VolumeHotkey.exe"
```

### 单项手工验证（替代单测）

1. 启动脚本或 EXE。
2. 鼠标移到左上角热区。
3. 每次只验证一个行为（`WheelUp` / `WheelDown` / `MButton`）。

### Release 产物校验

```powershell
Get-FileHash .\VolumeHotkey.exe -Algorithm SHA256
Get-Content .\VolumeHotkey.sha256
```

## 高层架构

### 启动与生命周期

- 启动后执行：`CoordMode("Mouse", "Screen")` -> `MigrateLegacyStartupIfNeeded()` -> `CheckFirstRun()` -> `InitTrayMenu()`。
- `MigrateLegacyStartupIfNeeded()`：仅在 legacy-only 场景迁移旧启动快捷方式（`VolumeHotkey.lnk`）到脚本名快捷方式。
- `CheckFirstRun()`：通过启动目录快捷方式判断首次运行，并可引导开启自启动。
- `InitTrayMenu()` / `ToggleAutoStart()` / `SetStartup()`：托盘菜单与开机启动控制。

### 输入门控

- `IsInTopLeftCorner()` 是统一门控函数。
- 通过 `#HotIf IsInTopLeftCorner()` 约束相关热键仅在热区生效。
- 内含 `20ms` 判定缓存，减少频繁坐标查询开销。

### 音量动作

- `AdjustVolume(direction)` 统一处理滚轮音量调节。
- 通过发送 `{Volume_Up}` / `{Volume_Down}` 控制系统音量。
- 内含 `50ms` 防抖。

### 热键绑定

- `WheelUp::AdjustVolume("up")`
- `WheelDown::AdjustVolume("down")`
- `MButton::Send "{Volume_Mute}"`
- 均在 `#HotIf IsInTopLeftCorner()` 作用域中。

## CI / 发布要点

- 工作流：`Release`
- 触发：仅 `push tags: v*`
- 流程：
  1. 下载并校验 AutoHotkey ZIP（固定版本 + SHA256 + 重试）
  2. 下载并校验 Ahk2Exe ZIP（固定版本 + SHA256 + 重试）
  3. 编译 `VolumeHotkey.ahk` -> `VolumeHotkey.exe`
  4. 编译步骤包含最多 `10 x 500ms` 的输出文件轮询等待，避免 Ahk2Exe 落盘时序导致“未生成输出文件”误报
  5. 生成 `VolumeHotkey.sha256`
  6. 上传 `VolumeHotkey.exe` 与 `VolumeHotkey.sha256` 到 GitHub Release

## 修改落点

- 热区大小：`CORNER_SIZE`
- 热区判定缓存窗口：`IsInTopLeftCorner()` 内 `20ms`
- 滚轮防抖：`AdjustVolume()` 内 `50ms`

## Claude Code 协作提示

- `find . -name "CLAUDE.md" -o -name ".claude.local.md" 2>/dev/null | head -20` - 快速定位仓库/本地 Claude 指令文件（本仓库当前仅有 `./CLAUDE.md`）。
- `并行调用 Glob/Read` - 多模式搜索与多文件读取建议并发执行，可减少 hooks 提示并提升分析速度。

## 规则文件检查结论

- 未发现 `.cursor/rules/`、`.cursorrules`、`.github/copilot-instructions.md`。