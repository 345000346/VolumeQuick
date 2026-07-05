#Requires AutoHotkey v2.0
#SingleInstance Force

; =============== 全局常量 ===============
CORNER_SIZE := 20  ; 左上角热区大小（像素）
CORNER_CHECK_CACHE_MS := 20
VOLUME_ADJUST_DEBOUNCE_MS := 50
STARTUP_LINK_NAME := RegExReplace(A_ScriptName, "\.[^.]+$") ".lnk"
STARTUP_PATH := A_Startup "\" STARTUP_LINK_NAME

; =============== 性能优化设置 ===============
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Screen"

; =============== 首次运行处理 ===============
IsStartupEnabled() {
    return FileExist(STARTUP_PATH)
}

CheckFirstRun() {
    if !IsStartupEnabled() {
        result := MsgBox("是否希望开机时自动启动音量控制工具？`n`n选择“是”会在系统启动目录创建一个快捷方式；不会写入注册表。", "开机启动设置", "36")
        if (result = "Yes")
            SetStartup(true)
    }
}

SetStartup(enable := true) {
    try {
        if (enable) {
            if !FileExist(STARTUP_PATH)
                FileCreateShortcut(A_ScriptFullPath, STARTUP_PATH, A_ScriptDir,, "音量控制快捷键工具", A_AhkPath)
            return true
        } else {
            if FileExist(STARTUP_PATH)
                FileDelete(STARTUP_PATH)
            return true
        }
    } catch as err {
        MsgBox("设置开机启动失败: " err.Message, "错误", "16 T2")
        return false
    }
}

; =============== 系统托盘设置 ===============
InitTrayMenu() {
    TrayMenu := A_TrayMenu
    TrayMenu.Delete()

    TrayMenu.Add("开机启动", ToggleAutoStart)
    if IsStartupEnabled()
        TrayMenu.Check("开机启动")

    TrayMenu.Add()
    TrayMenu.Add("退出", (*) => ExitApp())

    if FileExist(A_ScriptDir "\icon.ico")
        TraySetIcon(A_ScriptDir "\icon.ico")
}

ToggleAutoStart(ItemName, ItemPos, Menu) {
    if !IsStartupEnabled() {
        if SetStartup(true)
            Menu.Check(ItemName)
    } else {
        if SetStartup(false)
            Menu.Uncheck(ItemName)
    }
}

; =============== 核心功能函数 ===============
IsInTopLeftCorner() {
    static lastCheck := 0
    static lastResult := false
    if (A_TickCount - lastCheck < CORNER_CHECK_CACHE_MS)
        return lastResult

    MouseGetPos(&mouseX, &mouseY)
    lastCheck := A_TickCount
    lastResult := (mouseX >= 0 && mouseX < CORNER_SIZE && mouseY >= 0 && mouseY < CORNER_SIZE)
    return lastResult
}

AdjustVolume(direction) {
    static lastAdjust := 0
    if (A_TickCount - lastAdjust < VOLUME_ADJUST_DEBOUNCE_MS)
        return
    
    if (direction = "up")
        Send "{Volume_Up}"
    else if (direction = "down")
        Send "{Volume_Down}"
    
    lastAdjust := A_TickCount
}

; =============== 初始化 ===============
CheckFirstRun()  ; 检查首次运行
InitTrayMenu()

; =============== 热键绑定 ===============
#UseHook true
#HotIf IsInTopLeftCorner()
WheelUp::AdjustVolume("up")      ; 滚轮上 - 增加音量
WheelDown::AdjustVolume("down")  ; 滚轮下 - 降低音量
MButton::Send "{Volume_Mute}"    ; 中键 - 静音切换
#HotIf
