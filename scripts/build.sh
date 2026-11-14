#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

app="$build_dir/TimeCamp Reminder.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"

cp Resources/Info.plist "$app/Contents/Info.plist"
cp Resources/AppIcon.icns Resources/Ghost.png Resources/ReminderChime.wav "$app/Contents/Resources/"

for arch in arm64 x86_64; do
    xcrun swiftc -O -target "$arch-apple-macosx13.0" -module-cache-path "$build_dir/cache" \
        Sources/*.swift -o "$build_dir/$arch"
done

executable="$app/Contents/MacOS/TimeCampReminder"
xcrun lipo -create "$build_dir/arm64" "$build_dir/x86_64" -output "$executable"
codesign --sign - "$app"

mkdir -p dist
ditto -c -k --keepParent "$app" "dist/TimeCamp Reminder.zip"
