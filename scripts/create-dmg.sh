#!/usr/bin/env bash
set -euo pipefail

APP_NAME="KamiNotch"
BUNDLE_ID="com.jesserod329.kaminotch"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CODESIGN_IDENTITY="${CODESIGN_IDENTITY:-}"

VERSION="${VERSION:-}"
if [[ -z "$VERSION" ]]; then
  VERSION="$(git -C "$REPO_DIR" describe --tags --always --dirty 2>/dev/null || git -C "$REPO_DIR" rev-parse --short HEAD)"
fi
BUNDLE_SHORT_VERSION="${BUNDLE_SHORT_VERSION:-$VERSION}"
BUNDLE_VERSION="${BUNDLE_VERSION:-$VERSION}"

OUTPUT_DIR="${OUTPUT_DIR:-$REPO_DIR/dist}"
OUTPUT_NAME="${OUTPUT_NAME:-${APP_NAME}-${VERSION}.dmg}"
OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_NAME"

APP_BUNDLE="$REPO_DIR/.build/${APP_NAME}.app"
STAGING_DIR="$REPO_DIR/.build/dmg-root"
BINARY_PATH="$REPO_DIR/.build/release/$APP_NAME"

if ! command -v swift >/dev/null 2>&1; then
  echo "error: swift is required" >&2
  exit 1
fi

if ! command -v hdiutil >/dev/null 2>&1; then
  echo "error: hdiutil is required (run on macOS)" >&2
  exit 1
fi

if [[ -n "$CODESIGN_IDENTITY" ]]; then
  if [[ ! "$BUNDLE_SHORT_VERSION" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
    echo "error: BUNDLE_SHORT_VERSION must be numeric when CODESIGN_IDENTITY is set (got: $BUNDLE_SHORT_VERSION)" >&2
    exit 1
  fi
  if [[ ! "$BUNDLE_VERSION" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
    echo "error: BUNDLE_VERSION must be numeric when CODESIGN_IDENTITY is set (got: $BUNDLE_VERSION)" >&2
    exit 1
  fi
fi

echo "Building release binary..."
swift build -c release --product "$APP_NAME" --package-path "$REPO_DIR"

if [[ ! -f "$BINARY_PATH" ]]; then
  echo "error: expected binary not found at $BINARY_PATH" >&2
  exit 1
fi

echo "Preparing app bundle..."
rm -rf "$APP_BUNDLE" "$STAGING_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"
cp "$BINARY_PATH" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>${BUNDLE_ID}</string>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${BUNDLE_SHORT_VERSION}</string>
  <key>CFBundleVersion</key>
  <string>${BUNDLE_VERSION}</string>
  <key>LSMinimumSystemVersion</key>
  <string>15.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

if command -v codesign >/dev/null 2>&1; then
  if [[ -n "$CODESIGN_IDENTITY" ]]; then
    echo "Signing app with Developer ID identity..."
    codesign --force --deep --options runtime --timestamp --sign "$CODESIGN_IDENTITY" "$APP_BUNDLE"
    codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
  else
    echo "Applying ad-hoc code signature (dev build)..."
    if ! codesign --force --deep --sign - "$APP_BUNDLE"; then
      echo "warning: ad-hoc codesign failed; continuing" >&2
    fi
  fi
fi

echo "Assembling DMG staging folder..."
mkdir -p "$STAGING_DIR"
cp -R "$APP_BUNDLE" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_PATH"

echo "Creating DMG at $OUTPUT_PATH..."
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$OUTPUT_PATH" >/dev/null

echo "DMG ready: $OUTPUT_PATH"
