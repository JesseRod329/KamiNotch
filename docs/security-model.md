# KamiNotch Security Model

This document defines the trust boundaries for KamiNotch and what users should expect from official releases.

## Execution Model

- KamiNotch launches a local login shell using `SHELL` from the current environment (fallback: `/bin/zsh`).
- Commands run with the same privileges as the logged-in user.
- KamiNotch does not install a privileged helper, launch daemon, or kernel extension.

## App Capabilities

- The terminal can execute any command your user account can execute.
- The app does not request admin privileges by itself.
- The app does not include remote command-and-control features.

## Persistence

KamiNotch stores app UI state in JSON:

- `~/Library/Application Support/KamiNotch/workspaces.json`
- `~/Library/Application Support/KamiNotch/theme.json`

KamiNotch does not persist terminal output or app-managed command history.

Important: because KamiNotch launches your normal login shell, shell-level history behavior still applies (for example, `~/.zsh_history` if your shell is zsh).

## Network and Telemetry

- KamiNotch has no built-in analytics or telemetry pipeline.
- Network activity can still occur from commands you run in the terminal session.

## Distribution Trust Requirements

Official releases are expected to be:

1. Signed with a valid Developer ID Application certificate.
2. Signed with Hardened Runtime enabled.
3. Notarized by Apple (`notarytool submit` accepted).
4. Stapled (`stapler staple`) before upload.

If any of these conditions are missing, treat the artifact as a development build, not a trusted public release.
