;**********************************************
;*                                            *
;*                                            *
;*                                            *
;*                                            *
;*                Main Program                *
;*                                            *
;*                                            *
;*                                            *
;*                                            *
;**********************************************
$Version=0.1


;*************************
;*                       *
;*    AHK Environment    *
;*                       *
;*************************
#NoEnv
#ClipboardTimeout 3000
#SingleInstance Force
#Persistent
ListLines Off

;[====================]
;[  Global variables  ]
;[  (Initial values)  ]
;[====================]
SplitPath A_ScriptName,,,,$ScriptName
$ClipboardMonitor:=False
$ClipboardStack  :=""
$ClipCount       :=0
$ClipReset       :=False
$ConfigFile      :=A_ScriptDir . "\" . $ScriptName . ".ini"
$IconsDir        :=A_ScriptDir . "\Resources\Icons"
$SoundsDir       :=A_ScriptDir . "\Resources\Sounds"

;-- Icons
$TrayIconEnabled :=$IconsDir . "\" . $ScriptName . ".ico"
$TrayIconClips   :=$IconsDir . "\" . $ScriptName . "_Clips.ico"
$TrayIconDisabled:=$IconsDir . "\" . $ScriptName . "_Disabled.ico"
$TrayIconReset   :=$IconsDir . "\" . $ScriptName . "_Reset.ico"

;-- Menu items
s_Paste_MI           :="Paste`tWin+V"
s_CopyToClipboard_MI :="Copy All Clips to Clipboard"


;[===========]
;[  Process  ]
;[===========]
gosub ReadConfiguration
gosub BuildMenus
SetTimer ClipboardMonitorOn
SetTimer ClipboardMonitorOff,% $Timeout*1000
return


;*****************************
;*                           *
;*                           *
;*        Subroutines        *
;*                           *
;*                           *
;*****************************
ReadConfiguration:
iniRead
    ,$ShowTooltips
    ,%$ConfigFile%
    ,General
    ,Tooltips
    ,%False%

iniRead
    ,$ShowTrayTips
    ,%$ConfigFile%
    ,General
    ,TrayTips
    ,%True%

iniRead
    ,$PlaySounds
    ,%$ConfigFile%
    ,General
    ,Sounds
    ,%True%

iniRead
    ,$Timeout
    ,%$ConfigFile%
    ,General
    ,Timeout
    ,120

return


SaveConfiguration:
iniWrite
    ,%$ShowTooltips%
    ,%$ConfigFile%
    ,General
    ,Tooltips

iniWrite
    ,%$ShowTrayTips%
    ,%$ConfigFile%
    ,General
    ,TrayTips

iniWrite
    ,%$PlaySounds%
    ,%$ConfigFile%
    ,General
    ,Sounds

iniWrite
    ,%$Timeout%
    ,%$ConfigFile%
    ,General
    ,Timeout

return


BuildMenus:

;-- Special sub-menu
Menu Special,Add,Clear Clipboard,ClearClipboard
Menu Special,Add,%s_CopyToClipboard_MI%,CopyToClipboard
Menu Special,Disable,%s_CopyToClipboard_MI%

;-- System tray
Menu Tray,NoStandard
Menu Tray,Add,Tooltips,ToggleShowTooltips
if $ShowTooltips
    Menu Tray,Check,Tooltips

Menu Tray,Add,TrayTips,ToggleShowTrayTips
if $ShowTrayTips
    Menu Tray,Check,TrayTips

Menu Tray,Add,Sounds,TogglePlaySounds
if $PlaySounds
    Menu Tray,Check,Sounds

Menu Tray,Add
Menu Tray,Add,%s_Paste_MI%,Paste
Menu Tray,Disable,%s_Paste_MI%
Menu Tray,Add,Clear,Clear
Menu Tray,Disable,Clear
Menu Tray,Add,Special,:Special
Menu Tray,Add
Menu Tray,Add,Timeout...,UpdateTimeout
Menu Tray,Add,About...,About
Menu Tray,Add
Menu Tray,Add,Enable,ToggleStatus  ;-- Start as if disabled
Menu Tray,Default,Enable
Menu Tray,Add,E&xit,Exit

;-- Set tray icon
Menu Tray,Icon,%$TrayIconEnabled%

;-- Show it
Menu Tray,Icon
return


ClipboardMonitorOn:
SetTimer %A_ThisLabel%,Off
$ClipboardMonitor:=True
$ClipboardStack  :=""
$ClipCount       :=0
$ClipReset       :=False
Menu Tray,Icon,%$TrayIconEnabled%
Menu Tray,Rename,Enable,Disable
Menu Tray,Tip,% $ScriptName . "`nClips: " . $ClipCount
if $PlaySounds
    {
    SetTimer ReleaseSoundFile,5000
    SoundPlay %$SoundsDir%\Monitor On.wav
    }

