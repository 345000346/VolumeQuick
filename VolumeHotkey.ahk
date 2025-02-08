#Requires AutoHotkey v2.0
#SingleInstance Force

; =============== 全局配置及初始化 ===============
class Config {
    static VOLUME_STEP := 2  ; 默认音量调节步进值
    static CONFIG_FILE := A_ScriptDir "\config.ini"
    static CORNER_SIZE := 20  ; 左上角热区大小（像素）
    
    ; 初始化配置
    static Init() {
        if !FileExist(this.CONFIG_FILE) {
            try {
                FileAppend "[Settings]`nVolumeStep=" this.VOLUME_STEP, this.CONFIG_FILE
            } catch as err {
                MsgBox "无法创建配置文件: " err.Message, "错误", "16"
                ExitApp
            }
        }
        this.VOLUME_STEP := IniRead(this.CONFIG_FILE, "Settings", "VolumeStep", this.VOLUME_STEP)
    }
}

; =============== 性能优化设置 ===============
SetWorkingDir A_ScriptDir
ProcessSetPriority "High"
SetWinDelay -1
SetControlDelay -1

; =============== 启动初始化 ===============
Config.Init()  ; 初始化配置
SetupAutoStart()  ; 检查开机启动

; =============== 核心功能函数 ===============
; 检测鼠标是否在左上角热区
IsInTopLeftCorner() {
    static lastCheck := 0
    static lastResult := false
    if (A_TickCount - lastCheck < 20)
        return lastResult
    
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mouseX, &mouseY)
    lastCheck := A_TickCount
    lastResult := (mouseX <= Config.CORNER_SIZE && mouseY <= Config.CORNER_SIZE)
    return lastResult
}

; 调整系统音量
AdjustVolume(direction) {
    static lastAdjust := 0
    if (A_TickCount - lastAdjust < 50)
        return
    
    ; 计算按键次数
    keyPresses := Max(1, Config.VOLUME_STEP // 2)
    
    ; 发送音量调整按键
    if (direction = "up") {
        Loop keyPresses
            Send "{Volume_Up}"
    } else if (direction = "down") {
        Loop keyPresses
            Send "{Volume_Down}"
    }
    
    lastAdjust := A_TickCount
}

; 设置开机启动
SetupAutoStart() {
    shortcutPath := A_Startup "\VolumeHotkey.lnk"
    if !FileExist(shortcutPath) {
        result := MsgBox("是否将音量控制工具添加到开机启动？", "开机启动设置", "36")
        if (result = "Yes") {
            try {
                FileCreateShortcut(A_ScriptFullPath, shortcutPath, A_ScriptDir,, "音量控制快捷键工具", A_AhkPath)
                MsgBox("已添加开机启动", "设置成功", "64 T1")
            } catch as err {
                MsgBox("添加开机启动失败: " err.Message, "错误", "16 T2")
            }
        }
    }
}

; =============== 设置界面类 ===============
class SettingsGui {
    __New() {
        ; 创建主窗口
        this.gui := Gui("+AlwaysOnTop +Theme", "音量快捷控制设置")
        this.gui.SetFont("s10", "Microsoft YaHei UI")
        
        ; 添加图标（如果存在）
        if FileExist(A_ScriptDir "\icon.ico")
            this.gui.Add("Picture", "x0 y0 w32 h32", A_ScriptDir "\icon.ico")
        
        ; 创建设置界面元素
        this.CreateSettingsGroup()
        
        ; 添加按钮
        this.CreateButtons()
        
        ; 设置事件处理
        this.SetupEvents()
    }
    
    ; 创建设置组
    CreateSettingsGroup() {
        this.gui.Add("GroupBox", "x10 y10 w280 h140", "设置选项")
        
        ; 音量步进设置
        this.gui.Add("Text", "x25 y35", "音量调整步进值: ")
        this.gui.Add("Text", "x230 y35", "%")
        this.volumeStepEdit := this.gui.Add("Edit", "x140 y32 w80 Center", Config.VOLUME_STEP)
        this.gui.Add("UpDown", "x220 y32 w20 h20 Range2-20", Config.VOLUME_STEP)
        this.gui.Add("Text", "x25 y60 w250 c666666", "每次调整音量的百分比（建议：2-20）")
        
        ; 开机启动选项
        this.shortcutPath := A_Startup "\VolumeHotkey.lnk"
        this.autoStartCheckbox := this.gui.Add("Checkbox", "x25 y90", "开机自动启动")
        this.autoStartCheckbox.Value := FileExist(this.shortcutPath) ? 1 : 0
        
        this.gui.Add("Text", "x10 y160 w280 h1 0x10")  ; 分隔线
    }
    
    ; 创建按钮
    CreateButtons() {
        this.gui.Add("Button", "x120 y170 w80 h30 Default", "保存")
            .OnEvent("Click", this.SaveSettings.Bind(this))
        
        this.gui.Add("Button", "x210 y170 w80 h30", "取消")
            .OnEvent("Click", (*) => this.gui.Destroy())
    }
    
    ; 设置事件处理
    SetupEvents() {
        this.gui.OnEvent("Close", (*) => this.gui.Destroy())
    }
    
    ; 保存设置
    SaveSettings(*) {
        ; 保存音量步进值
        newStep := Integer(this.volumeStepEdit.Value)
        if (newStep >= 2 && newStep <= 20) {
            Config.VOLUME_STEP := newStep
            IniWrite(newStep, Config.CONFIG_FILE, "Settings", "VolumeStep")
        } else {
            MsgBox("步进值必须在 2-20 之间", "设置错误", "48 T2")
            return
        }
        
        ; 处理开机启动设置
        this.HandleAutoStart()
        
        this.gui.Destroy()
        MsgBox("设置已保存", "设置成功", "64 T1")
    }
    
    ; 处理开机启动设置
    HandleAutoStart() {
        if (this.autoStartCheckbox.Value != FileExist(this.shortcutPath)) {
            if (this.autoStartCheckbox.Value) {
                try {
                    FileCreateShortcut(A_ScriptFullPath, this.shortcutPath, A_ScriptDir,, "音量控制快捷键工具", A_AhkPath)
                } catch as err {
                    MsgBox("创建启动项失败: " err.Message, "错误", "16 T2")
                }
            } else {
                FileDelete(this.shortcutPath)
            }
        }
    }
    
    Show() {
        this.gui.Show()
    }
}

; =============== 设置界面管理 ===============
ShowSettingsGui(*) {
    global settingsGuiInstance
    
    try {
        if IsSet(settingsGuiInstance) && WinExist(settingsGuiInstance.gui) {
            settingsGuiInstance.gui.Show()
            return
        }
    }
    
    settingsGuiInstance := SettingsGui()
    settingsGuiInstance.Show()
}

; =============== 热键绑定 ===============
#UseHook true
#InputLevel 1
#HotIf IsInTopLeftCorner()
~WheelUp::AdjustVolume("up")      ; 滚轮上 - 增加音量
~WheelDown::AdjustVolume("down")  ; 滚轮下 - 降低音量
~MButton::Send "{Volume_Mute}"    ; 中键 - 静音切换
#HotIf

; 打开设置界面
^!o::ShowSettingsGui()  ; Ctrl + Alt + O
