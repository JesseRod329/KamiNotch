# Global Hotkey Setup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a global hotkey that toggles the panel, with a first-launch setup flow and Settings UI.

**Architecture:** Use the `KeyboardShortcuts` package to store and register the hotkey. Add a setup window for first launch, a settings view for updates, and a hotkey manager that binds the shortcut to the panel toggle.

**Tech Stack:** Swift 6, SwiftUI, AppKit, Swift Package Manager, KeyboardShortcuts

---

### Task 1: Add KeyboardShortcuts dependency and hotkey name

**Files:**
- Modify: `Package.swift`
- Create: `Sources/KamiNotch/Hotkey/HotkeyName.swift`
- Test: `Tests/KamiNotchTests/HotkeyNameTests.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/HotkeyNameTests.swift`:

```swift
import XCTest
@testable import KamiNotch

final class HotkeyNameTests: XCTestCase {
    func test_globalHotkey_name_is_stable() {
        XCTAssertEqual(HotkeyName.globalToggle.rawValue, "globalToggle")
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'HotkeyName'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Hotkey/HotkeyName.swift`:

```swift
import KeyboardShortcuts

enum HotkeyName {
    static let globalToggle = KeyboardShortcuts.Name("globalToggle")
}
```

Update `Package.swift`:

```swift
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "1.16.0")
    ],
    targets: [
        .executableTarget(
            name: "KamiNotch",
            dependencies: ["KeyboardShortcuts"],
            path: "Sources/KamiNotch"
        ),
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Package.swift Sources/KamiNotch/Hotkey Tests/KamiNotchTests

git commit -m "feat: add KeyboardShortcuts dependency"
```

---

### Task 2: Add AppPreferences for first-launch setup

**Files:**
- Create: `Sources/KamiNotch/Preferences/AppPreferences.swift`
- Test: `Tests/KamiNotchTests/AppPreferencesTests.swift`

**Step 1: Write the failing test**

```swift
import XCTest
@testable import KamiNotch

final class AppPreferencesTests: XCTestCase {
    func test_default_hotkey_setup_is_false() {
        let prefs = AppPreferences(userDefaults: .init(suiteName: "AppPreferencesTests")!)
        prefs.reset()
        XCTAssertFalse(prefs.hasCompletedHotkeySetup)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'AppPreferences'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Preferences/AppPreferences.swift`:

```swift
import Foundation

final class AppPreferences {
    private let userDefaults: UserDefaults
    private let hotkeySetupKey = "hasCompletedHotkeySetup"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasCompletedHotkeySetup: Bool {
        get { userDefaults.bool(forKey: hotkeySetupKey) }
        set { userDefaults.set(newValue, forKey: hotkeySetupKey) }
    }

    func reset() {
        userDefaults.removeObject(forKey: hotkeySetupKey)
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/Preferences Tests/KamiNotchTests

git commit -m "feat: add app preferences for hotkey setup"
```

---

### Task 3: Add HotkeyManager and register toggle handler

**Files:**
- Create: `Sources/KamiNotch/Hotkey/HotkeyManager.swift`
- Modify: `Sources/KamiNotch/AppDelegate.swift`
- Test: `Tests/KamiNotchTests/HotkeyManagerTests.swift`

**Step 1: Write the failing test**

```swift
import XCTest
@testable import KamiNotch

final class HotkeyManagerTests: XCTestCase {
    func test_register_calls_handler() {
        let handler = HotkeyHandlerSpy()
        let manager = HotkeyManager(register: handler.register)
        manager.registerToggle(action: { handler.called = true })
        handler.trigger()
        XCTAssertTrue(handler.called)
    }
}

final class HotkeyHandlerSpy {
    var called = false
    private var callback: (() -> Void)?

    func register(_ name: String, _ block: @escaping () -> Void) {
        callback = block
    }

    func trigger() {
        callback?()
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'HotkeyManager'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Hotkey/HotkeyManager.swift`:

```swift
import KeyboardShortcuts

final class HotkeyManager {
    typealias Register = (_ name: String, _ action: @escaping () -> Void) -> Void

    private let registerBlock: Register

    init(register: @escaping Register = { name, action in
        KeyboardShortcuts.onKeyUp(for: KeyboardShortcuts.Name(name), action: action)
    }) {
        self.registerBlock = register
    }

    func registerToggle(action: @escaping () -> Void) {
        registerBlock(HotkeyName.globalToggle.rawValue, action)
    }
}
```

Update `AppDelegate.swift`:

```swift
private let preferences = AppPreferences()
private let hotkeyManager = HotkeyManager()
```

