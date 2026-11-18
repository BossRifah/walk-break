# Walk Break

A macOS menu-bar timer that alternates 40 minutes of work with a 5-minute movement break. The pixel-art rabbit types during work and hops during the break.

The break window opens automatically at both transitions. Closing it leaves the countdown running. Each break shows three movement ideas, rotating through all 35 combinations of the seven activities.

## Build on macOS

Walk Break runs on macOS 13 or later. The build needs Apple's Xcode Command Line Tools and produces a universal app for Apple silicon and Intel Macs.

```sh
bash build.sh
open "build/Walk Break.app"
```

## Use the app

1. Click the walking-person icon in the menu bar and switch Walk Break on.
2. Allow notifications when macOS asks.
3. Leave the app running to repeat the cycle. Switch it off to stop and reset the timer.

To try both pop-ups quickly, switch Walk Break off and click **Test cycle · 25 sec**. The test starts a 20-second movement break after 5 seconds and then begins a regular work session.

## Install on Windows

The Windows version lives in the `windows` folder. It runs on Windows 10 and Windows 11 and uses Windows PowerShell 5.1, which every copy of Windows 10 and 11 already includes. You don't need to install Python, Node.js, Visual Studio, or administrator rights.

The Windows app works like the macOS one. A rabbit icon sits in the system tray (the area next to the clock), the timer alternates 40 minutes of work with a 5-minute movement break, and a break window opens in the bottom-right corner at both transitions. Closing that window leaves the countdown running.

### Step 1: download the files

1. Open this repository on GitHub.
2. Click the green **Code** button, then click **Download ZIP**.
3. Open your Downloads folder, right-click the ZIP file, and choose **Extract All**. Click **Extract**.
4. Open the extracted folder, then open the `windows` folder inside it. It should contain `Install.cmd`, `install.ps1`, `WalkBreak.ps1`, `Uninstall.cmd`, and `uninstall.ps1`.

If you use Git, you can clone the repository instead:

```powershell
git clone https://github.com/BossRifah/walk-break.git
cd walk-break\windows
```

### Step 2: run the installer

1. Double-click `Install.cmd`.
2. Windows may show a security warning because the file came from the internet. Click **Run** (or **More info**, then **Run anyway**).
3. A black installer window opens. When it asks whether Walk Break should start automatically when you sign in, type `Y` or `N` and press Enter.
4. When the window says the installation is complete, press any key to close it.

The installer copies Walk Break to `%LOCALAPPDATA%\Programs\WalkBreak`, adds a **Walk Break** shortcut to the Start menu, and opens the app.

If double-clicking doesn't work on your computer, open PowerShell in the `windows` folder and run this command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

### Step 3: find the tray icon

Look for the rabbit icon next to the clock on the taskbar. On Windows 11 (and on Windows 10 with many tray icons), it is often hidden inside the **^** overflow arrow.

To keep the icon visible at all times, drag it from the overflow area onto the taskbar. On Windows 11 you can also open **Settings > Personalization > Taskbar > Other system tray icons** and switch on the entry for Walk Break. Windows may list it as **Windows PowerShell**, because PowerShell runs the app.

### Step 4: use the app

1. Left-click the rabbit icon to open the Walk Break panel.
2. Click **OFF** in the top-right corner of the panel to switch Walk Break on. The rabbit starts typing and the 40-minute countdown begins.
3. Leave the app running to repeat the cycle. Click **ON** to switch it off and reset the timer.

To try both pop-ups quickly, switch Walk Break off and click **Test cycle · 25 sec**. The test starts a 20-second movement break after 5 seconds and then begins a regular work session.

You can also right-click the rabbit icon for a menu with **Turn on**, **Turn off**, **Test cycle**, and **Quit**. Press Esc to close the panel, or Ctrl+Q to quit while the panel is open.

### Notifications

Walk Break shows a Windows notification when each break starts and ends. These notifications appear under the name **Windows PowerShell**. If you don't see them, check that notifications are on in **Settings > System > Notifications**, and that Do Not Disturb (Focus Assist on Windows 10) is off. The break window still opens even when notifications are blocked.

### Start Walk Break when you sign in

If you skipped this during installation, run the installer again and type `Y` at the prompt. You can also run this command in the `windows` folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -StartWithWindows
```

To stop it from starting automatically, run the installer again and type `N`.

### Update to a newer version

Download the latest files from GitHub and run `Install.cmd` again. The installer closes the running copy, replaces it, and keeps your movement rotation.

### Uninstall

Double-click `Uninstall.cmd` in the `windows` folder. It closes Walk Break, removes the Start menu and sign-in shortcuts, and deletes the app and its saved settings. To keep the saved movement rotation, run this command instead:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\uninstall.ps1 -KeepSettings
```

### Troubleshooting

**Nothing happens after installation.** Check the tray overflow area first (see step 3). If the icon isn't there, open Walk Break from the Start menu. Only one copy runs at a time, so opening it twice does nothing.

**A script error mentions execution policy.** Use `Install.cmd` or the command in step 2. Both run the installer with a one-time policy bypass and don't change your system settings.

**The app closes or behaves oddly.** Walk Break writes errors to `%APPDATA%\WalkBreak\walkbreak.log`. Paste that path into the File Explorer address bar to open it, and include the log when you report an issue.

**The rabbit doesn't animate.** Walk Break respects the Windows animation setting, like Reduce Motion on macOS. If **Settings > Accessibility > Visual effects > Animation effects** is off, the rabbit hops in place during breaks and stays still at the desk.
