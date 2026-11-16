#!/bin/bash
set -euo pipefail

source_dir="$(cd "$(dirname "$0")" && pwd)"
output_dir="${1:-$source_dir/build}"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

mkdir -p "$output_dir"
module_cache="${WALK_BREAK_MODULE_CACHE:-$build_dir/module-cache}"
app="$build_dir/Walk Break.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$source_dir/Info.plist" "$app/Contents/Info.plist"

xcrun swift -module-cache-path "$module_cache" \
    "$source_dir/MakeIcon.swift" "$app/Contents/Resources/WalkBreak.icns"

for architecture in arm64 x86_64; do
    xcrun swiftc -module-cache-path "$module_cache" \
        -target "$architecture-apple-macosx13.0" -O -warnings-as-errors \
        "$source_dir/BreakCycle.swift" "$source_dir/MovementRotation.swift" \
        "$source_dir/BreakPanel.swift" "$source_dir/PixelMeadow.swift" "$source_dir/WalkBreakApp.swift" \
        -o "$build_dir/WalkBreak-$architecture"
done

xcrun lipo -create "$build_dir/WalkBreak-arm64" "$build_dir/WalkBreak-x86_64" \
    -output "$app/Contents/MacOS/WalkBreak"
codesign --force --sign - "$app"
codesign --verify --strict "$app"
ditto "$app" "$output_dir/Walk Break.app"
