#!/usr/bin/env bash
set -euo pipefail

DMG_PATH="${1:-}"
if [[ -z "$DMG_PATH" ]]; then
  echo "usage: $0 <path-to-dmg>" >&2
  exit 1
fi

if [[ ! -f "$DMG_PATH" ]]; then
  echo "error: dmg not found at $DMG_PATH" >&2
  exit 1
fi

NOTARY_PROFILE="${NOTARY_PROFILE:-KAMINOTCH_NOTARY}"
NOTARY_KEYCHAIN="${NOTARY_KEYCHAIN:-}"

if ! command -v xcrun >/dev/null 2>&1; then
  echo "error: xcrun is required (run on macOS with Xcode command line tools)" >&2
  exit 1
fi

NOTARY_ARGS=(--keychain-profile "$NOTARY_PROFILE")
if [[ -n "$NOTARY_KEYCHAIN" ]]; then
  NOTARY_ARGS+=(--keychain "$NOTARY_KEYCHAIN")
fi

echo "Submitting DMG for notarization..."
xcrun notarytool submit "$DMG_PATH" "${NOTARY_ARGS[@]}" --wait

echo "Stapling notarization ticket..."
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"

echo "Notarized DMG ready: $DMG_PATH"
