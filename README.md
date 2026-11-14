# TimeCamp Reminder

A small macOS menu bar app that reminds you to log time in TimeCamp after login, wake, or unlock. The reminder leaves the menu bar available so you can open TimeCamp, then dismiss it with **Done**.

## Install

```sh
brew install --cask vinod-rightmo/tap/timecamp-reminder
```

Open **TimeCamp Reminder** from Applications. The clock icon in the menu bar has **Launch at Login** and **Play Chime** controls. For a manual install, use the ZIP from the [public release](https://github.com/vinod-rightmo/homebrew-tap/releases/latest).

The app requires macOS 13 or later and runs on Apple silicon and Intel Macs. See the [public tap](https://github.com/vinod-rightmo/homebrew-tap) for first launch and upgrade instructions.

## Build

With the Xcode Command Line Tools installed, run `sh build.sh` from the repository root. The script creates `TimeCamp Reminder.zip` with a universal app bundle.

## Release

On a Mac with the Xcode Command Line Tools and GitHub CLI, sign in to GitHub and run `gh auth setup-git --hostname github.com` once. Your account needs write access to this repository and the public tap.

1. Bump both version fields in `Info.plist`, commit the release changes, and push to `main`.
2. Write the release notes in a Markdown file. These notes will be public.
3. Run `sh release.sh /path/to/release-notes.md`.

The script builds and verifies the universal ZIP, creates the private release, mirrors its ZIP to the public release, and updates the tap's cask version and checksum. If a publication step fails, rerun the same command. Existing release assets are reused and verified. Users get the update with `brew update` and `brew upgrade --cask vinod-rightmo/tap/timecamp-reminder`.
