# VolumeQuick

一个基于 AutoHotkey v2 的 Windows 音量快捷控制工具。

当鼠标位于屏幕左上角热区时：
- 滚轮上/下滚动可增减系统音量（仅热区内生效，不透传到前台应用）
- 鼠标中键可切换静音状态（仅热区内生效，不透传到前台应用）

## 目录

- [功能特性](#功能特性)
- [系统要求](#系统要求)
- [安装与使用](#安装与使用)
- [下载完整性校验](#下载完整性校验)
- [开发指南](#开发指南)
- [CI 与发布](#ci-与发布)
- [常见问题与排查](#常见问题与排查)
- [贡献指南](#贡献指南)
- [许可证](#许可证)

## 功能特性

- 左上角热区触发（默认 20x20）
- 鼠标滚轮调节系统音量（仅热区内生效，不透传到前台应用）
- 鼠标中键静音/取消静音（仅热区内生效，不透传到前台应用）
- 托盘菜单管理运行状态与开机启动
- 常驻后台，低资源占用

## 系统要求

- Windows 10 / 11
- AutoHotkey v2.0 或更高版本
- 普通用户权限即可运行

## 安装与使用

### 方式一：使用 Release 二进制（推荐）

1. 打开 [Releases](../../releases) 页面。
2. 下载以下文件：
   - `VolumeHotkey.exe`
   - `VolumeHotkey.sha256`
3. 完成哈希校验后运行 `VolumeHotkey.exe`。

### 方式二：运行源码脚本

确保已安装 AutoHotkey v2 后，执行：

```bash
"C:/Program Files/AutoHotkey/v2/AutoHotkey64.exe" "./VolumeHotkey.ahk"
```

## 下载完整性校验

在 Windows PowerShell 中执行：

```powershell
Get-FileHash .\VolumeHotkey.exe -Algorithm SHA256
Get-Content .\VolumeHotkey.sha256
```

确认两处 SHA256 值一致后再运行程序。

## 开发指南

### 本地编译 EXE

```bash
"C:/Program Files/AutoHotkey/Compiler/Ahk2Exe.exe" /in "VolumeHotkey.ahk" /out "VolumeHotkey.exe"
```

若上述路径不存在，可尝试：

```bash
"C:/Program Files (x86)/AutoHotkey/Compiler/Ahk2Exe.exe" /in "VolumeHotkey.ahk" /out "VolumeHotkey.exe"
```

### 手工验证建议

本项目无自动化单元测试框架，建议按单功能进行手工验证：

1. 启动脚本或 EXE。
2. 将鼠标移动到屏幕左上角热区。
3. 分别验证：
   - 滚轮上滑增大音量
   - 滚轮下滑减小音量
   - 中键切换静音
4. 在热区内触发上述操作时，确认前台应用不会收到滚轮/中键事件。

### 升级兼容验证矩阵

围绕旧名（legacy）与新名（new）并存/迁移行为，建议补充以下四场景验证：

| 场景 | 前置态 | 操作 | 期望文件态 | 期望托盘态 | 是否阻断提示 |
| --- | --- | --- | --- | --- | --- |
| 仅旧名（legacy-only） | 仅存在旧名文件，不存在新名文件 | 启动脚本或 EXE，触发一次初始化/迁移流程 | 可迁移时仅保留新名；迁移失败时允许保持 legacy-only | 托盘可正常显示，菜单可操作 | 否（不阻断） |
| 仅新名（new-only） | 仅存在新名文件，不存在旧名文件 | 启动脚本或 EXE，触发初始化检查 | 保持 new-only，不回退生成旧名 | 托盘可正常显示，菜单可操作 | 否（不阻断） |
| 并存（both） | 旧名与新名文件同时存在 | 启动脚本或 EXE，触发初始化检查 | 允许保持并存，或按策略收敛到新名（不影响运行） | 托盘可正常显示，菜单可操作 | 否（不阻断） |
| 均不存在（none） | 旧名与新名文件都不存在 | 启动脚本或 EXE，触发初始化检查 | 按当前逻辑创建目标文件态（通常为新名） | 托盘可正常显示，菜单可操作 | 否（不阻断） |

迁移失败回退可观测说明：

- 迁移异常不应阻断主流程，程序应继续运行并保持可交互托盘。
- 回退后文件态可保持 `legacy-only` 或 `both`，属于可接受结果。
- 主功能（左上角热区音量调节与中键静音）应保持不受影响。

## CI 与发布

发布工作流文件：`.github/workflows/release.yml`

- 触发条件：推送 `v*` 标签（示例：`v1.2.0`）
- 固定版本来源下载 AutoHotkey 与 Ahk2Exe
- 下载文件执行 SHA256 校验
- 下载失败/校验失败自动重试 3 次
- 构建后发布以下产物：
  - `VolumeHotkey.exe`
  - `VolumeHotkey.sha256`

## 常见问题与排查

- AutoHotkey 下载失败或哈希不匹配：
  - 查看工作流日志中的下载地址和预期哈希；
  - 确认网络可访问上游资源后重试。

- Ahk2Exe 下载失败或哈希不匹配：
  - 多为网络波动或文件损坏；
  - 重新运行 workflow 并观察下载步骤日志。

- Ahk2Exe 解压后未找到 `Ahk2Exe.exe`：
  - 通常为压缩包损坏；
  - 重新触发工作流即可恢复。

- 编译后未生成 `VolumeHotkey.exe`：
  - 检查 `VolumeHotkey.ahk` 语法；
  - 检查 AutoHotkey 基础可执行文件路径是否存在。

## 贡献指南

欢迎提交 Issue 和 Pull Request。

在提交前建议：
- 保持改动聚焦，避免无关重构
- 提供必要的复现与验证步骤

## 许可证

本项目采用 MIT License，详见 [LICENSE](LICENSE)。
