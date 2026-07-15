# VolumeQuick

一个基于 AutoHotkey v2 的 Windows 音量快捷控制工具，单文件、免安装、轻量绿色。

当鼠标位于**当前显示器**左上角热区（默认 `20x20`）时：
- `WheelUp` / `WheelDown` 调整系统音量（仅热区内生效，不透传到前台应用）
- `MButton` 切换静音（仅热区内生效，不透传到前台应用）

## 功能特性

- 当前显示器左上角热区触发（默认 `20x20`，多屏下各屏均可用）
- 滚轮调节系统音量（仅热区内生效）
- 中键切换静音（仅热区内生效）
- 托盘菜单支持开机启动切换与退出
- 常驻后台，低资源占用
- 单文件；不写注册表、不写配置文件；**唯一允许的写入**是用户开启开机启动时在启动文件夹创建/删除快捷方式

## 环境要求

- Windows 10 / 11
- [AutoHotkey v2.0+](https://www.autohotkey.com/download/)

## 安装与使用

请先安装 [AutoHotkey v2.0+](https://www.autohotkey.com/download/)。

1. 点击仓库中的 [`VolumeHotkey.ahk`](VolumeHotkey.ahk) 文件。
2. 点击右上角 **Download raw file**（下载原始文件）按钮；如果只看到 **Raw**，可点击后在浏览器中右键另存为 `VolumeHotkey.ahk`。
3. 请确认下载后的文件名后缀为 `.ahk`。
4. 双击下载的 `VolumeHotkey.ahk` 即可运行。

首次运行若未开启开机启动，会询问是否创建启动快捷方式；也可随时在托盘菜单中切换「开机启动」。

## 配置项（可选）

在 `VolumeHotkey.ahk` 中可调整：

- `CORNER_SIZE`：热区大小（默认 `20`）

## 测试与验证

本项目当前无自动化单元测试，采用手工验证：

1. 双击运行 `VolumeHotkey.ahk`。
2. 鼠标移动到当前显示器左上角热区。
3. 验证滚轮上/下可调节音量。
4. 验证中键可切换静音。
5. 确认热区触发时前台应用不会收到滚轮/中键事件。
6. 多屏环境下，在副屏左上角同样验证 3–5。

## 贡献指南

欢迎提交 Issue 和 Pull Request。

## 许可证

本项目采用 MIT License，详见 [LICENSE](LICENSE)。
