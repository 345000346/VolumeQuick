# VolumeQuick

一个基于 AutoHotkey v2 的 Windows 音量快捷控制工具，免安装、轻量绿色。

当鼠标位于屏幕左上角热区（默认 `20x20`）时：
- `WheelUp` / `WheelDown` 调整系统音量（仅热区内生效，不透传到前台应用）
- `MButton` 切换静音（仅热区内生效，不透传到前台应用）

## 功能特性

- 左上角热区触发（默认 `20x20`）
- 滚轮调节系统音量（仅热区内生效）
- 中键切换静音（仅热区内生效）
- 托盘菜单支持开机启动切换与退出
- 常驻后台，低资源占用
- 轻量绿色：不写注册表；除用户主动开启开机启动时创建启动快捷方式外，不产生配置文件

## 环境要求

- Windows 10 / 11
- [AutoHotkey v2.0+](https://www.autohotkey.com/download/)

## 安装与使用

请先安装 [AutoHotkey v2.0+](https://www.autohotkey.com/download/)。

1. 点击仓库中的 [`VolumeHotkey.ahk`](VolumeHotkey.ahk) 文件。
2. 点击右上角 **Download raw file**（下载原始文件）按钮；如果只看到 **Raw**，可点击后在浏览器中右键另存为 `VolumeHotkey.ahk`。
3. 请确认下载后的文件名后缀为 `.ahk`。
4. 双击下载的 `VolumeHotkey.ahk` 即可运行。

## 配置项（可选）

在 `VolumeHotkey.ahk` 中可调整：

- `CORNER_SIZE`：热区大小（默认 `20`）
- `CORNER_CHECK_CACHE_MS`：热区判定缓存（默认 `20ms`）
- `VOLUME_ADJUST_DEBOUNCE_MS`：滚轮防抖（默认 `50ms`）

## 测试与验证

本项目当前无自动化单元测试，采用手工验证：

1. 双击运行 `VolumeHotkey.ahk`。
2. 鼠标移动到左上角热区。
3. 验证滚轮上/下可调节音量。
4. 验证中键可切换静音。
5. 确认热区触发时前台应用不会收到滚轮/中键事件。

## 贡献指南

欢迎提交 Issue 和 Pull Request。

## 许可证

本项目采用 MIT License，详见 [LICENSE](LICENSE)。
