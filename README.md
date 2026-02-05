# KamiNotch

KamiNotch is a menubar-only macOS terminal HUD that drops from the notch with a clean liquid-glass look. It keeps your shell running when collapsed, so you can pop it open and keep working.

**Status**
Prototype in progress. Core HUD, hotkey, terminal, workspaces, and themes are implemented. App packaging and polish are still in progress.

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
- If you convert this to an Xcode app target, disable App Sandbox so the embedded shell can run local commands.

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
- [ ] App packaging and notarization.
- [ ] UI polish and animations.

**Contributing**
See `CONTRIBUTING.md`.

**License**
Apache-2.0. See `LICENSE`.

**Disclaimer**
KamiNotch is an independent project and is not affiliated with Apple.
