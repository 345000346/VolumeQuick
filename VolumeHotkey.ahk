#Requires AutoHotkey v2.0
#SingleInstance Force

; =============== 全局常量 ===============
CORNER_SIZE := 20  ; 当前显示器左上角热区大小（像素）
STARTUP_LINK_NAME := RegExReplace(A_ScriptName, "\.[^.]+$") ".lnk"
STARTUP_PATH := A_Startup "\" STARTUP_LINK_NAME

; =============== 环境初始化 ===============
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Screen"

; =============== 开机启动 ===============
IsStartupEnabled() {
    if !FileExist(STARTUP_PATH)
        return false

    try {
        FileGetShortcut(STARTUP_PATH, &target)
        return target = A_ScriptFullPath
    } catch {
        return false
    }
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
        if enable {
            iconPath := FileExist(A_ScriptDir "\icon.ico") ? A_ScriptDir "\icon.ico" : A_AhkPath
            if FileExist(STARTUP_PATH)
                FileDelete(STARTUP_PATH)
            FileCreateShortcut(A_ScriptFullPath, STARTUP_PATH, A_ScriptDir,, "音量控制快捷键工具", iconPath)
        } else if FileExist(STARTUP_PATH) {
            FileDelete(STARTUP_PATH)
        }
        return true
    } catch as err {
        MsgBox("设置开机启动失败: " err.Message, "错误", "16 T2")
        return false
    }
}

; =============== 系统托盘 ===============
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
    if !SetStartup(!IsStartupEnabled())
        return
    if IsStartupEnabled()
        Menu.Check(ItemName)
    else
        Menu.Uncheck(ItemName)
}

; =============== 热区门控 ===============
; 相对「鼠标所在显示器」的左上角判定，多屏下各屏均可用
IsInHotCorner() {
    MouseGetPos(&x, &y)
    loop MonitorGetCount() {
        MonitorGet(A_Index, &left, &top, &right, &bottom)
        if (x >= left && x < right && y >= top && y < bottom)
            return (x < left + CORNER_SIZE && y < top + CORNER_SIZE)
    }
    return false
}

; =============== 初始化 ===============
CheckFirstRun()
InitTrayMenu()

; =============== 热键绑定 ===============
#UseHook true
#HotIf IsInHotCorner()
WheelUp::Send "{Volume_Up}"
WheelDown::Send "{Volume_Down}"
MButton::Send "{Volume_Mute}"
#HotIf
