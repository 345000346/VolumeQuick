# AGENT.md

AI 编码助手在本仓库中工作时遵循的指引。

## 项目原则

- **轻量绿色免安装**：不写注册表；除用户主动开启开机启动时创建启动快捷方式外，不产生配置文件

## 项目概览

- **VolumeQuick** — 基于 AutoHotkey v2 的 Windows 音量快捷控制工具
- 鼠标位于屏幕左上角热区（默认 `20×20` 像素）时：
  - `WheelUp` / `WheelDown` — 调整系统音量
  - `MButton` — 切换静音
- 热键仅在热区内触发，不透传到前台应用
- 常驻后台托盘，支持开机自启动切换

## 文件结构

```
.
├── VolumeHotkey.ahk          # 唯一源文件（~100 行）
├── AGENT.md                  # 本文件
├── README.md                 # 用户文档
├── LICENSE                   # MIT
└── .gitignore
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
| `CORNER_CHECK_CACHE_MS` | `20` | 热区判定缓存窗口（ms） |
| `VOLUME_ADJUST_DEBOUNCE_MS` | `50` | 滚轮防抖（ms） |
| `STARTUP_LINK_NAME` | `RegExReplace(A_ScriptName, …)` | 从脚本名派生快捷方式名 |
| `STARTUP_PATH` | `A_Startup + link name` | 开机启动快捷方式完整路径 |

### 启动流程

```
#Requires → #SingleInstance → 常量定义 → SetWorkingDir
    → CheckFirstRun() → InitTrayMenu() → 热键注册 → 消息循环
```

- `CheckFirstRun()` — 通过启动目录快捷方式判首次运行，弹窗引导自启动（不写注册表）
- `InitTrayMenu()` — 构建托盘菜单（开机启动开关 + 退出）；若存在 `icon.ico` 则设置托盘图标
- `ToggleAutoStart()` / `SetStartup()` — 创建/删除 `%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\*.lnk`

### 输入门控

- `IsInTopLeftCorner()` — 统一门控，通过 `#HotIf` 绑定
- `static lastCheck` + `static lastResult` — `20ms` 坐标查询缓存

### 音量控制

- `AdjustVolume(direction)` — 发送 `{Volume_Up}` / `{Volume_Down}`
- `static lastAdjust` — `50ms` 防抖，防止滚轮高速触发时堆积

### 热键绑定

```
#UseHook true                ; 强制键盘/鼠标钩子
#HotIf IsInTopLeftCorner()   ; 仅热区生效
WheelUp::AdjustVolume("up")
WheelDown::AdjustVolume("down")
MButton::Send "{Volume_Mute}"
#HotIf
```


