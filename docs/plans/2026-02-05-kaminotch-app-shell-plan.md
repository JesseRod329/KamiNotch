# KamiNotch App Shell Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Scaffold a native macOS menubar app that toggles a glass panel with placeholder content.

**Architecture:** SwiftUI renders the UI, while AppKit manages the menubar icon and an `NSPanel` window. A small observable state object drives panel visibility and size presets.

**Tech Stack:** Swift 6, SwiftUI, AppKit, Swift Package Manager

---

### Task 1: Scaffold the Swift package and app entry

**Files:**
- Create: `Package.swift`
- Create: `Sources/KamiNotch/KamiNotchApp.swift`
- Create: `Sources/KamiNotch/AppDelegate.swift`
- Create: `Sources/KamiNotch/UI/PanelView.swift`

**Step 1: Write the failing test**

Create a tiny state object test stub so `swift test` runs and fails until the type exists.

`Tests/KamiNotchTests/PanelStateTests.swift`:

```swift
import XCTest
@testable import KamiNotch

final class PanelStateTests: XCTestCase {
    func test_default_visibility_is_false() {
        let state = PanelState()
        XCTAssertFalse(state.isVisible)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'PanelState'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/State/PanelState.swift`:

```swift
import Foundation

@MainActor
final class PanelState: ObservableObject {
    @Published var isVisible = false
}
```

Create `Package.swift`:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KamiNotch",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "KamiNotch", targets: ["KamiNotch"])
    ],
    targets: [
        .executableTarget(
            name: "KamiNotch",
            path: "Sources/KamiNotch"
        ),
        .testTarget(
            name: "KamiNotchTests",
            dependencies: ["KamiNotch"],
            path: "Tests/KamiNotchTests"
        )
    ]
)
```

Create `Sources/KamiNotch/KamiNotchApp.swift`:

```swift
import SwiftUI

@main
struct KamiNotchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
```

Create `Sources/KamiNotch/AppDelegate.swift`:

```swift
import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let panelState = PanelState()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}
```

Create `Sources/KamiNotch/UI/PanelView.swift`:

```swift
import SwiftUI

struct PanelView: View {
    var body: some View {
        Text("KamiNotch")
            .padding(24)
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Package.swift Sources/KamiNotch Tests/KamiNotchTests

git commit -m "feat: scaffold macOS app shell"
```

---

### Task 2: Add the menubar status item and panel window

**Files:**
- Modify: `Sources/KamiNotch/AppDelegate.swift`
- Create: `Sources/KamiNotch/UI/PanelWindowController.swift`
- Modify: `Sources/KamiNotch/UI/PanelView.swift`
- Modify: `Sources/KamiNotch/State/PanelState.swift`
- Test: `Tests/KamiNotchTests/PanelStateTests.swift`

**Step 1: Write the failing test**

Add a toggle test:

```swift
func test_toggle_changes_visibility() {
    let state = PanelState()
    state.toggle()
    XCTAssertTrue(state.isVisible)
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "value of type 'PanelState' has no member 'toggle'".

**Step 3: Write minimal implementation**

Update `PanelState.swift`:

```swift
@MainActor
final class PanelState: ObservableObject {
    @Published var isVisible = false

    func toggle() {
        isVisible.toggle()
    }
}
```

Create `PanelWindowController.swift`:

```swift
import AppKit
import SwiftUI

@MainActor
final class PanelWindowController {
    private let panel: NSPanel

    init(rootView: AnyView) {
        let contentView = NSHostingView(rootView: rootView)
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 360),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.contentView = contentView
    }

    func show(at origin: CGPoint) {
        panel.setFrameOrigin(origin)
        panel.orderFront(nil)
    }

    func hide() {
        panel.orderOut(nil)
    }
}
```

Update `PanelView.swift` to show placeholder style:

```swift
struct PanelView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            Text("KamiNotch")
                .font(.title2)
        }
        .frame(width: 600, height: 360)
        .padding(16)
    }
}
```

Update `AppDelegate.swift`:

```swift
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let panelState = PanelState()
    private var statusItem: NSStatusItem?
    private var panelController: PanelWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.title = "⌘"
        item.button?.action = #selector(togglePanel)
        item.button?.target = self
        statusItem = item

        panelController = PanelWindowController(rootView: AnyView(PanelView()))
    }

    @objc private func togglePanel() {
        panelState.toggle()
        if panelState.isVisible, let button = statusItem?.button {
            let frame = button.window?.convertToScreen(button.frame) ?? .zero
            let origin = CGPoint(x: frame.minX - 200, y: frame.minY - 380)
            panelController?.show(at: origin)
        } else {
            panelController?.hide()
        }
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Manual check**

Run: `swift run`
Expected: menubar icon appears, click toggles panel.

**Step 6: Commit**

```bash
git add Sources/KamiNotch Tests/KamiNotchTests

git commit -m "feat: add menubar toggle and panel window"
```

---

### Task 3: Add size presets (Compact/Tall/Full)

**Files:**
- Modify: `Sources/KamiNotch/State/PanelState.swift`
- Modify: `Sources/KamiNotch/UI/PanelView.swift`
- Modify: `Sources/KamiNotch/UI/PanelWindowController.swift`
- Test: `Tests/KamiNotchTests/PanelStateTests.swift`

**Step 1: Write the failing test**

```swift
func test_default_size_is_compact() {
    let state = PanelState()
    XCTAssertEqual(state.sizePreset, .compact)
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "type 'PanelState' has no member 'sizePreset'".

**Step 3: Write minimal implementation**

Update `PanelState.swift`:

```swift
enum PanelSizePreset: String, CaseIterable {
    case compact
    case tall
    case full
}

@MainActor
final class PanelState: ObservableObject {
    @Published var isVisible = false
    @Published var sizePreset: PanelSizePreset = .compact

    func toggle() {
        isVisible.toggle()
    }
}
```

Update `PanelView.swift` to show size controls:

```swift
struct PanelView: View {
    @EnvironmentObject var panelState: PanelState

    var body: some View {
        VStack(spacing: 12) {
            Picker("Size", selection: $panelState.sizePreset) {
                ForEach(PanelSizePreset.allCases, id: \.self) { preset in
                    Text(preset.rawValue.capitalized).tag(preset)
                }
            }
            .pickerStyle(.segmented)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                Text("KamiNotch")
                    .font(.title2)
            }
            .frame(width: 600, height: 320)
        }
        .padding(16)
    }
}
```

Update `PanelWindowController.swift` to resize on preset change:

```swift
final class PanelWindowController {
    private let panel: NSPanel
    private var observation: Any?

    init(rootView: AnyView, panelState: PanelState) {
        let contentView = NSHostingView(rootView: rootView.environmentObject(panelState))
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 360),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.contentView = contentView

        observation = panelState.$sizePreset.sink { [weak self] preset in
            self?.resize(for: preset)
        }
    }

    private func resize(for preset: PanelSizePreset) {
        let height: CGFloat
        switch preset {
        case .compact: height = 360
        case .tall: height = 540
        case .full: height = 720
        }
        var frame = panel.frame
        frame.size.height = height
        panel.setFrame(frame, display: true, animate: true)
    }

    func show(at origin: CGPoint) { panel.setFrameOrigin(origin); panel.orderFront(nil) }
    func hide() { panel.orderOut(nil) }
}
```

Update `AppDelegate.swift` to pass panelState into panel controller.

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Manual check**

Run: `swift run`
Expected: segmented control changes panel height.

**Step 6: Commit**

```bash
git add Sources/KamiNotch Tests/KamiNotchTests

git commit -m "feat: add size presets"
```
