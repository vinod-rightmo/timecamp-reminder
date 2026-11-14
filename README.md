# TimeCamp Reminder

A small macOS menu bar app that reminds you to log time in TimeCamp after login, wake, or unlock. The reminder leaves the menu bar available so you can open TimeCamp, then dismiss it with **Done**.

## Install

1. Download **TimeCamp-Reminder.zip** from [Releases](https://github.com/vinod-rightmo/timecamp-reminder/releases/latest).
2. Unzip it and move **TimeCamp Reminder.app** to **Applications**. If you are updating, quit the old copy and choose **Replace** when Finder asks.
3. Open the app. Use its clock menu bar icon to turn on **Launch at Login** or toggle **Play Chime**.

The app requires macOS 13 or later and runs on Apple silicon and Intel Macs. It reminds you to log time manually in TimeCamp.

## Install with Homebrew

The tap and release ZIP are private. Update Homebrew and sign in with a GitHub account that can read this repository.

```sh
gh auth login --hostname github.com
gh auth setup-git --hostname github.com
brew tap vinod-rightmo/timecamp-reminder https://github.com/vinod-rightmo/timecamp-reminder.git
brew trust --cask vinod-rightmo/timecamp-reminder/timecamp-reminder
HOMEBREW_GITHUB_API_TOKEN="$(gh auth token --hostname github.com)" brew install --cask vinod-rightmo/timecamp-reminder/timecamp-reminder
```

If the same version is already in Applications, add `--adopt` to the install command. To upgrade, run `brew update`, then use the same token prefix with `brew upgrade --cask vinod-rightmo/timecamp-reminder/timecamp-reminder`.

When publishing a new release, update the cask's version, GitHub release asset ID, and ZIP checksum.

## Build

With the Xcode Command Line Tools installed, run `sh build.sh` from the repository root. The script creates `TimeCamp Reminder.zip` with a universal app bundle.
