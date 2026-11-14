#!/bin/sh
set -eu

notes="$PWD/${1:-}"
case "${1:-}" in
    /*) notes="$1" ;;
esac

fail() {
    printf '%s\n' "$*" >&2
    exit 1
}

[ "$#" -eq 1 ] && [ -f "$notes" ] || fail "Usage: sh scripts/release.sh <release-notes.md>"
cd "$(dirname "$0")/.."

source_repo=vinod-rightmo/timecamp-reminder
tap_repo=vinod-rightmo/homebrew-tap
asset=TimeCamp-Reminder.zip
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)"
tag="v$version"
commit="$(git rev-parse HEAD)"

[ -z "$(git status --porcelain)" ] || fail "Commit the release changes first."
remote_commit="$(gh api "repos/$source_repo/commits/main" --jq .sha)"
[ "$remote_commit" = "$commit" ] ||
    fail "Push this commit to main before releasing."

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
git clone --quiet "https://github.com/$tap_repo.git" "$work/tap"
cask="$work/tap/Casks/timecamp-reminder.rb"
published_version="$(awk -F '"' '/^  version / { print $2 }' "$cask")"
[ "$(printf '%s\n' "$published_version" "$version" | sort -V | tail -n 1)" = "$version" ] ||
    fail "Homebrew already offers the newer version $published_version."

release_exists() {
    if gh api "repos/$1/releases/tags/$tag" >"$work/release.json" 2>"$work/release-error"; then
        return 0
    fi
    if grep -q 'HTTP 404' "$work/release-error"; then
        return 1
    fi

    cat "$work/release-error" >&2
    fail "Could not check $1 for release $tag."
}

if release_exists "$source_repo"; then
    source_published=true
    gh release download "$tag" --repo "$source_repo" --pattern "$asset" --dir "$work"
else
    source_published=false
    mkdir "$work/source"
    git archive "$commit" | tar -x -C "$work/source"
    sh "$work/source/scripts/build.sh"
    mv "$work/source/dist/TimeCamp Reminder.zip" "$work/$asset"
fi

ditto -x -k "$work/$asset" "$work/verified"
app="$work/verified/TimeCamp Reminder.app"
[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist")" = "$version" ] ||
    fail "The ZIP does not contain version $version."
codesign --verify --strict "$app"
xcrun lipo "$app/Contents/MacOS/TimeCampReminder" -verify_arch arm64 x86_64
checksum="$(shasum -a 256 "$work/$asset" | cut -d ' ' -f 1)"

if [ "$source_published" = false ]; then
    gh release create "$tag" "$work/$asset" --repo "$source_repo" --target "$commit" \
        --title "TimeCamp Reminder $version" --notes-file "$notes"
fi

if ! release_exists "$tap_repo"; then
    gh release create "$tag" "$work/$asset" --repo "$tap_repo" --target main \
        --title "TimeCamp Reminder $version" --notes-file "$notes"
fi

public_checksum="$(gh api "repos/$tap_repo/releases/tags/$tag" \
    --jq ".assets[] | select(.name == \"$asset\") | .digest")"
[ "$public_checksum" = "sha256:$checksum" ] ||
    fail "The tap release asset does not match the source release."

sed -i '' -e "s/^  version .*/  version \"$version\"/" \
    -e "s/^  sha256 .*/  sha256 \"$checksum\"/" "$cask"
ruby -c "$cask"

if ! git -C "$work/tap" diff --quiet; then
    git -C "$work/tap" add Casks/timecamp-reminder.rb
    git -C "$work/tap" -c user.email=300719421+vinod-rightmo@users.noreply.github.com \
        commit -m "Update TimeCamp Reminder to $version"
    git -C "$work/tap" push origin main
fi

printf 'Release %s is available through Homebrew.\n' "$tag"
