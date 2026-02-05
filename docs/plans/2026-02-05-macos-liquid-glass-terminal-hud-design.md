# macOS Liquid Glass Terminal HUD (Design)

## Overview
Build a menubar-only macOS app that drops a liquid-glass terminal HUD from the notch area. Clicking the menubar icon or a global hotkey expands/collapses the panel. The terminal stays running while collapsed. Users can open tabs and group them into named workspaces that restore on app relaunch. The UI uses a clean liquid-glass aesthetic with custom themes and preset packs.

## Goals
- Menubar/notch toggle for a glass HUD panel.
- Built-in terminal with real PTY sessions.
- Tabs grouped into workspaces with saved layouts.
- Size presets (Compact, Tall, Full) with a selector.
- Custom themes (tint, blur, glow, font) plus preset packs.
- User-defined global hotkey set on first launch.
- Full restore of workspaces and tabs after relaunch.

## Non-goals
- Cross-platform support.
- Split panes in v1.
- Terminal feature parity with iTerm2.

## User Experience
- Menubar icon is the only visible UI when collapsed.
- Click the menubar icon or press the hotkey to open the panel.
- The panel animates down from the notch area and stays anchored there.
- The top HUD bar exposes: workspace selector, tab controls, size preset toggle, and theme switcher.
- Collapsing the panel hides it without stopping terminal sessions.

## Architecture
Use SwiftUI for the UI with AppKit for menubar integration and panel window control.
- `NSStatusItem` for the menubar icon and anchor point.
- Custom `NSPanel` (borderless, titlebar hidden, vibrancy) to render glass.
- SwiftUI root view hosted in the panel window.
- Terminal emulator view embedded via `NSViewRepresentable`.

## Key Components
- `StatusItemController`: menubar icon, click handling, anchor frame.
- `PanelWindowController`: window creation, animations, and size preset transitions.
- `PanelView`: SwiftUI root view for the HUD.
- `WorkspaceStore`: manages workspaces, tabs, and persistence.
- `TerminalSessionManager`: creates and tracks PTY-backed sessions.
- `TerminalViewHost`: wraps the terminal emulator view for SwiftUI.
- `ThemeStore`: custom theme values and preset packs.
- `HotkeyManager`: registers and updates the global hotkey.

## Data Flow (Simplified)
- Menubar click or hotkey toggles the panel.
- Workspace selection switches the visible tab set.
- New tab creates a new PTY session and attaches it to the UI.
- Theme and size changes update the panel in real time.
- All workspace and tab state persists automatically.

## Terminal Integration
- Use a mature Swift terminal emulator (e.g., SwiftTerm) and a PTY-backed shell.
- Each tab maps to one PTY session.
- Session output streams into the terminal view; input routes back to the PTY.

## Workspaces and Tabs
- Workspaces are named groups of tabs.
- Each workspace stores its tabs and last-selected size preset.
- Restore workspaces and tabs on relaunch.

## Theming
- Custom theme controls: glass tint, blur strength, glow intensity, and font.
- Preset packs provide quick switching between curated looks.
- Theme changes apply instantly to the panel and HUD controls.

## Window Behavior
- Panel is anchored under the notch/menubar item.
- Size presets map to fixed height ratios (Compact, Tall, Full).
- Collapsing hides the panel but keeps sessions alive.
- If notch anchoring fails, center under the active menubar.

## Hotkey
- Prompt on first launch for a global hotkey.
- Store the hotkey and allow changes in Settings.
- Detect conflicts and keep the last valid hotkey.

## Error Handling
- If a session exits, show a “Session ended” state with Restart.
- If PTY creation fails, show a non-blocking error and keep the app running.
- If restore fails, mark affected tabs as failed with Retry.
- If theme values are invalid, fall back to safe defaults.

## Testing
- Unit tests for stores, hotkey manager, and session lifecycle.
- Manual QA for: toggle behavior, tab/workspace lifecycle, restore, theme changes, and size presets.
- Multi-monitor placement checks and notch anchoring fallback.

## Open Questions
- Preferred terminal emulator library (SwiftTerm vs. other).
- Whether to include minimal scrollback persistence across relaunch.
- Whether to add split panes post-v1.
