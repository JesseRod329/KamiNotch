# Release Signing and Notarization

This project ships outside the Mac App Store, so distribution must use Developer ID signing plus notarization.

## GitHub Actions Secrets

Set these repository secrets before tagging a release:

- `MACOS_CERTIFICATE_P12_BASE64`: Base64-encoded `.p12` for your Developer ID Application certificate.
- `MACOS_CERTIFICATE_PASSWORD`: Password used when exporting the `.p12`.
- `MACOS_CERTIFICATE_NAME`: Full certificate identity as shown by `security find-identity -v -p codesigning`.
- `APPLE_ID`: Apple ID email for notarization.
- `APPLE_TEAM_ID`: Apple Developer Team ID.
- `APPLE_APP_SPECIFIC_PASSWORD`: App-specific password created for the Apple ID above.

Encode your exported `.p12` for `MACOS_CERTIFICATE_P12_BASE64`:

```bash
base64 -i DeveloperIDApplication.p12 | pbcopy
```

## CI Release Flow

Tagging `v*` triggers `.github/workflows/release-dmg.yml`. The workflow:

1. Imports the Developer ID certificate into a temporary keychain.
2. Builds `KamiNotch.app` and signs it with Hardened Runtime.
3. Packages `dist/KamiNotch.dmg`.
4. Stores notary credentials in the same keychain.
5. Submits DMG for notarization, waits for acceptance, staples the ticket.
6. Uploads notarized `KamiNotch.dmg` to the GitHub release.

## Local Verification Commands

After downloading a release artifact:

```bash
codesign --verify --deep --strict --verbose=2 /Applications/KamiNotch.app
spctl -a -vv /Applications/KamiNotch.app
xcrun stapler validate /path/to/KamiNotch.dmg
```

Or run the project helper:

```bash
scripts/verify-release.sh /Applications/KamiNotch.app /path/to/KamiNotch.dmg
```

## Local Notarization (Optional)

If you need to notarize manually on macOS:

```bash
xcrun notarytool store-credentials "KAMINOTCH_NOTARY" \
  --apple-id "you@example.com" \
  --team-id "TEAMID" \
  --password "app-specific-password"

chmod +x scripts/create-dmg.sh scripts/notarize-dmg.sh
VERSION="0.1.0" \
BUNDLE_SHORT_VERSION="0.1.0" \
BUNDLE_VERSION="0.1.0" \
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
OUTPUT_NAME="KamiNotch.dmg" \
scripts/create-dmg.sh

scripts/notarize-dmg.sh dist/KamiNotch.dmg
```
