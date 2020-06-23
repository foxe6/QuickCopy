# QuickCopy
This page is copied from http://web.archive.org/web/20160827113406/https://autohotkey.com/board/topic/54600-quickcopy-v01-accumulate-text-copied-to-the-clipboard/.

## Introduction
QuickCopy is a simple utility that allows you to copy many times and paste (using Win+V) once.


# QuickCopy
## Key features:
Auto-Format. All clips are formated so that they will be pasted on separate lines. Interpretation: End-Of-Line characters (CR+LR) are added if/where needed.

Auto-Reset. After the Paste command (Win+V) is used, the copy buffer is automatically cleared the next time text is copied to the clipboard.

Timeout. The program will automatically disable itself after a period of inactivity. The initial timeout period is 120 seconds (2 minutes) but it can be set to any value.

Tooltips, TrayTips. Tooltips and/or TrayTips are shown on key events. [Optional] By default, Tooltips are disabled and TrayTips are enabled.

Sounds. Unique sounds are played on key events. [Optional]

Tray icon. The tray icon shows the current status and is used to set program options. The tooltip for the tray icon is also updated with pertinent information.

Quick Enable/Disable. Double-click on the tray icon to quickly enable or disable the utility.
```Screenshots
Copy:
Posted Image
Paste:
Posted Image
```

## The Code
The pertinent files are as follows:

Project: QuickCopy.zip (Includes source, EXE, and resource files (icons and sounds)

Documentation/Help: Nothing official yet. See the Usage Notes section (below) for guidance.

## Usage Notes

A few notes/tips:

Copy. To copy, use the standard methods -- Ctrl+C, Ctrl+X, context menu, etc. Every time text is copied to the clipboard, the program will show a tooltip and/or TrayTip (if enabled), play a sound (if enabled), and append the copied text to the copy buffer.

Paste. After all copy requests have been made, use Win+V to paste the collection of copied text to any application. If needed, Win+V can be used multiple times. If the Paste command is selected from the tray context menu, an instruction message will precede the paste operation.

Tray icon. In addition to being used to set program options, the tray icon shows the following statuses:

Posted Image Enabled. This icon is seen when the application first starts and after the Clear command is used.

Posted Image Active. This icon is seen after text has been copied to the clipboard but before the Paste command is used.

Posted Image Reset. This icon is seen after the Paste command is used. It indicates that the copy buffer will automatically be cleared the next time text is copied to the clipboard.

Posted Image Disabled. This icon is seen when the program is disabled.
Clear. The Clear command deletes (clears) the copy buffer so that the next copy request starts with an empty buffer. Under most circumstances, this command is not needed because after the Paste (Win+V) command is used, the copy buffer is automatically cleared the next time text is copied to the clipboard.

Disable. Since the program only monitors the clipboard (Exception: Special commands), it is unlikely that it will interfere with any other utilities, keyboard shortcuts, or scripts that update the clipboard. However, since the default behavior is to show tooltips and/or TrayTips and play a sound when text is copied to the clipboard, it's best to disable the program when not in use.[/list]Issues/Considerations
A few considerations:
Preview release. Since this a preview release, some of the code has not been optimized and there may be some residual debug code lying around. If there is any interest, these issues will be corrected in future releases.

Paste. The paste operation (Win+V) has only been tested on a small number of applications. Since this command actually sends the Ctrl+V characters to initiate a paste operation, there will undoubtedly be applications where this command will not work.

Sounds. Some of the event sounds are good but a few are not great. If I find any better alternatives, I will make an update. If you have some specific sounds to recommend, please make a noise. If you want to disable some but not all of the sounds, just delete or rename the undesired sound file(s).Final Thoughts
I've been using this program for about a week now. I've found it very useful when I needed it. I've also discovered that when left enabled, it is very annoying when I copied text to the clipboard but wasn't expecting the program to to be active. Be sure to disable the program when not in use. Setting a fairly low timeout period is also a good idea.

```I hope that someone finds this useful.```

---------------------------------------------------------------------------
# Release Notes

v0.1 (Preview)
Original release.
