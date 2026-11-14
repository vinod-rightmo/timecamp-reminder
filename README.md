# TimeCamp Reminder

A small macOS menu bar app that reminds you to log time in TimeCamp after login, wake, or unlock. The reminder leaves the menu bar available so you can open TimeCamp, then dismiss it with **Done**.

## Install

Run this in Terminal to build the pinned release on your Mac, install it in your personal Applications folder, and open it.

```sh
/bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/vinod-rightmo/timecamp-reminder/HEAD/scripts/install.sh)"
```

The app requires macOS 13 or later and runs on Apple silicon and Intel. If macOS prompts you to install Apple's Command Line Tools, finish the installation and run the command again. You can [review the installer](scripts/install.sh) before running it.

Use the clock icon in the menu bar to set **Launch at Login** or **Play Chime**.

## Build

With the Xcode Command Line Tools installed, run `sh scripts/build.sh` from the repository root. The script creates `dist/TimeCamp Reminder.zip` with a universal app bundle.

- `Sources/` contains the AppKit entry point, reminder, and controls.
- `Resources/` contains the app icon, artwork, chime, and bundle metadata.
- `scripts/` contains the build and release commands.

## Release

On a Mac with the Xcode Command Line Tools and GitHub CLI, sign in to GitHub and run `gh auth setup-git --hostname github.com` once. Your account needs write access to this repository.

1. Bump both version fields in `Resources/Info.plist`, commit the release changes, and push to `main`.
2. Write the release notes in a Markdown file. These notes will appear on GitHub.
3. Run `sh scripts/release.sh /path/to/release-notes.md`.
4. Update the version and revision pinned in `scripts/install.sh` once the release is available.

The script builds and verifies the universal ZIP and publishes it to GitHub Releases. If a publication step fails, rerun the same command. The script reuses and verifies an existing release asset.
