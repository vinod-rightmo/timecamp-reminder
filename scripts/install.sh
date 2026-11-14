#!/bin/sh
set -eu

fail() {
    printf '%s\n' "$*" >&2
    exit 1
}

[ "$(uname -s)" = Darwin ] || fail "TimeCamp Reminder requires macOS."
macos_version="$(sw_vers -productVersion)"
[ "${macos_version%%.*}" -ge 13 ] || fail "TimeCamp Reminder requires macOS 13 or later."

app_name='TimeCamp Reminder.app'
applications="$HOME/Applications"
destination="$applications/$app_name"

for app in "/Applications/$app_name" "$destination"; do
    if [ -e "$app" ] || [ -L "$app" ]; then
        fail "TimeCamp Reminder is already installed at $app. Use its existing installation method to update it."
    fi
done

if ! xcrun --find swiftc >/dev/null 2>&1; then
    printf '%s\n' 'Install the Apple Command Line Tools in the dialog, then run this command again.'
    xcode-select --install
    exit 1
fi

repository='https://github.com/vinod-rightmo/timecamp-reminder.git'
version='v1.0.0'
revision='f1dceb15bb6ccfb1a3157607897ecc77b6cc6acd'

mkdir -p "$applications"
work="$(mktemp -d "$applications/.timecamp-install.XXXXXX")"
trap 'rm -rf "$work"' EXIT
trap 'exit 1' HUP INT TERM

printf '\n👻  TimeCamp Reminder · %s\n' "$version"
printf '    by Vinod Liyanage\n\n'

printf '    Downloading source from GitHub…\n'
git -c advice.detachedHead=false clone --quiet --depth 1 \
    --branch "$version" --single-branch "$repository" "$work/source"
[ "$(git -C "$work/source" rev-parse HEAD)" = "$revision" ] ||
    fail "The source release does not match the expected revision."
printf ' ✓  Download complete\n'

printf '    Building your little timekeeper…\n'
sh "$work/source/scripts/build.sh"
ditto -x -k "$work/source/dist/TimeCamp Reminder.zip" "$work"
codesign --verify --strict "$work/$app_name"

mv -n "$work/$app_name" "$destination"
[ ! -e "$work/$app_name" ] || fail "An app already exists at $destination."
printf ' ✓  Installed in ~/Applications\n'

printf '    Opening TimeCamp Reminder…\n'
open "$destination"
printf '\n    Go log those hours before they ghost you.\n\n'
