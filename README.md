# KamiNotch

KamiNotch is a menubar-only macOS terminal HUD that drops from the notch with a clean liquid-glass look. It keeps your shell running when collapsed, so you can pop it open and keep working.

## Status
Design phase. No runnable app yet.

- Design doc: `docs/plans/2026-02-05-macos-liquid-glass-terminal-hud-design.md`

## Goals
- Menubar toggle and global hotkey.
- Built-in terminal with real PTY sessions.
- Tabs grouped into workspaces that restore on relaunch.
- Liquid-glass theming with presets and custom controls.

## Planned Features
- Drop-down HUD anchored to the notch/menubar.
- Size presets: Compact, Tall, Full.
- Workspace switcher with saved tab sets.
- Custom themes: tint, blur, glow, font.

## Tech Direction
- SwiftUI UI with AppKit window control.
- `NSStatusItem` menubar integration.
- Embedded terminal view and PTY sessions.

## Roadmap
- [ ] Scaffold native macOS app shell.
- [ ] Menubar toggle and panel window.
- [ ] Terminal session manager and tab UI.
- [ ] Workspace persistence and restore.
- [ ] Theme system and preset packs.

## Contributing
See `CONTRIBUTING.md`.

## License
Apache-2.0. See `LICENSE`.

## Disclaimer
KamiNotch is an independent project and is not affiliated with Apple.
