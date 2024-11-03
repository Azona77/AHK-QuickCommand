/*
  AHK QuickCommand by Azona77
    requires: AutoHotkey v1.1
*/
global FunctionList := ["ActionExample","OpenAHKDoc","OpenMyComputer","OpenNotepad","OpenTaskManager","OpenControlPanel","OpenCommandPromptCMD","PasteTime"]
Loop, Read, %A_ScriptFullPath%
{
    if RegExMatch(A_LoopReadLine, "^\s*(\w+)\s*\(\)\s*{", match)  ; 匹配函数定义
        FunctionList.Push(match1)
}
; Sort the list alphabetically
FunctionList := sortArray(FunctionList)
FunctionList := trimArray(FunctionList)
;-----------------------------------------------------------------------------------



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
#C::
#if GetKeyState("CapsLock", "P")
C::
    SetCapsLockState, off
    global LastCommand
    if (A_ThisHotkey = "c" && A_ThisHotkey = A_PriorHotkey && A_TimeSincePriorHotkey < 250) && LastCommand{
    gui, Destroy
    %LastCommand%()
    }
    else if !(WinActive("AHK QuickCommand") && WinActive("ahk_class AutoHotkeyGUI")){
    Gui, Destroy

    FontSize := 32
    Margin := FontSize * 0
    backgroundColor = 1d1d1d
    FontColor = d1d1d1
    transparency := 240

    Gui, -Caption +ToolWindow -border

    Gui, Margin, %Margin%, %Margin%
    Gui, Color, , %backgroundColor%
    Gui, Font, s%FontSize% c%FontColor% bold, Microsoft YaHei

    Gui, Add, Edit, vSearchInput w800 gUpdateListBox -vscroll -E0x200,
    Gui, Add, ListBox, vListBox w800 h800 gListBoxKey -E0x200,
    Gui, Show,, AHK QuickCommand

    WinSet, Transparent, %transparency%, AHK QuickCommand

    GuiControl,, ListBox1,  
    for index, value in FunctionList {
        GuiControl,, ListBox1, %value%
    }
    return

    UpdateListBox:
        Gui, Submit, NoHide
        searchText := SearchInput
        matchedList := RegExMatchList(FunctionList, searchText)
        ; ↓↓↓ Uncommenting following 4 lines to trigger immediately when matched item is unique
        ; if (IsFunc(matchedList)) {
        ;     Gui, Destroy
        ;     %matchedList%()
        ; }
        GuiControl,, ListBox1,  
        if (matchedList != ""){
            GuiControl,, ListBox1, % "|" matchedList
        }
    return

    ListBoxKey:
        GuiControlGet, selectedItem, , ListBox1
        if (A_GuiEvent = "DoubleClick"){
            RunListboxItem()
        }
    return
}
return

#if 

#IfWinActive AHK QuickCommand ahk_class AutoHotkeyGUI
CapsLock & Space::
~Enter::
    ControlGetFocus, focusedControl, A 
    if (focusedControl = "Edit1"){
        GuiControl, Focus, ListBox
        Send, {Down}
    }
    RunListboxItem()
return

~BackSpace::
    GuiControl, Focus, Edit1
return

GetLineNumber( ){
    ; Code from: https://www.autohotkey.com/board/topic/954-guicontrolget-listbox-line-number/
    SendMessage, 0x188, 0, 0, ListBox1, A
    return (ErrorLevel+1)
}
GetLineCount( ){
    ; Code from: https://www.autohotkey.com/boards/viewtopic.php?t=43057
    SendMessage, 0x18B, 0, 0, ListBox1, A ; LB_GETCOUNT
    return ErrorLevel
}

CapsLock & Esc::BackSpace
Esc::Gui, Destroy

~LButton::
    If !WinActive("AHK QuickCommand"){
        Gui, Destroy
    }
return

CapsLock & S::
Down::
    GuiControl, Focus, ListBox 
    if (GetLineNumber() = GetLineCount()){
        ControlSend, ListBox1, {Home}
    }
    else{
        ControlSend, ListBox1, {Down}
    }
return
CapsLock & W::
Up::
    GuiControl, Focus, ListBox 
    if (GetLineNumber() = 0 or GetLineNumber() = 1){
        ControlSend, ListBox1, {End}
    }
    else{
        ControlSend, ListBox1, {Up}
    }
return
#IfWinActive
;-----------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------
RunListboxItem( ){
    GuiControlGet, selectedItem, , ListBox1
    if (IsFunc(selectedItem)) {
        Gui, Destroy
        global LastCommand
        LastCommand:= selectedItem
        sleep, 50
        %selectedItem%()
    }else{
        tooltip, not existing func
        GuiControl, Focus, SearchInput
        sleep, 1000
        tooltip
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
/*
;-----------------------------------------------------------------------------------
; Code snippet from:
    ; https://stackoverflow.com/questions/46432447/how-do-i-remove-duplicates-from-an-autohotkey-array
;-----------------------------------------------------------------------------------
*/
trimArray(arr) { ; Hash O(n) 

    hash := {}, newArr := []

    for e, v in arr
        if (!hash.Haskey(v))
            hash[(v)] := 1, newArr.push(v)

    return newArr
}
;-----------------------------------------------------------------------------------
