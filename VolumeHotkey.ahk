#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 1

; =============== 全局常量 ===============
global CORNER_SIZE := 20           ; 热区大小（像素）
global VOLUME_STEP := 2            ; 音量调节步长（百分比）
global GAME_CHECK_INTERVAL := 5000 ; 游戏检测间隔（毫秒）

; =============== 性能优化设置 ===============
SetWorkingDir A_ScriptDir
ProcessSetPriority "Normal"
SetBatchLines -1  ; 最高性能模式
Thread "Interrupt", 0  ; 防止中断关键操作

; 全局变量
global LastGameCheck := 0
global GameStatusCache := false
global LastVolumeAdjust := 0

; =============== 游戏检测函数（带缓存）=******
IsGameRunning() {
    ; 检查缓存是否仍然有效（5秒内）
    if (A_TickCount - LastGameCheck < GAME_CHECK_INTERVAL) {
        return GameStatusCache
    }

    games := [
        ; EA Sports FC系列
        "FIFA24.exe", "FC24.exe",
        "EADesktop.exe", "EAapp.exe",
        
        ; Steam游戏
        "steam.exe", "steamwebhelper.exe",
        
        ; Epic Games
        "EpicGamesLauncher.exe",
        
        ; 射击类游戏
        "csgo.exe", "game.exe",           ; CS系列
        "valorant.exe",                   ; Valorant
        "TslGame.exe",                    ; PUBG
        "r5apex.exe",                     ; Apex Legends
        
        ; MOBA类游戏
        "LeagueClient.exe", "RiotClientServices.exe",  ; 英雄联盟
        "dota.exe",                       ; Dota 2
        
        ; 其他竞技游戏
        "Overwatch.exe",                  ; 守望先锋
        "RocketLeague.exe",               ; 火箭联盟
        "RainbowSix.exe",                 ; 彩虹六号
        "FortniteClient-Win64-Shipping.exe", ; Fortnite
        "bf2042.exe",                     ; BattleField 2042
        "Wow.exe"                         ; 魔兽世界
    ]

    GameStatusCache := false
    for game in games {
        if WinExist("ahk_exe " game) {
            GameStatusCache := true
            break
        }
    }
    
    LastGameCheck := A_TickCount
    return GameStatusCache
}

; =============== 音量控制函数 =******
GetMasterVolume() {
    try {
        return Round(DllCall("winmm.dll\waveOutGetVolume", "Ptr", 0, "UInt*", &vol := 0) = 0 ? (vol & 0xFFFF) * 100 // 0xFFFF : 0)
    } catch {
        return 0
    }
}

SetMasterVolume(volume) {
    try {
        volume := Clamp(volume, 0, 100)
        volDWORD := (volume * 0xFFFF // 100) << 16 | (volume * 0xFFFF // 100)
        DllCall("winmm.dll\waveOutSetVolume", "Ptr", 0, "UInt", volDWORD)
    } catch {
        ; 如果API调用失败，使用Send方法作为备选
        try {
            currentVol := GetMasterVolume()
            if (volume > currentVol) {
                steps := Ceil((volume - currentVol) / VOLUME_STEP)
                Loop steps {
                    Send("{Volume_Up}")
                }
            } else if (volume < currentVol) {
                steps := Ceil((currentVol - volume) / VOLUME_STEP)
                Loop steps {
                    Send("{Volume_Down}")
                }
            }
        } catch {
            ; 最后备选方案
        }
    }
}

; =============== 核心功能函数 =******
IsInTopLeftCorner() {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mouseX, &mouseY)
    return (mouseX <= CORNER_SIZE && mouseY <= CORNER_SIZE && !IsGameRunning())
}

AdjustVolume(direction) {
    ; 防止过于频繁的调用
    if (A_TickCount - LastVolumeAdjust < 40)  ; 40ms防抖
        return
    
    currentVolume := GetMasterVolume()
    newVolume := direction = "up" ? currentVolume + VOLUME_STEP : currentVolume - VOLUME_STEP
    newVolume := Clamp(newVolume, 0, 100)
    
    SetMasterVolume(newVolume)
    
    LastVolumeAdjust := A_TickCount
}

; =============== 系统托盘设置 =******
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

; =============== 首次运行处理 =******
CheckFirstRun() {
    startupPath := A_Startup "\VolumeHotkey.lnk"
    ; 通过检查启动项来判断是否首次运行，实现无残留
    if !FileExist(startupPath) && A_ScriptFullPath != startupPath {
        result := MsgBox("是否希望在开机时自动启动音量控制工具？", "首次运行设置", "35")
        if (result = "Yes")
            SetStartup(true)
    }
}

; =============== 错误处理和初始化 =******
try {
    ; =============== 初始化 =******
    CheckFirstRun()  ; 检查首次运行
    InitTrayMenu()

    ; =============== 热键绑定 =******
    #UseHook true
    #InputLevel 1
    #HotIf IsInTopLeftCorner()
    ~WheelUp::AdjustVolume("up")      ; 滚轮上 - 增加音量
    ~WheelDown::AdjustVolume("down")  ; 滚轮下 - 降低音量
    ~MButton::Send "{Volume_Mute}"    ; 中键 - 静音切换
    #HotIf
} catch as e {
    MsgBox("VolumeQuick启动失败: " e.Message "`n`n行: " e.Line "`n文件: " e.File, "严重错误", "16")
    ExitApp()
}
