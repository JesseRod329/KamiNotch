#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:-}"
DMG_PATH="${2:-}"

if [[ -z "$APP_PATH" ]]; then
  echo "usage: $0 <path-to-app> [path-to-dmg]" >&2
  exit 1
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "error: app bundle not found at $APP_PATH" >&2
  exit 1
fi

echo "Verifying app signature integrity..."
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

echo "Printing signing identity..."
codesign -dv --verbose=4 "$APP_PATH" 2>&1 | sed -n '1,40p'

echo "Checking Gatekeeper assessment..."
spctl -a -vv "$APP_PATH"

if [[ -n "$DMG_PATH" ]]; then
  if [[ ! -f "$DMG_PATH" ]]; then
    echo "error: dmg not found at $DMG_PATH" >&2
    exit 1
  fi
  echo "Validating stapled notarization ticket..."
  xcrun stapler validate "$DMG_PATH"
fi

echo "Release verification checks passed."
