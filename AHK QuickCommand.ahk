/*
  AHK QuickCommand by Azona77
    requires: AutoHotkey v1.1
*/
global FunctionList := ["ActionExample","OpenAHKDoc","OpenMyComputer","OpenNotepad","OpenTaskManager","OpenControlPanel","OpenCommandPromptCMD","PasteTime"]
global QuickCommandResults := []
global QuickCommandMeta := {}
global QuickCommandState := {Selected: 1, Query: "", Running: false}
global QuickCommandConfig := {Width: 800, Height: 800, RowHeight: 52, IndicatorWidth: 34, NoteWidth: 190, RunFeedbackMs: 80, Background: "1d1d1d", Foreground: "d1d1d1", Muted: "7f858d", Accent: "8bd5ff", SelectedBackground: "2a2f36", RunningBackground: "334252", ScrollbarFace: "4b5563", ScrollbarTrack: "20242a", ScrollbarArrow: "8bd5ff", Regex: "f5a97f", Acronym: "a6da95", Fuzzy: "c6a0f6", Contains: "eed49f"}

; Catalog bootstrap:
; - FunctionList stores real callable function names.
; - QuickCommandMeta stores optional display names and aliases, including emoji labels.
; - A function can add inline metadata with: MyFunc() { ; qc: 🚀 Display Name | alias words
QuickCommandInitMeta()
Loop, Read, %A_ScriptFullPath%
{
    if RegExMatch(A_LoopReadLine, "^\s*([^\s(]+)\s*\(\s*\)\s*{(?:\s*;\s*qc:\s*(.*))?", match) { ; 匹配无参函数定义，可带 ; qc: 显示名 | alias
        FunctionList.Push(match1)
        if (match2 != "")
            QuickCommandSetMeta(match1, match2)
    }
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
PasteTime(){
    FormatTime, CurrentDateTime,, yyyy-MM-dd HH_mm
    Clipboard := CurrentDateTime
    send, ^v
    return CurrentDateTime
}
; -----------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------
; Main 
; Entry hotkeys:
; - First press opens the command palette.
; - Double press repeats the last selected command.
#C::
    QuickCommandInvoke("WinC")
return

#if GetKeyState("CapsLock", "P")
C::
    SetCapsLockState, off
    QuickCommandInvoke("CapsC")
return

#if 

QuickCommandInvoke(trigger := "") {
    global LastCommand, HSearchInput, QuickCommandWeb, HQuickCommandWeb, SearchInput
    static PriorTrigger := ""
    static PriorTick := 0

    if (trigger = "")
        trigger := A_ThisHotkey

    isDoublePress := (trigger != "" && trigger = PriorTrigger && A_TickCount - PriorTick < 250)
    PriorTrigger := trigger
    PriorTick := A_TickCount

    if (isDoublePress && LastCommand) {
        Gui, Destroy
        %LastCommand%()
        return
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
    Gui, Color, %backgroundColor%, %backgroundColor%
    Gui, Font, s%FontSize% c%FontColor% bold, Microsoft YaHei

    ; Native Edit keeps keyboard input reliable; the result panel below is rendered by HTML.
    Gui, Add, Edit, vSearchInput w800 gQuickCommandUpdateListBox -vscroll -E0x200 hwndHSearchInput
    if LastCommand{
        SetEditCueBanner(HSearchInput, LastCommand . " ⬅️ Capslock+C+C")
    }
    ; Shell.Explorer gives us colored spans and emoji rendering without replacing AHK hotkeys.
    Gui, Add, ActiveX, vQuickCommandWeb w800 h800 hwndHQuickCommandWeb, Shell.Explorer
    QuickCommandInitRenderer(QuickCommandWeb)
    QuickCommandRenderResults("")

    Gui, Show,, AHK QuickCommand
    WinSet, Transparent, %transparency%, AHK QuickCommand
    QuickCommandFocusSearch()
    }
return
}

QuickCommandUpdateListBox:
    Gui, Submit, NoHide
    searchText := SearchInput
    QuickCommandRenderResults(searchText)
        ; ↓↓↓ Uncommenting following 4 lines to trigger immediately when matched item is unique
        ; matchedList := RegExMatchList(FunctionList, searchText)
        ; if (IsFunc(matchedList)) {
        ;     Gui, Destroy
        ;     %matchedList%()
        ; }
return

#IfWinActive AHK QuickCommand ahk_class AutoHotkeyGUI
Space::
    if !GetKeyState("Capslock", "P"){
        GuiControl, Focus, Edit1
        Send, {Blind}{Space}
        return
    }
~Enter::
    ControlGetFocus, focusedControl, A 
    RunListboxItem()
return

~BackSpace::
    GuiControl, Focus, Edit1
return

GetLineNumber( ){
    global QuickCommandState
    return QuickCommandState.Selected
}
GetLineCount( ){
    global QuickCommandResults
    return QuickCommandResults.MaxIndex()
}

*tab::
    if GetKeyState("Capslock", "P"){
        Send, {Blind}{BackSpace}
    }
return

*esc::Gui, Destroy

~LButton::
    if !winactive("AHK QuickCommand ahk_class AutoHotkeyGUI"){
        Gui, Destroy
    }
return

*S::
    if !GetKeyState("Capslock", "P"){
        Send, {Blind}s
        return
    }
Down::
    QuickCommandMoveSelection(1)
return
*W::
    if !GetKeyState("Capslock", "P"){
        Send, {Blind}w
        return
    }
Up::
    QuickCommandMoveSelection(-1)
return
#IfWinActive
;-----------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------
; Execute the currently selected row. The visible HTML may contain colors or emoji,
; so execution always uses QuickCommandResults[n].Name, the real AHK function name.
RunListboxItem( ){
    global QuickCommandResults
    global QuickCommandState
    global QuickCommandConfig

    if (QuickCommandState.Running)
        return

    selectedRow := QuickCommandState.Selected ? QuickCommandState.Selected : 1
    if (!QuickCommandResults.HasKey(selectedRow))
        selectedRow := 1
    selectedItem := QuickCommandResults[selectedRow].Name
    if (IsFunc(selectedItem)) {
        QuickCommandState.Running := true
        QuickCommandMarkRunning(selectedRow)
        Sleep, % QuickCommandConfig.RunFeedbackMs
        Gui, Destroy
        global LastCommand
        LastCommand:= selectedItem
        sleep, 50
        %selectedItem%()
        QuickCommandState.Running := false
    }else{
        tooltip, not existing func
        GuiControl, Focus, SearchInput
        sleep, 1000
        tooltip
        QuickCommandState.Running := false
    }
return
}

; Renderer lifecycle. ActiveX steals focus after navigation and document writes;
; all public render/select calls finish by restoring focus to SearchInput.
QuickCommandInitRenderer(ByRef web) {
    web.Silent := true
    web.Navigate("about:blank")
    while (web.Busy || web.ReadyState != 4)
        Sleep, 10
    QuickCommandWriteHtml(web, QuickCommandBuildBlankHtml())
    ComObjConnect(web, "QuickCommandWeb_")
}

QuickCommandWeb_TitleChange(title) {
    if RegExMatch(title, "^qc:(hover|select|run):(\d+):", match) {
        QuickCommandSelect(match2)
        if (match1 = "run")
            RunListboxItem()
        else
            QuickCommandFocusSearch()
    }
}

; Rebuild search result objects, reset selection to the first candidate, and rerender.
QuickCommandRenderResults(searchText := "") {
    global FunctionList
    global QuickCommandResults
    global QuickCommandState

    QuickCommandState.Query := searchText
    QuickCommandState.Running := false
    QuickCommandResults := QuickCommandBuildResults(FunctionList, searchText)
    QuickCommandSelect(1, false)
    QuickCommandRenderHtml()
    QuickCommandFocusSearch()
}

; Keyboard navigation wraps around result bounds.
QuickCommandMoveSelection(delta) {
    global QuickCommandResults
    global QuickCommandState

    rowCount := QuickCommandResults.MaxIndex()
    if (!rowCount)
        return

    currentRow := QuickCommandState.Selected
    if (!currentRow)
        currentRow := 1

    nextRow := currentRow + delta
    if (nextRow < 1)
        nextRow := rowCount
    else if (nextRow > rowCount)
        nextRow := 1

    QuickCommandSelect(nextRow)
}

; Change selected result. This is called by keyboard movement and HTML row clicks.
QuickCommandSelect(index, shouldRender := true) {
    global QuickCommandResults
    global QuickCommandState

    rowCount := QuickCommandResults.MaxIndex()
    if (!rowCount) {
        QuickCommandState.Selected := 0
        return
    }
    previousRow := QuickCommandState.Selected ? QuickCommandState.Selected : 0
    if (index < 1)
        index := 1
    else if (index > rowCount)
        index := rowCount
    QuickCommandState.Selected := index
    if (shouldRender) {
        QuickCommandSyncSelection(previousRow, index)
        QuickCommandFocusSearch()
    }
}

; Keep keyboard/mouse selection cheap: update only affected DOM rows and preserve
; the list scroll state instead of rewriting the whole document.
QuickCommandSyncSelection(previousRow, selectedRow) {
    global QuickCommandWeb

    if (!IsObject(QuickCommandWeb))
        return

    try {
        script := "qcSetSelection(" . previousRow . "," . selectedRow . ");"
        QuickCommandWeb.Document.parentWindow.execScript(script, "JavaScript")
    }
}

QuickCommandMarkRunning(selectedRow) {
    global QuickCommandWeb

    if (!IsObject(QuickCommandWeb))
        return

    try {
        script := "qcSetRunning(" . selectedRow . ");"
        QuickCommandWeb.Document.parentWindow.execScript(script, "JavaScript")
    }
}

; Search changes write a full HTML document. Selection changes are synced in-place
; by QuickCommandSyncSelection so the result list keeps its scroll position.
QuickCommandRenderHtml() {
    global QuickCommandWeb

    if (!IsObject(QuickCommandWeb))
        return

    html := QuickCommandBuildHtml()
    QuickCommandWriteHtml(QuickCommandWeb, html)
}

QuickCommandWriteHtml(web, html) {
    try {
        doc := web.Document
        doc.open()
        doc.write(html)
        doc.close()
    }
}

QuickCommandFocusSearch() {
    if WinActive("AHK QuickCommand ahk_class AutoHotkeyGUI")
        GuiControl, Focus, SearchInput
}

; HTML component. Rows signal AHK by changing document.title; AHK receives this via
; QuickCommandWeb_TitleChange. The input box stays native, so typing remains fast.
QuickCommandBuildHtml() {
    global QuickCommandResults
    global QuickCommandState
    global QuickCommandConfig

    rows := ""
    if (!QuickCommandResults.MaxIndex()) {
        rows := "<div class='empty'>No command</div>"
    } else {
        for index, result in QuickCommandResults {
            selectedClass := (index = QuickCommandState.Selected) ? " selected" : ""
            indicator := (index = QuickCommandState.Selected) ? "&#9656;" : ""
            rows .= "<div id='qc-row-" . index . "' class='row" . selectedClass . "' unselectable='on' onmouseover='qcHover(" . index . ")' onclick='qcSelect(" . index . ")' ondblclick='qcRun(" . index . ")'>"
                . "<span class='indicator'>" . indicator . "</span>"
                . "<span class='command'>" . result.Html . "</span>"
                . "<span class='note'>" . QuickCommandHtmlEscape(result.Note) . "</span>"
                . "</div>"
        }
    }

    return "<!doctype html><html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'><meta charset='utf-8'>"
        . "<style>"
        . "html,body{height:100%;margin:0;padding:0;background:#" . QuickCommandConfig.Background . ";color:#" . QuickCommandConfig.Foreground . ";overflow:hidden;font-family:'Microsoft YaHei','Segoe UI Emoji','Segoe UI Symbol','Segoe UI',sans-serif;font-size:30px;font-weight:700;-ms-user-select:none;user-select:none;}"
        . ".wrap{width:100%;height:100%;box-sizing:border-box;padding:0;overflow-y:auto;overflow-x:hidden;scrollbar-face-color:#" . QuickCommandConfig.ScrollbarFace . ";scrollbar-track-color:#" . QuickCommandConfig.ScrollbarTrack . ";scrollbar-arrow-color:#" . QuickCommandConfig.ScrollbarArrow . ";scrollbar-highlight-color:#" . QuickCommandConfig.ScrollbarFace . ";scrollbar-shadow-color:#" . QuickCommandConfig.ScrollbarTrack . ";scrollbar-3dlight-color:#" . QuickCommandConfig.ScrollbarTrack . ";scrollbar-darkshadow-color:#" . QuickCommandConfig.Background . ";}"
        . ".row{display:table;width:100%;table-layout:fixed;height:" . QuickCommandConfig.RowHeight . "px;line-height:" . QuickCommandConfig.RowHeight . "px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;padding:0 18px;box-sizing:border-box;cursor:default;border-left:4px solid transparent;-ms-user-select:none;user-select:none;transition:background-color .12s ease,border-left-color .12s ease,color .12s ease;}"
        . ".row.selected{background:#" . QuickCommandConfig.SelectedBackground . ";border-left-color:#" . QuickCommandConfig.Accent . ";}"
        . ".row.running{background:#" . QuickCommandConfig.RunningBackground . ";border-left-color:#" . QuickCommandConfig.Regex . ";}"
        . ".indicator{display:table-cell;width:" . QuickCommandConfig.IndicatorWidth . "px;color:#" . QuickCommandConfig.Accent . ";vertical-align:middle;}"
        . ".row.running .indicator{color:#" . QuickCommandConfig.Regex . ";}"
        . ".command{display:table-cell;overflow:hidden;text-overflow:ellipsis;vertical-align:middle;}"
        . ".note{display:table-cell;width:" . QuickCommandConfig.NoteWidth . "px;overflow:hidden;text-overflow:ellipsis;font-size:20px;color:#" . QuickCommandConfig.Muted . ";font-weight:400;vertical-align:middle;}"
        . ".m-prefix{color:#" . QuickCommandConfig.Accent . ";}"
        . ".m-contains{color:#" . QuickCommandConfig.Contains . ";}"
        . ".m-acronym{color:#" . QuickCommandConfig.Acronym . ";}"
        . ".m-fuzzy{color:#" . QuickCommandConfig.Fuzzy . ";}"
        . ".m-regex{color:#" . QuickCommandConfig.Regex . ";}"
        . ".alias{color:#" . QuickCommandConfig.Muted . ";font-weight:400;}"
        . ".empty{padding:24px 20px;color:#" . QuickCommandConfig.Muted . ";}"
        . "</style>"
        . "<script>"
        . "var qcSelected=" . QuickCommandState.Selected . ";var qcRunning=false;"
        . "function qcSignal(a,i){document.title='qc:'+a+':'+i+':'+(new Date()).getTime();}"
        . "function qcRow(i){return document.getElementById('qc-row-'+i);}"
        . "function qcHasClass(el,name){return el&&((' '+el.className+' ').indexOf(' '+name+' ')>=0);}"
        . "function qcAddClass(el,name){if(el&&!qcHasClass(el,name)){el.className+=' '+name;}}"
        . "function qcRemoveClass(el,name){if(el){el.className=(' '+el.className+' ').replace(new RegExp(' '+name+' ','g'),' ').replace(/^ +| +$/g,'');}}"
        . "function qcScrollNearest(el){var wrap=document.getElementById('qc-wrap');if(!wrap||!el){return;}var top=el.offsetTop;var bottom=top+el.offsetHeight;if(top<wrap.scrollTop){wrap.scrollTop=top;}else if(bottom>wrap.scrollTop+wrap.clientHeight){wrap.scrollTop=bottom-wrap.clientHeight;}}"
        . "function qcSetSelection(prev,next){var oldRow=qcRow(qcSelected||prev);var newRow=qcRow(next);if(oldRow&&oldRow!=newRow){qcRemoveClass(oldRow,'selected');var oldMark=oldRow.getElementsByTagName('span')[0];if(oldMark){oldMark.innerHTML='';}}if(newRow){qcAddClass(newRow,'selected');var newMark=newRow.getElementsByTagName('span')[0];if(newMark){newMark.innerHTML='&#9656;';}qcSelected=next;qcScrollNearest(newRow);}}"
        . "function qcSetRunning(i){qcRunning=true;qcSetSelection(qcSelected,i);qcAddClass(qcRow(i),'running');}"
        . "function qcHover(i){if(qcRunning||qcSelected==i){return;}qcSetSelection(qcSelected,i);qcSignal('hover',i);}"
        . "function qcSelect(i){if(qcRunning){return;}qcSetSelection(qcSelected,i);qcSignal('select',i);}"
        . "function qcRun(i){if(qcRunning){return;}qcSetRunning(i);qcSignal('run',i);}"
        . "document.onselectstart=function(){return false;};document.ondragstart=function(){return false;};"
        . "</script>"
        . "</head><body onselectstart='return false' ondragstart='return false' unselectable='on'><div id='qc-wrap' class='wrap' unselectable='on'>" . rows . "</div></body></html>"
}

QuickCommandBuildBlankHtml() {
    global QuickCommandConfig

    return "<!doctype html><html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'><meta charset='utf-8'>"
        . "<style>html,body{height:100%;margin:0;padding:0;background:#" . QuickCommandConfig.Background . ";overflow:hidden;}</style>"
        . "</head><body></body></html>"
}

; Built-in metadata for demo commands. User commands can either be added here or
; annotated inline after the function declaration with "; qc: Display | aliases".
QuickCommandInitMeta() {
    QuickCommandSetMeta("ActionExample", "⚙ ActionExample | example demo")
    QuickCommandSetMeta("OpenAHKDoc", "📘 OpenAHKDoc | ahk docs documentation")
    QuickCommandSetMeta("OpenMyComputer", "💻 OpenMyComputer | explorer computer")
    QuickCommandSetMeta("OpenNotepad", "📝 OpenNotepad | text editor")
    QuickCommandSetMeta("OpenTaskManager", "📊 OpenTaskManager | task process")
    QuickCommandSetMeta("OpenControlPanel", "🛠 OpenControlPanel | settings control")
    QuickCommandSetMeta("OpenCommandPromptCMD", "⌨ OpenCommandPromptCMD | cmd terminal shell")
    QuickCommandSetMeta("PasteTime", "🕒 PasteTime | date now")
}

; Parse and store one command metadata entry.
; specOrDisplay accepts either "Display | alias words" or just "Display".
QuickCommandSetMeta(name, specOrDisplay := "", aliases := "") {
    global QuickCommandMeta

    display := specOrDisplay
    if (aliases = "" && InStr(specOrDisplay, "|")) {
        parts := StrSplit(specOrDisplay, "|")
        display := Trim(parts[1])
        aliases := Trim(parts[2])
    }
    if (display = "")
        display := name
    QuickCommandMeta[name] := {Display: display, Aliases: aliases}
}

; Normalize a raw function name into the command object consumed by search/render.
; Display may contain emoji; Name must remain the real callable AHK function name.
QuickCommandGetCommand(name) {
    global QuickCommandMeta

    display := name
    aliases := ""
    if (QuickCommandMeta.HasKey(name)) {
        display := QuickCommandMeta[name].Display
        aliases := QuickCommandMeta[name].Aliases
    }
    searchText := display . " " . name . " " . aliases
    return {Name: name, Display: display, Aliases: aliases, SearchText: searchText}
}

; Backward-compatible API: returns the same pipe-delimited list as the old regex
; search function, but it now delegates to the richer result builder.
RegExMatchList(list, input) {
    results := QuickCommandBuildResults(list, input)
    matched := ""
    for _, result in results
        matched .= result.Name . "|"
    return RTrim(matched, "|")
}

; Search pipeline:
; - Empty query returns the alphabetized catalog.
; - "re:<pattern>" uses safe regex matching.
; - Other input uses weighted fuzzy matching over display name, function name, aliases.
QuickCommandBuildResults(list, input) {
    query := Trim(input)
    results := []
    if (query = "") {
        for _, item in list {
            command := QuickCommandGetCommand(item)
            results.Push({Name: command.Name, Display: command.Display, Html: QuickCommandHtmlEscape(command.Display), Note: command.Aliases ? "alias: " . command.Aliases : "ready", Score: 1})
        }
        return results
    }

    ranked := ""
    useRegex := (SubStr(query, 1, 3) = "re:")
    regex := useRegex ? SubStr(query, 4) : ""
    resultByName := {}

    for each, item in list {
        command := QuickCommandGetCommand(item)
        result := useRegex ? QuickCommandRegexResult(command, regex) : QuickCommandFuzzyResult(command, query)
        if (result.Score > 0) {
            ranked .= Format("{:05}", 99999 - result.Score) "|" command.Name "`n"
            resultByName[command.Name] := result
        }
    }

    ranked := RTrim(ranked, "`n")
    if (ranked = "")
        return results

    Sort, ranked

    Loop, Parse, ranked, `n, `r
    {
        parts := StrSplit(A_LoopField, "|")
        results.Push(resultByName[parts[2]])
    }
    return results
}

; Regex mode returns colored HTML only when the regex hits the visible display name.
; Alias/name hits still rank the command, but the visible name is left unmarked.
QuickCommandRegexResult(command, regex) {
    score := QuickCommandRegexScore(command.SearchText, regex)
    if (score <= 0)
        return {Name: command.Name, Display: command.Display, Html: QuickCommandHtmlEscape(command.Display), Note: "", Score: 0}

    html := QuickCommandHtmlEscape(command.Display)
    try {
        pos := RegExMatch(command.Display, "i)" . regex, match)
        if (pos && StrLen(match))
            html := QuickCommandDecorateRange(command.Display, pos, pos + StrLen(match) - 1, "regex")
    } catch e {
        return {Name: command.Name, Display: command.Display, Html: QuickCommandHtmlEscape(command.Display), Note: "", Score: 0}
    }

    return {Name: command.Name, Display: command.Display, Html: html, Note: "regex", Score: score}
}

; Fuzzy mode selects the best source (display/name/alias), then marks visible
; display-name characters when possible. Alias-only hits are explained in Note.
QuickCommandFuzzyResult(command, query) {
    match := QuickCommandBestFuzzyMatch(command, query)
    score := match.Score
    if (score <= 0)
        return {Name: command.Name, Display: command.Display, Html: QuickCommandHtmlEscape(command.Display), Note: "", Score: 0}

    marked := {}
    modes := {}
    itemLower := StrLower(command.Display)
    tokens := QuickCommandSplitQuery(StrLower(Trim(query)))

    if (match.Source = "display" || match.Source = "name") {
        for _, token in tokens
            QuickCommandMarkToken(command.Display, itemLower, token, marked, modes)
    }

    html := QuickCommandDecorateMarked(command.Display, marked)
    note := QuickCommandJoinModes(modes)
    if (match.Source = "alias")
        note := "alias: " . match.Alias
    return {Name: command.Name, Display: command.Display, Html: html, Note: note, Score: score}
}

; Compare display text, real function name, and aliases. Alias/name matches receive
; small penalties so direct visible-name matches stay first when scores are close.
QuickCommandBestFuzzyMatch(command, query) {
    best := {Score: QuickCommandFuzzyScore(command.Display, query), Source: "display", Alias: ""}

    nameScore := QuickCommandFuzzyScore(command.Name, query) - 30
    if (nameScore > best.Score)
        best := {Score: nameScore, Source: "name", Alias: ""}

    if (command.Aliases != "") {
        aliasScore := QuickCommandFuzzyScore(command.Aliases, query) - 80
        if (aliasScore > best.Score)
            best := {Score: aliasScore, Source: "alias", Alias: command.Aliases}
    }
    return best
}

; Mark one query token with a semantic match mode. The renderer maps these modes
; to CSS colors: prefix/contains/acronym/fuzzy.
QuickCommandMarkToken(item, itemLower, token, marked, modes) {
    if (token = "")
        return

    pos := InStr(itemLower, token)
    if (pos) {
        if (pos = 1) {
            QuickCommandMarkRange(marked, pos, pos + StrLen(token) - 1, "prefix")
            modes["prefix"] := true
        } else {
            QuickCommandMarkRange(marked, pos, pos + StrLen(token) - 1, "contains")
            modes["contains"] := true
        }
        return
    }

    acronymInfo := QuickCommandAcronymInfo(item)
    acronymPos := InStr(acronymInfo.Text, token)
    if (acronymPos) {
        Loop, % StrLen(token) {
            sourceIndex := acronymInfo.Positions[acronymPos + A_Index - 1]
            marked[sourceIndex] := "acronym"
        }
        modes["acronym"] := true
        return
    }

    positions := QuickCommandSubsequencePositions(itemLower, token)
    if (positions.MaxIndex()) {
        for _, sourceIndex in positions
            marked[sourceIndex] := "fuzzy"
        modes["fuzzy"] := true
    }
}

; Wrap a contiguous range with a semantic mode for HTML rendering.
QuickCommandDecorateRange(text, startPos, endPos, mode := "contains") {
    marked := {}
    QuickCommandMarkRange(marked, startPos, endPos, mode)
    return QuickCommandDecorateMarked(text, marked)
}

; Convert a marked character map into escaped HTML with colored span segments.
QuickCommandDecorateMarked(text, marked) {
    result := ""
    currentMode := ""

    Loop, Parse, text
    {
        mode := marked.HasKey(A_Index) ? marked[A_Index] : ""
        if (mode != currentMode) {
            if (currentMode != "")
                result .= "</span>"
            if (mode != "")
                result .= "<span class='m-" . mode . "'>"
            currentMode := mode
        }
        result .= QuickCommandHtmlEscape(A_LoopField)
    }
    if (currentMode != "")
        result .= "</span>"
    return result
}

; Store a mode for each character index in a range.
QuickCommandMarkRange(ByRef marked, startPos, endPos, mode := "contains") {
    Loop, % endPos - startPos + 1
        marked[startPos + A_Index - 1] := mode
}

; Return source character positions when token characters appear in order.
QuickCommandSubsequencePositions(itemLower, token) {
    positions := []
    searchPos := 1
    Loop, Parse, token
    {
        pos := InStr(itemLower, A_LoopField, false, searchPos)
        if (!pos)
            return []
        positions.Push(pos)
        searchPos := pos + 1
    }
    return positions
}

; Build an acronym map from first letter, CamelCase capitals, and separators.
QuickCommandAcronymInfo(item) {
    info := {Text: "", Positions: []}
    prev := ""

    Loop, Parse, item
    {
        ch := A_LoopField
        if (A_Index = 1 || RegExMatch(ch, "[A-Z]") || RegExMatch(prev, "[_\-\s]")) {
            info.Text .= StrLower(ch)
            info.Positions.Push(A_Index)
        }
        prev := ch
    }
    return info
}

; Human-readable summary shown in the right-side Match column.
QuickCommandJoinModes(modes) {
    result := ""
    for _, mode in ["prefix", "contains", "acronym", "fuzzy"] {
        if (modes.HasKey(mode))
            result .= mode . " "
    }
    return RTrim(result)
}

; Escape visible text before it enters the HTML renderer.
QuickCommandHtmlEscape(text) {
    text := StrReplace(text, "&", "&amp;")
    text := StrReplace(text, "<", "&lt;")
    text := StrReplace(text, ">", "&gt;")
    text := StrReplace(text, """", "&quot;")
    return text
}

QuickCommandRegexScore(item, regex) {
    if (regex = "")
        return 0

    try {
        pos := RegExMatch(item, "i)" . regex)
    } catch e {
        return 0
    }
    return pos ? 9000 - (pos * 10) : 0
}

; Weighted fuzzy scoring. Exact/prefix/contains/acronym/subsequence matches are
; deliberately scored in descending order to keep common commands predictable.
QuickCommandFuzzyScore(item, query) {
    itemLower := StrLower(item)
    queryLower := StrLower(Trim(query))

    if (itemLower = queryLower)
        return 10000

    tokens := QuickCommandSplitQuery(queryLower)
    tokenCount := tokens.MaxIndex()
    if (!tokenCount)
        return 0

    totalScore := 0
    for _, token in tokens {
        tokenScore := QuickCommandTokenScore(item, itemLower, token)
        if (tokenScore <= 0)
            return 0
        totalScore += tokenScore
    }

    return Round(totalScore / tokenCount) + (tokenCount * 80) - StrLen(item)
}

; Score one token against one searchable string.
QuickCommandTokenScore(item, itemLower, token) {
    pos := InStr(itemLower, token)
    if (pos = 1)
        return 8800 - StrLen(item)
    if (pos > 1)
        return 7600 - (pos * 20) - StrLen(item)

    acronym := QuickCommandAcronym(item)
    acronymPos := InStr(acronym, token)
    if (acronymPos = 1)
        return 7200 - StrLen(item)
    if (acronymPos > 1)
        return 6500 - (acronymPos * 20) - StrLen(item)

    return QuickCommandSubsequenceScore(itemLower, token)
}

; Score non-contiguous character matches. Tighter spans and earlier starts rank
; higher, which makes abbreviations feel natural without expensive algorithms.
QuickCommandSubsequenceScore(itemLower, token) {
    searchPos := 1
    firstPos := 0
    lastPos := 0
    gapTotal := 0

    Loop, Parse, token
    {
        pos := InStr(itemLower, A_LoopField, false, searchPos)
        if (!pos)
            return 0
        if (!firstPos)
            firstPos := pos
        if (lastPos)
            gapTotal += pos - lastPos - 1
        lastPos := pos
        searchPos := pos + 1
    }

    return 5600 + (StrLen(token) * 60) - (firstPos * 20) - (gapTotal * 25) - StrLen(itemLower)
}

; Legacy helper kept for scoring. QuickCommandAcronymInfo is used when positions
; are needed for colored rendering.
QuickCommandAcronym(item) {
    acronym := ""
    prev := ""

    Loop, Parse, item
    {
        ch := A_LoopField
        if (A_Index = 1 || RegExMatch(ch, "[A-Z]") || RegExMatch(prev, "[_\-\s]"))
            acronym .= ch
        prev := ch
    }
    return StrLower(acronym)
}

; Split query into non-empty space-separated tokens.
QuickCommandSplitQuery(query) {
    result := []
    parts := StrSplit(query, A_Space)
    for _, part in parts {
        part := Trim(part)
        if (part != "")
            result.Push(part)
    }
    return result
}

; AHK v1 compatibility shim; built-in StrLower is not available in all v1 setups.
StrLower(text) {
    StringLower, output, text
    return output
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
/*
;-----------------------------------------------------------------------------------
; Code snippet from:
    ; https://www.autohotkey.com/board/topic/76540-function-seteditcuebanner-ahk-l/
;-----------------------------------------------------------------------------------
*/
SetEditCueBanner(HWND, Cue) {  ; requires AHL_L
    Static EM_SETCUEBANNER := (0x1500 + 1)
    Return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
 }
