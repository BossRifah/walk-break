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
