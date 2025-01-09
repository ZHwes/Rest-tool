#RequireAdmin
#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <Misc.au3>

; 注册表路径定义
Global $editorPath = "HKEY_CURRENT_USER\SOFTWARE\JavaSoft\Prefs\com\wiris\editor"
Global $optionsPath = "HKEY_CURRENT_USER\SOFTWARE\Install Options"
Global $editorTargetKey = "license"
Global $optionsTargetKey = "options7.8"

; GUI创建
MainGUI()

; 主GUI函数
Func MainGUI()
    Local $GUI = GUICreate("Math Trial Reset", 400, 200)
    Local $btReset = GUICtrlCreateButton("Reset Math Trial", 100, 80, 200, 40)
    Local $btExit = GUICtrlCreateButton("Exit", 160, 150, 80, 30)
    GUISetState(@SW_SHOW)

    ; 主流程
    While 1
        Local $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE, $btExit
                GUIDelete($GUI)
                Exit

            Case $btReset
                GUICtrlSetData($btReset, "Processing...")
                ; 删除 Editor 注册表文件夹
                DeleteRegFolder($editorPath, $editorTargetKey)
                ; 删除 Options 注册表键值
                DeleteRegValue($optionsPath, $optionsTargetKey)
                GUICtrlSetData($btReset, "Reset Math Trial")
                MsgBox(64, "Success", "Math trial reset completed!")
        EndSwitch
    WEnd
EndFunc

; 函数: 删除指定路径下的注册表文件夹（即包含子项的键）
Func DeleteRegFolder($path, $folderName)
    Local $fullPath = $path & "\" & $folderName
    RunWait('reg delete "' & $fullPath & '" /f', "", @SW_HIDE)
    ConsoleWrite("Deleted registry folder (key): " & $fullPath & @CRLF)
EndFunc

; 函数: 删除指定路径下的注册表值项
Func DeleteRegValue($path, $keyName)
    ; 查询路径下的值项
    Local $queryResult = _getDOSOutput('reg query "' & $path & '" /v "' & $keyName & '"')
    ConsoleWrite("Query Result: " & $queryResult & @CRLF)

    ; 确认值项存在并类型为 REG_BINARY
    If StringInStr($queryResult, $keyName) And StringInStr($queryResult, "REG_BINARY") Then
        ; 删除值项
        RunWait('reg delete "' & $path & '" /v "' & $keyName & '" /f', "", @SW_HIDE)
        ConsoleWrite("Deleted registry value: " & $keyName & " from " & $path & @CRLF)
    Else
        ConsoleWrite("Value not found or not REG_BINARY: " & $keyName & " in " & $path & @CRLF)
    EndIf
EndFunc

; 函数: 执行DOS命令并获取输出
Func _getDOSOutput($command)
    Local $output = '', $pid = Run('"' & @ComSpec & '" /c ' & $command, '', @SW_HIDE, 2 + 4)
    While 1
        $output &= StdoutRead($pid, False, False)
        If @error Then ExitLoop
        Sleep(10)
    WEnd
    Return StringStripWS($output, 7)
EndFunc
