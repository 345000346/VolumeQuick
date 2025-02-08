#Requires AutoHotkey v2.0
#SingleInstance Force

; =============== 全局常量 ===============
CORNER_SIZE := 20  ; 左上角热区大小（像素）

; =============== 性能优化设置 ===============
SetWorkingDir A_ScriptDir
ProcessSetPriority "High"
SetWinDelay -1
SetControlDelay -1

; =============== 首次运行处理 ===============
CheckFirstRun() {
    startupPath := A_Startup "\VolumeHotkey.lnk"
    ; 通过检查启动项来判断是否首次运行，实现无残留
    if !FileExist(startupPath) && A_ScriptFullPath != startupPath {
        result := MsgBox("是否希望在开机时自动启动音量控制工具？", "首次运行设置", "35")
        if (result = "Yes")
            SetStartup(true)
    }
}

SetStartup(enable := true) {
    startupPath := A_Startup "\VolumeHotkey.lnk"
    try {
        if (enable && !FileExist(startupPath)) {
            FileCreateShortcut(A_ScriptFullPath, startupPath, A_ScriptDir,, "音量控制快捷键工具", A_AhkPath)
            return true
        } else if (!enable && FileExist(startupPath)) {
            FileDelete(startupPath)
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
    
    startupPath := A_Startup "\VolumeHotkey.lnk"
    
    TrayMenu.Add("开机启动", ToggleAutoStart)
    if FileExist(startupPath)
        TrayMenu.Check("开机启动")
    
    TrayMenu.Add()
    TrayMenu.Add("退出", (*) => ExitApp())
    
    if FileExist(A_ScriptDir "\icon.ico")
        TraySetIcon(A_ScriptDir "\icon.ico")
}

ToggleAutoStart(ItemName, ItemPos, Menu) {
    startupPath := A_Startup "\VolumeHotkey.lnk"
    if (!FileExist(startupPath)) {
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
    if (A_TickCount - lastCheck < 20)
        return lastResult
    
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mouseX, &mouseY)
    lastCheck := A_TickCount
    lastResult := (mouseX <= CORNER_SIZE && mouseY <= CORNER_SIZE)
    return lastResult
}

AdjustVolume(direction) {
    static lastAdjust := 0
    if (A_TickCount - lastAdjust < 50)
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
#InputLevel 1
#HotIf IsInTopLeftCorner()
~WheelUp::AdjustVolume("up")      ; 滚轮上 - 增加音量
~WheelDown::AdjustVolume("down")  ; 滾輪下 - 降低音量
~MButton::Send "{Volume_Mute}"    ; 中键 - 静音切换
#HotIf
