#!/bin/sh
set -eu

cd "$(dirname "$0")"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

app="$build_dir/TimeCamp Reminder.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp Info.plist "$app/Contents/Info.plist"
cp AppIcon.icns Ghost.png ReminderChime.wav "$app/Contents/Resources/"

for arch in arm64 x86_64; do
    xcrun swiftc -O -target "$arch-apple-macosx13.0" -module-cache-path "$build_dir/cache" \
        main.swift -o "$build_dir/$arch"
done

executable="$app/Contents/MacOS/TimeCampReminder"
xcrun lipo -create "$build_dir/arm64" "$build_dir/x86_64" -output "$executable"
codesign --sign - "$app"
ditto -c -k --keepParent "$app" "TimeCamp Reminder.zip"
