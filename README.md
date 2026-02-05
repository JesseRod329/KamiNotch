# KamiNotch

![License](https://img.shields.io/github/license/JesseRod329/KamiNotch)
![Platform](https://img.shields.io/badge/platform-macOS-111111)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen)
[![Download for macOS](https://img.shields.io/badge/Download-macOS_DMG-007AFF?style=for-the-badge&logo=apple)](https://github.com/JesseRod329/KamiNotch/releases/latest/download/KamiNotch.dmg)

KamiNotch is a menubar-only macOS terminal HUD that drops from the notch with a clean liquid-glass look. It keeps your shell running when collapsed, so you can pop it open and keep working.

**Status**
Prototype in progress. Core HUD, hotkey, terminal, workspaces, themes, and DMG packaging are implemented. Notarization and polish are still in progress.

- Design doc: `docs/plans/2026-02-05-macos-liquid-glass-terminal-hud-design.md`

**Current Features**
- Menubar toggle and global hotkey.
- Built-in terminal (SwiftTerm) with local shell.
- Tabs grouped into workspaces, persisted to JSON.
- Liquid-glass theming with presets and custom controls.
- Size presets: Compact, Tall, Full.

**Screenshots**
- `docs/screenshots/hud.png` (coming soon)
- `docs/screenshots/workspaces.png` (coming soon)
- `docs/screenshots/theme-settings.png` (coming soon)

**Getting Started**
Requirements:
- macOS with Xcode and Swift 6 toolchain.

Install from release (recommended):
1. Click [Download for macOS](https://github.com/JesseRod329/KamiNotch/releases/latest/download/KamiNotch.dmg).
2. Drag `KamiNotch.app` to Applications.
3. Launch from Applications.

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
- Current DMG is ad-hoc signed and not notarized yet. If Gatekeeper blocks first launch, right-click `KamiNotch.app` and choose Open.
- If you convert this to an Xcode app target, disable App Sandbox so the embedded shell can run local commands.

Release DMG from GitHub Actions:
```bash
git tag v0.1.0
git push origin v0.1.0
```
The `Release DMG` workflow builds `KamiNotch.dmg` and attaches it to the GitHub release.

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
- [ ] Notarization.
- [ ] UI polish and animations.

**Contributing**
See `CONTRIBUTING.md`.

**License**
Apache-2.0. See `LICENSE`.

**Disclaimer**
KamiNotch is an independent project and is not affiliated with Apple.