return


ClipboardMonitorOff:
SetTimer %A_ThisLabel%,Off
$ClipboardMonitor:=False
$ClipboardStack  :=""
$ClipCount       :=0
$ClipReset       :=False
Menu Special,Disable,%s_CopyToClipboard_MI%
Menu Tray,Icon,%$TrayIconDisabled%
Menu Tray,Disable,%s_Paste_MI%
Menu Tray,Disable,Clear
Menu Tray,Rename,Disable,Enable
Menu Tray,Tip,% $ScriptName . "`nDisabled"
if $PlaySounds
    {
    SetTimer ReleaseSoundFile,5000
    SoundPlay %$SoundsDir%\Monitor Off.wav
    }

return


OnClipboardChange:
;-- Bounce?
if ($ClipboardMonitor=False or A_EventInfo<>1)
    return

;-- Reset?
if $ClipReset
    {
    $ClipboardStack:=""
    $ClipCount     :=0
    $ClipReset     :=False
    }

;-- Count it
$ClipCount++

;-- Tooltip
if $ShowTooltips
    {
    MouseGetPos $MouseX,$MouseY,
    ToolTip Text copied.`nClips: %$ClipCount%,% $MouseX+50,% $MouseY+10
    SetTimer TooltipOff,3000
    }

;-- TrayTip
if $ShowTrayTips
    {
    TrayTip
        ,%$ScriptName%
        ,Clips: %$ClipCount%
        ,10
        ,16  ;-- No sound


    SetTimer TrayTipOff,6000
    }

;-- Push to stack
$Clipboard:=Clipboard
if StrLen($ClipboardStack)=0
    $ClipboardStack:=$Clipboard
 else
    {
    if SubStr($ClipboardStack,-1)<>"`r`n"
        $ClipboardStack.="`r`n"

    $ClipboardStack.=$Clipboard
    }

;-- Update tray icon and menu
if $ClipCount=1
    {
    Menu Special,Enable,%s_CopyToClipboard_MI%
    Menu Tray,Icon,%$TrayIconClips%
    Menu Tray,Enable,%s_Paste_MI%
    Menu Tray,Enable,Clear
    }

;-- Update tray tip
Menu Tray,Tip,% $ScriptName . "`nClips: " . $ClipCount

;-- Reset ClipboardMonitorOff timer
SetTimer ClipboardMonitorOff,% $Timeout*1000

;-- Sound
if $PlaySounds
    {
    SetTimer ReleaseSoundFile,5000
    SoundPlay, %$SoundsDir%\Copy.wav
    }

return


Clear:
;-- Bounce?
if not $ClipboardMonitor
    {
    SoundPlay *-1  ;-- Default system sound
    return
    }

;-- Reset
$ClipboardStack:=""
$ClipCount     :=0
$ClipReset     :=False

;-- Update tray icon
Menu Tray,Icon,%$TrayIconEnabled%

;-- Update menu
Menu Special,Disable,%s_CopyToClipboard_MI%
Menu Tray,Disable,%s_Paste_MI%
Menu Tray,Disable,Clear

;-- Update tray tip
Menu Tray,Tip,% $ScriptName . "`nClips: " . $ClipCount

;-- Reset ClipboardMonitorOff timer
SetTimer ClipboardMonitorOff,% $Timeout*1000

;-- Sound
if $PlaySounds
    {
    SetTimer ReleaseSoundFile,5000
    SoundPlay, %$SoundsDir%\Clear.wav
    }

return


ClearClipboard:
Clipboard :=""

;-- Reset ClipboardMonitorOff timer
if $ClipboardMonitor
    SetTimer ClipboardMonitorOff,% $Timeout*1000

;-- Sound
if $PlaySounds
    SoundPlay *64  ;-- System info sound

return


CopyToClipboard:
;-- Bounce?
if ($ClipboardMonitor=False or $ClipCount=0)
    {
    SoundPlay *-1  ;-- Default system sound
    return
    }

;-- Turn Clipboard monitoring Off
$ClipboardMonitor:=False
SetTimer ClipboardMonitorOff,Off

;-- If necessary, add trailing CR+LF
if SubStr($ClipboardStack,-1)<>"`r`n"
    $ClipboardStack.="`r`n"

;-- Update clipboard with the clipboard stack
Clipboard :=$ClipboardStack

;-- Trigger OnClipboardChange
Sleep 50

;-- Resume Clipboard monitoring
$ClipboardMonitor:=True
SetTimer ClipboardMonitorOff,% $Timeout*1000

;-- Sound
if $PlaySounds
    SoundPlay *64  ;-- System info sound

return


ToggleStatus:
if $ClipboardMonitor
    gosub ClipboardMonitorOff
 else
    {
    SetTimer ClipboardMonitorOff,Off
    gosub ClipboardMonitorOn
    SetTimer ClipboardMonitorOff,% $Timeout*1000
    }

return


ToggleShowTooltips:
$ShowTooltips:=($ShowTooltips) ? False:True
Menu Tray,ToggleCheck,Tooltips
gosub SaveConfiguration
return


ToggleShowTrayTips:
$ShowTrayTips:=($ShowTrayTips) ? False:True
Menu Tray,ToggleCheck,TrayTips
gosub SaveConfiguration
return


TogglePlaySounds:
$PlaySounds:=($PlaySounds) ? False:True
Menu Tray,ToggleCheck,Sounds
gosub SaveConfiguration
return


UpdateTimeout:
Loop
    {
    InputBox t_Timeout,Timeout,Inactivity timeout`n(in seconds):,,180,160,,,,,%$Timeout%
    If ErrorLevel
        return
    
    if t_Timeout is Integer
        {
        if t_Timeout>4
            {
            $Timeout:=t_Timeout
            Break
            }
        }

    SoundPlay *16  ;-- System error sound
    }

;-- Reset ClipboardMonitorOff timer
if $ClipboardMonitor
    SetTimer ClipboardMonitorOff,% $Timeout*1000

;-- Save configuration
gosub SaveConfiguration

;-- Sound
if $PlaySounds
    SoundPlay *64  ;-- System info sound

return


About:
MsgBox 64,About,%$ScriptName%            %A_Space%`nv%$Version%
return


TooltipOff:
SetTimer %A_ThisLabel%,Off
Tooltip
return


TrayTipOff:
SetTimer %A_ThisLabel%,Off
TrayTip
return


ReleaseSoundFile:
outputdebug Subroutine: %A_ThisLabel%
SetTimer %A_ThisLabel%,Off
SoundPlay ThisFileNameShouldNotExist.zxxqyz
return


Exit:
ExitApp


;*****************
;*               *
;*    Hotkeys    *
;*               *
;*****************
Paste:
;-- Bounce?
if ($ClipboardMonitor=False or StrLen($ClipboardStack)=0)
    {
    SoundPlay *-1  ;-- Default system sound
    return
    }

;-- Instruct the user
MsgBox
    ,262209  ;-- 262209 = 1 (OK/Cancel buttons) + 64 (info icon) + 262144 (AOT)
    ,%$ScriptName% - Paste,
       (ltrim join`s
        Put the cursor where you want to start pasting then click OK to
        paste.  %A_Space%
       )

IfMsgBox Cancel
    return


;-- Give the target window a chanse to focus
Sleep 400

;Do it!
gosub Paste2
return


#v::
Paste2:
;-- Bounce?
if ($ClipboardMonitor=False or StrLen($ClipboardStack)=0)
    {
    SoundPlay *-1  ;-- Default system sound
    return
    }

;-- Turn Clipboard monitoring Off
$ClipboardMonitor:=False
SetTimer ClipboardMonitorOff,Off

;-- If necessary, add trailing CR+LF
if SubStr($ClipboardStack,-1)<>"`r`n"
    $ClipboardStack.="`r`n"

;-- Save current clipboard
$ClipboardAll:=ClipboardAll

;-- Update clipboard with the clipboard stack
Clipboard :=$ClipboardStack

;-- Paste from clipboard
SendInput ^v

;-- Minor delay to allow paste to begin
Sleep 180
    ;-- Note: This delay also allows the OnClipboardChange routine to fire

;-- Restore Clipboard
Clipboard :=$ClipboardAll

;-- Trigger OnClipboardChange
Sleep 50

;-- Tooltip
if $ShowTooltips and not $ClipReset
    {
    ToolTip Paste.`nCopy buffer will be reset`non the next copy request.
    SetTimer TooltipOff,5000
    }

;-- TrayTip
if $ShowTrayTips and not $ClipReset
    {
    TrayTip
        ,%$ScriptName%
        ,Paste.`nCopy buffer will be reset`non the next copy request.
        ,10
        ,16  ;-- No sound

    SetTimer TrayTipOff,10000
    }

;-- Set to reset on the next copy
$ClipReset:=True

;-- Update tray icon
Menu Tray,Icon,%$TrayIconReset%

;-- Update tray tip
Menu Tray
    ,Tip
    ,% $ScriptName . "`nClips: " . $ClipCount . "`nAuto-reset on the next copy."

;-- Sound
if $PlaySounds
    {
    SetTimer ReleaseSoundFile,5000
    SoundPlay %$SoundsDir%\Paste.wav
    }

;-- Resume Clipboard monitoring
$ClipboardMonitor:=True
SetTimer ClipboardMonitorOff,% $Timeout*1000
return