In `applicationDidFinishLaunching`:

```swift
hotkeyManager.registerToggle(action: { [weak self] in
    self?.togglePanel()
})
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/AppDelegate.swift Sources/KamiNotch/Hotkey Tests/KamiNotchTests

git commit -m "feat: add hotkey manager"
```

---

### Task 4: Add first-launch hotkey setup window

**Files:**
- Create: `Sources/KamiNotch/Hotkey/HotkeySetupView.swift`
- Create: `Sources/KamiNotch/Hotkey/HotkeySetupWindowController.swift`
- Modify: `Sources/KamiNotch/AppDelegate.swift`
- Modify: `Sources/KamiNotch/KamiNotchApp.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/HotkeySetupFlowTests.swift`:

```swift
import XCTest
@testable import KamiNotch

final class HotkeySetupFlowTests: XCTestCase {
    func test_setup_completed_after_confirm() {
        let prefs = AppPreferences(userDefaults: .init(suiteName: "HotkeySetupFlowTests")!)
        prefs.reset()
        let viewModel = HotkeySetupViewModel(preferences: prefs)
        viewModel.confirmSetup()
        XCTAssertTrue(prefs.hasCompletedHotkeySetup)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'HotkeySetupViewModel'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Hotkey/HotkeySetupView.swift`:

```swift
import KeyboardShortcuts
import SwiftUI

@MainActor
final class HotkeySetupViewModel: ObservableObject {
    private let preferences: AppPreferences

    init(preferences: AppPreferences) {
        self.preferences = preferences
    }

    func confirmSetup() {
        preferences.hasCompletedHotkeySetup = true
    }

    func cancelSetup() {
        if KeyboardShortcuts.getShortcut(for: HotkeyName.globalToggle) == nil {
            KeyboardShortcuts.setShortcut(
                .init(.t, modifiers: [.control, .option, .command]),
                for: HotkeyName.globalToggle
            )
        }
        preferences.hasCompletedHotkeySetup = true
    }
}

struct HotkeySetupView: View {
    @ObservedObject var viewModel: HotkeySetupViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Set Your Hotkey")
                .font(.title2)
            Text("Choose a shortcut to toggle KamiNotch.")
                .foregroundStyle(.secondary)
            KeyboardShortcuts.Recorder(for: HotkeyName.globalToggle)
            HStack {
                Button("Use Default") { viewModel.cancelSetup() }
                Button("Save") { viewModel.confirmSetup() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 380)
    }
}
```

Create `Sources/KamiNotch/Hotkey/HotkeySetupWindowController.swift`:

```swift
import AppKit
import SwiftUI

@MainActor
final class HotkeySetupWindowController {
    private var window: NSWindow?

    func show(preferences: AppPreferences) {
        let viewModel = HotkeySetupViewModel(preferences: preferences)
        let view = HotkeySetupView(viewModel: viewModel)
        let hosting = NSHostingView(rootView: view)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 220),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "KamiNotch"
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        self.window = window
    }
}
```

Update `AppDelegate.swift`:

```swift
private let preferences = AppPreferences()
private let hotkeySetupWindow = HotkeySetupWindowController()
```

In `applicationDidFinishLaunching`:

```swift
if KeyboardShortcuts.getShortcut(for: HotkeyName.globalToggle) == nil && !preferences.hasCompletedHotkeySetup {
    hotkeySetupWindow.show(preferences: preferences)
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/Hotkey Sources/KamiNotch/AppDelegate.swift Sources/KamiNotch/KamiNotchApp.swift Tests/KamiNotchTests

git commit -m "feat: add first-launch hotkey setup"
```

---

### Task 5: Add Settings UI for hotkey changes

**Files:**
- Create: `Sources/KamiNotch/Settings/SettingsView.swift`
- Modify: `Sources/KamiNotch/KamiNotchApp.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/SettingsViewTests.swift`:

```swift
import XCTest
import SwiftUI
@testable import KamiNotch

final class SettingsViewTests: XCTestCase {
    func test_settings_view_exists() {
        _ = SettingsView()
        XCTAssertTrue(true)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'SettingsView'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Settings/SettingsView.swift`:

```swift
import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Hotkey") {
                KeyboardShortcuts.Recorder(for: HotkeyName.globalToggle)
            }
        }
        .padding(24)
        .frame(width: 420)
    }
}
```

Update `KamiNotchApp.swift`:

```swift
var body: some Scene {
    Settings {
        SettingsView()
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/Settings Sources/KamiNotch/KamiNotchApp.swift Tests/KamiNotchTests

git commit -m "feat: add hotkey settings UI"
```
