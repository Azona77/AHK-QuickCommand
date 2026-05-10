## AHK-QuickCommand

**中文简介**：**AHK QuickCommand** 是一段即插即用的 AutoHotkey 脚本片段，通过极简配置，在 GUI 中快速搜索并执行主 AHK 脚本里的函数或命令。

**English Introduction**: **AHK QuickCommand** is a plug-and-play AutoHotkey snippet that enables you to instantly search and execute already-existing functions or commands in your scripts with minimal setup.

<div align=center>
<img src="https://github.com/user-attachments/assets/abd8091e-e151-4e58-9366-07a6d37b75bb" width="500px" style="margin-right:auto; margin-left:auto">
</div>

<p align="center">
  <img src="https://github.com/user-attachments/assets/b41f1d36-4f1f-4d52-b272-09c25d1c4d07" alt="Gif 1" style="display: inline-block; margin-right: 10px;" width="200px"/>
  <img src="https://github.com/user-attachments/assets/fa32ecbf-8669-4648-9019-9fe9dad8c125" alt="Gif 2" style="display: inline-block; margin-right: 10px;" width="200px"/>
  <img src="https://github.com/user-attachments/assets/bf8c0055-f95c-4873-906b-57f89356571e" alt="Gif 3" style="display: inline-block;" width="200px"/>
</p>

## 中文文档

## 主要功能
- **配置简单**：只需要在主脚本中引入 **AHK QuickCommand.ahk** 即可使用。它会自动读取并显示 AHK 脚本中可用的函数，并通过 GUI 提供快速调用入口。
- **快速搜索**：输入关键字即可过滤命令。可通过双击或按 `Enter` 执行选中的函数。

## 使用方法
1. 编辑你现有的 AHK 主脚本，并在脚本顶部引入 `AHK QuickCommand.ahk`，例如：`#Include, C:\Desktop\AHK QuickCommand.ahk`
2. 保存并运行脚本。按下 `Capslock + C` 打开命令 GUI。
3. 输入关键字过滤命令。使用方向键选择命令，按 `Enter` 或双击执行选中的函数。

## 自定义快捷键
`AHK QuickCommand.ahk` 默认只保留公开通用的快捷键。为了避免把个人快捷键写进分发文件，你可以在主脚本的 `#Include` 之后绑定自己的快捷键，并调用 `QuickCommandInvoke()`。

```AutoHotKey
#Include, C:\Desktop\AHK QuickCommand.ahk

F18::
    QuickCommandInvoke("F18")
return
```

可选的触发器名称会用于双击检测。因此，连续按两次同一个自定义快捷键时，可以重复执行上一次运行的命令。

## 注意事项
- 需要 AutoHotkey v1.1 或更高版本。
- 命令应按以下格式定义：

```AutoHotKey
; Example Commands
    ; To Exclude: change "func(){" to "func( ){"
ActionExample(){
    MsgBox, You selected Example!
    ; Replace with your custom function
}
```

- `#Include, C:\Desktop\AHK QuickCommand.ahk` 建议放在主脚本初始化后会自动运行的启动脚本之后。

## 扩展功能
- 使用 `CapsLock+W/S/Space` 作为 `Up/Down/Enter`；
- 使用 `CapsLock+C+C` 触发上一次执行的命令；
- 当匹配到唯一命令时可立即触发，默认关闭；
- 具体功能可以通过修改代码进一步微调。

## English Documentation

## Main Features
- **Minimal setup**: Just include **AHK QuickCommand.ahk** to use it. Automatically retrieves and displays available functions from your AHK script in a GUI.
- **Quick search**: Type to filter commands. Trigger by double-click or pressing Enter.

## Usage
1. Edit your existing AHK script and include `AHK QuickCommand.ahk` at the top of your main script like this: `#Include, C:\Desktop\AHK QuickCommand.ahk`
2. Save and run the script. Press `Capslock + C` to open the GUI.
3. Type to filter commands. Use arrow keys to navigate, and press `Enter` or double-click to execute the selected function.

## Custom Hotkeys
`AHK QuickCommand.ahk` only ships with the default public hotkeys. To keep personal shortcuts out of the distributable file, bind your own hotkeys in your main script after `#Include` and call `QuickCommandInvoke()`.

```AutoHotKey
#Include, C:\Desktop\AHK QuickCommand.ahk

F18::
    QuickCommandInvoke("F18")
return
```

The optional trigger name is used for double-press detection, so pressing the same custom hotkey twice can repeat the last executed command.

## Note
- Requires: AutoHotkey v1.1+
- Commands should be defined in the following format:

```AutoHotKey
; Example Commands
    ; To Exclude: change "func(){" to "func( ){"
ActionExample(){
    MsgBox, You selected Example!
    ; Replace with your custom function
}
```

- The `#Include, C:\Desktop\AHK QuickCommand.ahk` should be placed right after your startup scripts which automatically run after initializing.

## Extended Features
- Use `CapsLock+W/S/Space` as `Up/Down/Enter`;
- Use `CapsLock+C+C` to trigger last executed command;
- Trigger immediately when matched command is unique (Off by default);
- Specific features can be fine-tuned by modifying the code.
