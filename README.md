# DockLogiFix
Restarts <a name="lgs"></a>Logitech Gaming Software (LGS) when the number of monitors changes, because apparently Logitech didn't consider that someone might use a gaming keyboard with a laptop dock. 🤦‍♂️

## Requirements
- [AutoHotkey v2](https://www.autohotkey.com/v2)
- [Logitech Gaming Software](https://support.logi.com/hc/en-gb/articles/360025298053-Logitech-Gaming-Software) (duh)
- At least one monitor connected to the dock (see [Dock State Detection](#dock-state-detection))

## Usage
Run the script. That's it. You may want to consider setting the script to run at startup, either via a shortcut in `%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup` or via a scheduled task.

### Arguments
`-NoRestart`: By default, the script will restart [LGS](#lgs) once at launch, regardless of if it needs to be. This is because there is no trivial way to determine if [LGS](#lgs) has lost communication with its peripherals. This flag will suppress this behavior, and [LGS](#lgs) will only be restarted if necessary when the docking state next changes.

### Configuration
> 💡 TIP: For most intents and purposes, the defaults should be fine. Only tweak these if something isn't working.

Settings are defined at the beginning of the script as follows:

| Setting | Type | Default | Description |
| ---: | --- | --- | --- |
| `TIMEOUT` | Integer | `10240` | The number of milliseconds (roughly) that the script will wait for [LGS](#lgs) to spawn its UI window after the process is started.<br><br>This should be kept fairly high, as the window may take a bit to show up and there isn't much benefit to having a super short timeout (the timeout is at the end of a thread's function and will be bypassed completely if the window spawns sooner). |
| `PATH` | String | `EnvGet("ProgramFiles") . "\Logitech Gaming Software\LCore.exe"` | The path to the [LGS](#lgs) executable. Used to restart it.<br><br>Change this if you have [LGS](#lgs) installed elsewhere. |
| `PROCESS_NAME` | String | `LCore.exe` | The name of [LGS](#lgs)'s process. |
| `WINDOW_NAME` | String | `Logitech Gaming Software` | The *title* of the window spawned by [LGS](#lgs). |

## Miscellanea
### Dock State Detection
Windows offers a subscribable message that is sent when the computer's docked state changes. This script doesn't use it. Why? On my system (Lenovo ThinkPad T15 g1), at least, this message isn't triggered by the dock. Instead, the script assumes that someone using a laptop with a dock will have *at least* two monitors, as Windows also offers a message when the virtual display width changes.

If you use a dock *without* an extra monitor, why? On a more serious note, it should be possible to use another message, such as `WM_DEVICECHANGE` (`0x0219`) to detect the state change, but you'll need to use [`DllCall`](https://lexikos.github.io/v2/docs/commands/DllCall.htm) to call [`SetupDiEnumDeviceInterfaces`](https://learn.microsoft.com/en-us/windows/win32/api/setupapi/nf-setupapi-setupdienumdeviceinterfaces) and [`SetupDiGetDeviceInterfaceDetailA`](https://learn.microsoft.com/en-us/windows/win32/api/setupapi/nf-setupapi-setupdigetdeviceinterfacedetaila) to check if a device exclusive to the dock is connected (hence this method not being used).
