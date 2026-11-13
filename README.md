# TimeCamp Reminder

A small macOS menu bar app that reminds you to log time in TimeCamp after login, wake, or unlock. The reminder leaves the menu bar available so you can open TimeCamp, then dismiss it with **Done**.

## Install

1. Download **TimeCamp-Reminder.zip** from [Releases](https://github.com/vinod-rightmo/timecamp-reminder/releases/latest).
2. Unzip it and move **TimeCamp Reminder.app** to **Applications**. If you are updating, quit the old copy and choose **Replace** when Finder asks.
3. Open the app. Use its clock menu bar icon to turn on **Launch at Login** or toggle **Play Chime**.

The app requires macOS 13 or later and runs on Apple silicon and Intel Macs. It reminds you to log time manually in TimeCamp.

## Build

With the Xcode Command Line Tools installed, run `sh build.sh` from the repository root. The script creates `TimeCamp Reminder.zip` with a universal app bundle.
