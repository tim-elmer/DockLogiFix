#Requires AutoHotkey v2.0-

; **** SETTINGS ****

; Timeout for window spawn. Keep high, as the window may take a bit to spawn after the process does.
global TIMEOUT := 10240

; Path to software to restart.
global PATH := EnvGet("ProgramFiles") . "\Logitech Gaming Software\LCore.exe"

; Name of executable to kill.
global PROCESS_NAME := "LCore.exe"

; Name of window to close.
global WINDOW_NAME := "Logitech Gaming Software"

; **** END SETTINGS ****

HandleWmDisplayChanged(wParam, lParam, msg, hwnd) {
	OutputDebug("Display state changed.")
	CurrentDockState := MonitorGetCount() > 1
	DockStateDiff := CurrentDockState !== DockState
	global DockState := CurrentDockState

	; If not connected, no point in proceeding
	if (!CurrentDockState) {
	    OutputDebug("Not docked, returning to background.")
		return 0
	}
	; Only restart if dock state has changed
	if (DockStateDiff) {
        OutputDebug("Dock state changed, restarting.")
		SetTimer(Restart, -1)	; Start new thread to avoid blocking WM's
	}
    else
        OutputDebug("Dock state unchanged, returning to background.")
    return 0
}

/*
    Restarts Logitech Gaming Software
 */
Restart()
{
    ; PID of software
    Pid := -1

    OutputDebug("Closing software...")
    if (ProcessExist(PROCESS_NAME)) {
        loop {  ; * Close loop
            Pid := ProcessClose(PROCESS_NAME)
    
            ; If software didn't close, prompt user to retry
            if (!Pid && MsgBox("Failed to close process " . Pid, "Process Not Closed", "RetryCancel Iconx") !== "Retry")
                break
        } until Pid
    }

    OutputDebug("Starting software...")
    loop {  ; * Run loop
        Run(PATH, , &Pid)

        ; If software didn't start, prompt user to retry
        if (!Pid && MsgBox("Failed to start Logitech Gaming Software", "Process Not Started", "RetryCancel Iconx") !== "Retry")
            break
    } until Pid

    ; Unfortunately, LGS ignores the "Hide" option
    OutputDebug("Waiting for software window to spawn...")
    if (WinWait(WINDOW_NAME, , TIMEOUT))
        WinClose(WINDOW_NAME)
    OutputDebug("Done.")
}

; **** Startup ****
OutputDebug("Starting...")

global WM_DISPLAYCHANGE := 0x007E
global DockState := MonitorGetCount() > 1
NoRestart := false

Loop A_Args.Length {
	if (A_Args[A_Index] = "-NoRestart") {
        NoRestart := true
		break
	}
}
if (!NoRestart)
    Restart()    ; Assume it isn't working when the script is first started, because we don't have a good way to check.

; Hook display size change message
OnMessage(WM_DISPLAYCHANGE, HandleWmDisplayChanged)
Persistent()
