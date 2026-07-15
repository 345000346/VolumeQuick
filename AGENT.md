# AGENT.md

AI 编码助手在本仓库中工作时遵循的指引。

## 项目原则

- **单文件、轻量绿色免安装**
- **不写注册表、不写配置文件**
- **唯一允许的写入**：用户开启开机启动时，在启动文件夹创建/删除快捷方式

## 项目概览

- **VolumeQuick** — 基于 AutoHotkey v2 的 Windows 音量快捷控制工具
- 鼠标位于**当前显示器**左上角热区（默认 `20×20` 像素）时：
  - `WheelUp` / `WheelDown` — 调整系统音量
  - `MButton` — 切换静音
- 热键仅在热区内触发，不透传到前台应用
- 多屏下每块显示器的左上角均可触发
- 常驻后台托盘，支持开机自启动切换

## 文件结构

```
.
├── VolumeHotkey.ahk          # 唯一源文件
├── AGENT.md                  # 本文件
├── README.md                 # 用户文档
└── LICENSE                   # MIT
```

## 常用命令

> 无构建系统，无 lint，无自动化测试。

### 本地运行

```bash
"C:/Program Files/AutoHotkey/v2/AutoHotkey64.exe" "./VolumeHotkey.ahk"
```

或直接双击 `VolumeHotkey.ahk`。

## 架构

### 全局常量

| 常量 | 默认值 | 说明 |
|------|--------|------|
| `CORNER_SIZE` | `20` | 热区大小（像素） |
| `STARTUP_LINK_NAME` | `RegExReplace(A_ScriptName, …)` | 从脚本名派生快捷方式名 |
| `STARTUP_PATH` | `A_Startup + link name` | 开机启动快捷方式完整路径 |

### 启动流程

```
#Requires → #SingleInstance → 常量定义 → SetWorkingDir
    → CheckFirstRun() → InitTrayMenu() → 热键注册 → 消息循环
```

- `CheckFirstRun()` — 若未开启自启则弹窗引导（不写注册表；点「是」才创建 Startup 快捷方式）
- `InitTrayMenu()` — 托盘菜单（开机启动开关 + 退出）；若存在 `icon.ico` 则设置托盘图标
- `ToggleAutoStart()` / `SetStartup()` — 创建/删除 `%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\*.lnk`

### 输入门控

- `IsInHotCorner()` — 统一门控，通过 `#HotIf` 绑定
- 用 `MonitorGet` 定位鼠标所在显示器，判定是否在该屏左上角 `CORNER_SIZE` 内

### 音量控制

- 热键直接 `Send` 系统媒体键：`{Volume_Up}` / `{Volume_Down}` / `{Volume_Mute}`

### 热键绑定

```
#UseHook true              ; 强制键盘/鼠标钩子
#HotIf IsInHotCorner()     ; 仅热区生效
WheelUp::Send "{Volume_Up}"
WheelDown::Send "{Volume_Down}"
MButton::Send "{Volume_Mute}"
#HotIf
```
