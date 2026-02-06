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
NOTARY_WAIT_TIMEOUT="${NOTARY_WAIT_TIMEOUT:-30m}"
NOTARY_LOG_PATH="${NOTARY_LOG_PATH:-}"

if ! command -v xcrun >/dev/null 2>&1; then
  echo "error: xcrun is required (run on macOS with Xcode command line tools)" >&2
  exit 1
fi

NOTARY_ARGS=(--keychain-profile "$NOTARY_PROFILE")
if [[ -n "$NOTARY_KEYCHAIN" ]]; then
  NOTARY_ARGS+=(--keychain "$NOTARY_KEYCHAIN")
fi

echo "Submitting DMG for notarization..."
SUBMIT_JSON="$(
  xcrun notarytool submit "$DMG_PATH" "${NOTARY_ARGS[@]}" --output-format json
)"
SUBMISSION_ID="$(
  echo "$SUBMIT_JSON" | /usr/bin/python3 -c 'import json,sys; print(json.load(sys.stdin).get("id",""))'
)"

if [[ -z "$SUBMISSION_ID" ]]; then
  echo "error: failed to parse notarization submission id from notarytool response" >&2
  echo "$SUBMIT_JSON" >&2
  exit 1
fi

echo "Notary submission id: $SUBMISSION_ID"
echo "Waiting for notarization (timeout: $NOTARY_WAIT_TIMEOUT)..."
if ! xcrun notarytool wait "$SUBMISSION_ID" "${NOTARY_ARGS[@]}" --timeout "$NOTARY_WAIT_TIMEOUT"; then
  echo "warning: notarytool wait did not complete successfully; checking current submission state..." >&2
  INFO_JSON="$(
    xcrun notarytool info "$SUBMISSION_ID" "${NOTARY_ARGS[@]}" --output-format json 2>/dev/null || true
  )"
  STATUS=""
  if [[ -n "$INFO_JSON" ]]; then
    STATUS="$(
      echo "$INFO_JSON" | /usr/bin/python3 -c 'import json,sys; print(json.load(sys.stdin).get("status",""))' 2>/dev/null || true
    )"
  fi

  if [[ "$STATUS" == "Accepted" ]]; then
    echo "Notarization status is Accepted; continuing."
  else
    if [[ -n "$INFO_JSON" ]]; then
      echo "Current submission info:"
      echo "$INFO_JSON"
    fi

    if [[ -n "$NOTARY_LOG_PATH" ]]; then
      echo "Writing notary log to $NOTARY_LOG_PATH"
      xcrun notarytool log "$SUBMISSION_ID" "${NOTARY_ARGS[@]}" "$NOTARY_LOG_PATH" || true
    fi

    echo "error: notarization not complete/accepted. submission id: $SUBMISSION_ID" >&2
    echo "Use these commands to inspect later:" >&2
    echo "  xcrun notarytool info $SUBMISSION_ID --keychain-profile \"$NOTARY_PROFILE\"${NOTARY_KEYCHAIN:+ --keychain \"$NOTARY_KEYCHAIN\"}" >&2
    echo "  xcrun notarytool log $SUBMISSION_ID --keychain-profile \"$NOTARY_PROFILE\"${NOTARY_KEYCHAIN:+ --keychain \"$NOTARY_KEYCHAIN\"}" >&2
    exit 1
  fi
fi

if [[ -n "$NOTARY_LOG_PATH" ]]; then
  echo "Writing notary log to $NOTARY_LOG_PATH"
  xcrun notarytool log "$SUBMISSION_ID" "${NOTARY_ARGS[@]}" "$NOTARY_LOG_PATH" || true
fi

echo "Stapling notarization ticket..."
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"

echo "Notarized DMG ready: $DMG_PATH"
