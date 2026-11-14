# TimeCamp Reminder

A small macOS menu bar app that reminds you to log time in TimeCamp after login, wake, or unlock. The reminder leaves the menu bar available so you can open TimeCamp, then dismiss it with **Done**.

## Install

```sh
brew install --cask vinod-rightmo/tap/timecamp-reminder
```

Open **TimeCamp Reminder** from Applications. The clock icon in the menu bar has **Launch at Login** and **Play Chime** controls. For a manual install, use the ZIP from the [public release](https://github.com/vinod-rightmo/homebrew-tap/releases/latest).

The app requires macOS 13 or later and runs on Apple silicon and Intel Macs. See the [public tap](https://github.com/vinod-rightmo/homebrew-tap) for first launch and upgrade instructions.

### One-command install from source

Run this in Terminal to build the pinned release on your Mac and install it in your personal Applications folder. This uses Apple's Command Line Tools and needs no Homebrew or GitHub account.

```sh
installer="$(curl -fsSL https://raw.githubusercontent.com/vinod-rightmo/timecamp-reminder/main/scripts/install.sh)" && /bin/sh -c "$installer"
```

If macOS prompts you to install the Command Line Tools, let the installation finish and rerun the command. You can [review the installer](scripts/install.sh) before running it. This installs a local build while leaving macOS security settings in place.

## Build

With the Xcode Command Line Tools installed, run `sh scripts/build.sh` from the repository root. The script creates `dist/TimeCamp Reminder.zip` with a universal app bundle.

- `Sources/` contains the AppKit entry point, reminder, and controls.
- `Resources/` contains the app icon, artwork, chime, and bundle metadata.
- `scripts/` contains the build and release commands.

## Release

On a Mac with the Xcode Command Line Tools and GitHub CLI, sign in to GitHub and run `gh auth setup-git --hostname github.com` once. Your account needs write access to this repository and the public tap.

1. Bump both version fields in `Resources/Info.plist`, commit the release changes, and push to `main`.
2. Write the release notes in a Markdown file. These notes will be public.
3. Run `sh scripts/release.sh /path/to/release-notes.md`.
4. Update the version and revision pinned in `scripts/install.sh` once the release is available.

The script builds and verifies the universal ZIP, publishes it to the source and tap releases, and updates the tap's cask version and checksum. If a publication step fails, rerun the same command. The script reuses and verifies existing release assets. Users get the update with `brew update` and `brew upgrade --cask vinod-rightmo/tap/timecamp-reminder`.
