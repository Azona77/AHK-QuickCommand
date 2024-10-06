/*
  AHK QuickCommand by Azona77
    requires: AutoHotkey v1.1
*/
#SingleInstance force
global FunctionList := []
Loop, Read, %A_ScriptFullPath%
{
    if RegExMatch(A_LoopReadLine, "^\s*(\w+)\s*\(\)\s*{", match)  ; 匹配函数定义
        FunctionList.Push(match1)
}
; Sort the list alphabetically
FunctionList := sortArray(FunctionList)
;-----------------------------------------------------------------------------------
; ↑↑↑↑↑ Paste code above to the top of your script to automatically retrieve the list of functions when the script is loaded.



;-----------------------------------------------------------------------------------
; Example Commands
    ; To Exclude: change "func(){" to "func( ){"
ActionExample(){
    MsgBox, You selected Example!
}
OpenAHKDoc() {
    Run, https://www.autohotkey.com/docs/v1/
}
OpenMyComputer() {
    Run, explorer.exe
}
OpenNotepad() {
    Run, notepad.exe
}
OpenTaskManager() {
    Run, taskmgr.exe
}
OpenControlPanel() {
    Run, control panel
}
OpenCommandPromptCMD() {
    Run, cmd
}
PasteTime(){
    FormatTime, CurrentDateTime,, yyyy-MM-dd HH_mm
    Clipboard := CurrentDateTime
    send, ^v
    return CurrentDateTime
}
; -----------------------------------------------------------------------------------
    
;-----------------------------------------------------------------------------------
; Main 
#if GetKeyState("CapsLock", "P")
C::
    SetCapsLockState, off
    global FunctionList
    Gui, Destroy    

    FontSize := 32
    Margin := FontSize * 0
    backgroundColor = 1d1d1d
    FontColor = d1d1d1

    Gui -Caption +ToolWindow +Border
    Gui, Margin, %Margin%, %Margin%
    Gui, Color, , %backgroundColor%
    Gui, Font, s%FontSize% c%FontColor% bold, Microsoft YaHei

    Gui, Add, Edit, vSearchInput w800 gUpdateListBox,
    Gui, Add, ListBox, vListBox w800 h800 gListBoxKey,
    Gui, Show,, AHK QuickCommand

    GuiControl,, ListBox,  
    for index, value in FunctionList {
        GuiControl,, ListBox, %value%
    }
    return

    UpdateListBox:
        Gui, Submit, NoHide
        searchText := SearchInput
        matchedList := RegExMatchList(FunctionList, searchText)
        GuiControl,, ListBox,  
        if (matchedList != ""){
            GuiControl,, ListBox, % "|" matchedList
        }
    return

    ListBoxKey:
        GuiControlGet, selectedItem, , ListBox
        if (A_GuiEvent = "DoubleClick"){
            RunListboxItem()
        }
    return
return
#if 

#IfWinActive AHK QuickCommand ahk_class AutoHotkeyGUI
CapsLock & Space::
~Enter::
    ControlGetFocus, focusedControl
    if (focusedControl = "Edit1"){
        GuiControl, Focus, ListBox
        Send, {Down}
    }
    RunListboxItem()
return

CapsLock & Esc::BackSpace
Esc::Gui, Destroy

~LButton::
    If !WinActive("AHK QuickCommand"){
        Gui, Hide
    }
return

CapsLock & S::
Down::
ControlGetFocus, focusedControl
if (focusedControl = "Edit1"){
        GuiControl, Focus, ListBox
    }
Send, {Down}
return
CapsLock & W::
Up::
ControlGetFocus, focusedControl
if (focusedControl = "Edit1"){
        GuiControl, Focus, ListBox
    }
Send, {Up}
return
#IfWinActive
;-----------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------
RunListboxItem( ){
    GuiControlGet, selectedItem, , ListBox1
    if (IsFunc(selectedItem)) {
        Gui, Destroy
        %selectedItem%()
    }else{
        tooltip, not existing func
        GuiControl, Focus, SearchInput
    }
return
}
RegExMatchList(list, input) {
    if (input = "")
        return StrJoin(list, "|")

    regex := StrReplace(input, " ", ".*")
    ; case-insensitive flag i)
    regex := "i)" . regex

    matched := ""
    for each, item in list {
        if (RegExMatch(item, regex)) {
            matched .= item . "|"
        }
    }
    return RTrim(matched, "|")
}
StrJoin(arr, delim := "|") {
    result := ""
    for each, item in arr
        result .= item . delim
    return RTrim(result, delim)
}
/*
;-----------------------------------------------------------------------------------
; Code snippet from:
    ; https://www.autohotkey.com/board/topic/93570-sortarray/
;-----------------------------------------------------------------------------------
*/
sortArray(arr,options="") {	; specify only "Flip" in the options to reverse otherwise unordered array items
        if	!IsObject(arr)
            return	0
        new :=	[]
        if	(options="Flip") {
            While	(i :=	arr.MaxIndex()-A_Index+1)
                new.Insert(arr[i])
            return	new
        }
        For each, item in arr
            list .=	item "`n"
        list :=	Trim(list,"`n")
        Sort, list, %options%
        Loop, parse, list, `n, `r
            new.Insert(A_LoopField)
        return	new
}
;-----------------------------------------------------------------------------------
