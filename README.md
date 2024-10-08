## AHK-QuickCommand
**AHK QuickCommand** is a plug-and-play AutoHotkey snippet that enables you to instantly search and execute already-existing functions or commands in your scripts with minimal setup.

<div align=center>
<img src="https://github.com/user-attachments/assets/5f9f79d5-e683-48f3-92cf-bd712c4d09df" width="300px" style="margin-right:auto; margin-left:auto">
</div>
  
<p align="center">
  <img src="https://github.com/user-attachments/assets/b41f1d36-4f1f-4d52-b272-09c25d1c4d07" alt="Gif 1" style="display: inline-block; margin-right: 10px;" width="200px"/>
  <img src="https://github.com/user-attachments/assets/fa32ecbf-8669-4648-9019-9fe9dad8c125" alt="Gif 2" style="display: inline-block; margin-right: 10px;" width="200px"/>
  <img src="https://github.com/user-attachments/assets/bf8c0055-f95c-4873-906b-57f89356571e" alt="Gif 3" style="display: inline-block;" width="200px"/>
</p>

## Main Features
- **Minimal setup**: Just include **AHK QuickCommand.ahk** to use it. Automatically retrieves and displays available functions from your AHK script in a GUI.
- **Quick search**: Type to filter commands. Trigger by double-click or pressing Enter.

## Usage
1. Edit your existing AHK script and include `AHK QuickCommand.ahk` at the top of your main script like this: `#Include, C:\Desktop\AHK QuickCommand.ahk`
2. Save and run the script. Press `Capslock + C` to open the GUI.
3. Type to filter commands. Use arrow keys to navigate, and press `Enter` or double-click to execute the selected function.

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
- The `#Include, C:\Desktop\AHK QuickCommand.ahk` should be placed right after your  startup scripts which automatically run after initializing.

## Extended Features
- Use `CapsLock+W/S/Space` as `Up/Down/Enter`;
- Use `CapsLock+C+C` to trigger last excuted command;
- Trigger immediately when matched command is unique (Off by default);
- Specific features can be fine-tuned by modifying the code.
