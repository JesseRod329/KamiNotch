# KamiNotch

![License](https://img.shields.io/github/license/JesseRod329/KamiNotch)
![Platform](https://img.shields.io/badge/platform-macOS-111111)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen)
[![Download for macOS](https://img.shields.io/badge/Download-macOS_DMG-007AFF?style=for-the-badge&logo=apple)](https://github.com/JesseRod329/KamiNotch/releases/latest/download/KamiNotch.dmg)

KamiNotch is a menubar-only macOS terminal HUD that drops from the notch with a clean liquid-glass look. It keeps your shell running when collapsed, so you can pop it open and keep working.

**Status**
Alpha. Core HUD, hotkey, terminal, workspaces, themes, and DMG packaging are implemented.

- Official GitHub releases are intended to be **Developer ID signed + notarized + stapled**.
- Local builds are development artifacts and are not intended for end-user distribution.

- Design doc: `docs/plans/2026-02-05-macos-liquid-glass-terminal-hud-design.md`

**Current Features**
- Menubar toggle and global hotkey.
- Built-in terminal (SwiftTerm) with local shell.
- Tabs grouped into workspaces, persisted to JSON.
- Liquid-glass theming with presets and custom controls.
- Size presets: Compact, Tall, Full.

**Screenshots**
No production screenshots are committed yet. Before broader promotion, add:
- HUD open under notch.
- Workspace tab switcher.
- Theme settings panel.

**Install (Official Release)**
1. Click [Download for macOS](https://github.com/JesseRod329/KamiNotch/releases/latest/download/KamiNotch.dmg).
2. Drag `KamiNotch.app` to Applications.
3. Launch from Applications (double-click).

Optional verification:
```bash
spctl -a -vv /Applications/KamiNotch.app
codesign -dv --verbose=4 /Applications/KamiNotch.app
scripts/verify-release.sh /Applications/KamiNotch.app /path/to/KamiNotch.dmg
```

If a published release still shows a Gatekeeper malware-verification warning, treat it as a release pipeline defect and open an issue.

**Development**
Requirements:
- macOS with Xcode and Swift 6 toolchain.

Build a local DMG:
```bash
chmod +x scripts/create-dmg.sh
scripts/create-dmg.sh
```

Build and run:
```bash
swift build
swift run
```

Run tests:
```bash
swift test
```

Notes:
- Local DMGs are ad-hoc signed by default unless you set `CODESIGN_IDENTITY` and numeric bundle versions.
- Signing and notarization setup is documented in `docs/release-notarization.md`.

Release from GitHub Actions:
```bash
git tag v0.1.0
git push origin v0.1.0
```
The `Release DMG` workflow signs, notarizes, staples, and uploads `KamiNotch.dmg`.

**Security + Data Model**
- Security model: `docs/security-model.md`
- Stored app files:
  - `~/Library/Application Support/KamiNotch/workspaces.json`
  - `~/Library/Application Support/KamiNotch/theme.json`
- The app does not persist terminal output itself. Your shell may still persist history in your normal shell history files (for example `~/.zsh_history`).

**Display Behavior**
- Notch devices: panel is anchored to top-center around notch geometry.
- Non-notch displays: panel still anchors to top-center.
- Multi-display setups: current notch hit target follows the main display; improvements are planned for per-display behavior.

**Tech Direction**
- SwiftUI UI with AppKit window control.
- `NSStatusItem` menubar integration.
- SwiftTerm for terminal rendering.
- KeyboardShortcuts for global hotkey.
- JSON persistence for workspaces and theme.

**Roadmap**
- [x] Scaffold native macOS app shell.
- [x] Menubar toggle and panel window.
- [x] Terminal session manager and tab UI.
- [x] Workspace persistence and restore.
- [x] Theme system and preset packs.
- [x] App packaging (DMG build + release upload).
- [ ] Release screenshots and demo media.
- [ ] UI polish and animations.
- [ ] Multi-display notch target behavior.

**Contributing**
See `CONTRIBUTING.md`.

**License**
Apache-2.0. See `LICENSE`.

**Disclaimer**
KamiNotch is an independent project and is not affiliated with Apple.
