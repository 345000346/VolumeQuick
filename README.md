# VolumeQuick

一个基于 AutoHotkey v2 的 Windows 音量快捷控制工具。

当鼠标位于屏幕左上角热区（默认 `20x20`）时：
- `WheelUp` / `WheelDown` 调整系统音量（仅热区内生效，不透传到前台应用）
- `MButton` 切换静音（仅热区内生效，不透传到前台应用）

## 功能特性

- 左上角热区触发（默认 `20x20`）
- 滚轮调节系统音量（仅热区内生效）
- 中键切换静音（仅热区内生效）
- 托盘菜单支持开机启动切换与退出
- 常驻后台，低资源占用

## 环境要求

- Windows 10 / 11
- 运行 `VolumeHotkey.exe`：无需本地安装 AutoHotkey
- 运行 `VolumeHotkey.ahk`：需要 AutoHotkey v2.0+

## 安装与使用

### 方式一：使用 Release 二进制（推荐）

1. 打开 [Releases](../../releases) 页面。
2. 下载：
   - `VolumeHotkey.exe`
   - `VolumeHotkey.sha256`
3. 在 Windows PowerShell 中校验：

```powershell
Get-FileHash .\VolumeHotkey.exe -Algorithm SHA256
Get-Content .\VolumeHotkey.sha256
```

4. 确认两处 SHA256 一致后运行 `VolumeHotkey.exe`。

### 方式二：运行源码脚本

安装 AutoHotkey v2 后执行：

```bash
"C:/Program Files/AutoHotkey/v2/AutoHotkey64.exe" "./VolumeHotkey.ahk"
```

## 配置项（可选）

在 `VolumeHotkey.ahk` 中可调整：

- `CORNER_SIZE`：热区大小（默认 `20`）
- `CORNER_CHECK_CACHE_MS`：热区判定缓存（默认 `20ms`）
- `VOLUME_ADJUST_DEBOUNCE_MS`：滚轮防抖（默认 `50ms`）

## 开发与构建

### 本地编译 EXE

```bash
"C:/Program Files/AutoHotkey/Compiler/Ahk2Exe.exe" /in "VolumeHotkey.ahk" /out "VolumeHotkey.exe"
```

备用路径：

```bash
"C:/Program Files (x86)/AutoHotkey/Compiler/Ahk2Exe.exe" /in "VolumeHotkey.ahk" /out "VolumeHotkey.exe"
```

## 测试与验证

本项目当前无自动化单元测试，采用手工验证：

1. 启动脚本或 EXE。
2. 鼠标移动到左上角热区。
3. 验证滚轮上/下可调节音量。
4. 验证中键可切换静音。
5. 确认热区触发时前台应用不会收到滚轮/中键事件。

## CI 与发布

发布工作流：`.github/workflows/release.yml`

- 触发条件：推送 `v*` 标签（例如 `v1.2.0`）
- 发布产物：
  - `VolumeHotkey.exe`
  - `VolumeHotkey.sha256`

## 贡献指南

欢迎提交 Issue 和 Pull Request。

## 许可证

本项目采用 MIT License，详见 [LICENSE](LICENSE)。
