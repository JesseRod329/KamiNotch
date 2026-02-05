# Theme System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a global theme system with presets, custom sliders, and persistence. Apply the theme to the glass HUD and terminal font.

**Architecture:** A `ThemeStore` loads/saves JSON in Application Support and exposes the current theme and presets. `GlassBackgroundView` renders the HUD glass based on the theme. Settings UI edits sliders and applies presets. The terminal font updates via the SwiftTerm `font` API.

**Tech Stack:** Swift 6, SwiftUI, AppKit, SwiftTerm

---

### Task 1: Theme models + persistence helper

**Files:**
- Create: `Sources/KamiNotch/Theme/ThemeModels.swift`
- Create: `Sources/KamiNotch/Theme/ThemePersistence.swift`
- Test: `Tests/KamiNotchTests/ThemePersistenceTests.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/ThemePersistenceTests.swift`:

```swift
import XCTest
@testable import KamiNotch

final class ThemePersistenceTests: XCTestCase {
    func test_save_and_load_roundtrip() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let fileURL = tempDir.appendingPathComponent("theme.json")
        let persistence = ThemePersistence(fileURL: fileURL)

        let theme = Theme(
            tint: ThemeColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.8),
            blurStrength: 0.5,
            glowIntensity: 0.4,
            fontName: "Menlo",
            fontSize: 12
        )
        let preset = ThemePreset(id: UUID(), name: "Default", theme: theme)
        let state = ThemeState(currentTheme: theme, selectedPresetID: preset.id, presets: [preset])

        try persistence.save(state)
        let loaded = try persistence.load()
        XCTAssertEqual(loaded, state)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'ThemePersistence'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Theme/ThemeModels.swift`:

```swift
import AppKit
import SwiftUI

struct ThemeColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    var swiftUIColor: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    var nsColor: NSColor {
        NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
    }

    static func from(color: Color) -> ThemeColor {
        let ns = NSColor(color)
        let rgb = ns.usingColorSpace(.deviceRGB) ?? ns
        return ThemeColor(
            red: Double(rgb.redComponent),
            green: Double(rgb.greenComponent),
            blue: Double(rgb.blueComponent),
            alpha: Double(rgb.alphaComponent)
        )
    }
}

struct Theme: Codable, Equatable {
    var tint: ThemeColor
    var blurStrength: Double
    var glowIntensity: Double
    var fontName: String
    var fontSize: Double
}

struct ThemePreset: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var theme: Theme
}

struct ThemeState: Codable, Equatable {
    var currentTheme: Theme
    var selectedPresetID: UUID?
    var presets: [ThemePreset]
}
```

Create `Sources/KamiNotch/Theme/ThemePersistence.swift`:

```swift
import Foundation

struct ThemePersistence {
    let fileURL: URL

    init(fileURL: URL = ThemePersistence.defaultFileURL()) {
        self.fileURL = fileURL
    }

    static func defaultFileURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupport.appendingPathComponent("KamiNotch", isDirectory: true)
            .appendingPathComponent("theme.json")
    }

    func save(_ state: ThemeState) throws {
        let dir = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(state)
        try data.write(to: fileURL, options: [.atomic])
    }

    func load() throws -> ThemeState {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(ThemeState.self, from: data)
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/Theme Tests/KamiNotchTests

git commit -m "feat: add theme models and persistence"
```

---

### Task 2: ThemeStore with presets and persistence

**Files:**
- Create: `Sources/KamiNotch/Theme/ThemeStore.swift`
- Test: `Tests/KamiNotchTests/ThemeStoreTests.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/ThemeStoreTests.swift`:

```swift
import XCTest
@testable import KamiNotch

@MainActor
final class ThemeStoreTests: XCTestCase {
    func test_default_theme_loaded_when_missing_file() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let fileURL = tempDir.appendingPathComponent("theme.json")
        let persistence = ThemePersistence(fileURL: fileURL)

        let store = ThemeStore(persistence: persistence)
        XCTAssertFalse(store.presets.isEmpty)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'ThemeStore'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Theme/ThemeStore.swift`:

```swift
import AppKit
import SwiftUI

@MainActor
final class ThemeStore: ObservableObject {
    @Published var currentTheme: Theme
    @Published var selectedPresetID: UUID?
    @Published var presets: [ThemePreset]

    private let persistence: ThemePersistence

    init(persistence: ThemePersistence = ThemePersistence()) {
        self.persistence = persistence
        if let state = try? persistence.load() {
            currentTheme = state.currentTheme
            selectedPresetID = state.selectedPresetID
            presets = state.presets
        } else {
            let baseTheme = Theme(
                tint: ThemeColor(red: 0.75, green: 0.8, blue: 0.9, alpha: 0.5),
                blurStrength: 0.5,
                glowIntensity: 0.3,
                fontName: "Menlo",
                fontSize: 12
            )
            let presets = [
                ThemePreset(id: UUID(), name: "Clear", theme: baseTheme),
                ThemePreset(id: UUID(), name: "Smoke", theme: Theme(
                    tint: ThemeColor(red: 0.4, green: 0.45, blue: 0.5, alpha: 0.6),
                    blurStrength: 0.7,
                    glowIntensity: 0.2,
                    fontName: "Menlo",
                    fontSize: 12
                )),
                ThemePreset(id: UUID(), name: "Aurora", theme: Theme(
                    tint: ThemeColor(red: 0.25, green: 0.6, blue: 0.5, alpha: 0.6),
                    blurStrength: 0.6,
                    glowIntensity: 0.5,
                    fontName: "Menlo",
                    fontSize: 12
                ))
            ]
            self.presets = presets
            self.currentTheme = baseTheme
            self.selectedPresetID = presets.first?.id
            save()
        }
    }

    func applyPreset(_ preset: ThemePreset) {
        currentTheme = preset.theme
        selectedPresetID = preset.id
        save()
    }

    func updateTheme(_ theme: Theme) {
        currentTheme = theme
        selectedPresetID = nil
        save()
    }

    func savePreset(name: String) {
        let preset = ThemePreset(id: UUID(), name: name, theme: currentTheme)
        presets.append(preset)
        selectedPresetID = preset.id
        save()
    }

    var currentFont: NSFont {
        NSFont(name: currentTheme.fontName, size: currentTheme.fontSize)
            ?? NSFont.monospacedSystemFont(ofSize: CGFloat(currentTheme.fontSize), weight: .regular)
    }

    private func save() {
        let state = ThemeState(
            currentTheme: currentTheme,
            selectedPresetID: selectedPresetID,
            presets: presets
        )
        try? persistence.save(state)
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/Theme Tests/KamiNotchTests

git commit -m "feat: add theme store"
```

---

### Task 3: Glass background + terminal font updates

**Files:**
- Create: `Sources/KamiNotch/Theme/GlassBackgroundView.swift`
- Modify: `Sources/KamiNotch/UI/PanelView.swift`
- Modify: `Sources/KamiNotch/Terminal/TerminalPanelView.swift`
- Modify: `Sources/KamiNotch/Terminal/TerminalViewHost.swift`
- Test: `Tests/KamiNotchTests/GlassBackgroundViewTests.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/GlassBackgroundViewTests.swift`:

```swift
import XCTest
@testable import KamiNotch

final class GlassBackgroundViewTests: XCTestCase {
    func test_glass_background_view_exists() {
        _ = GlassBackgroundView()
        XCTAssertTrue(true)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'GlassBackgroundView'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Theme/GlassBackgroundView.swift`:

```swift
import SwiftUI

struct GlassBackgroundView: View {
    @EnvironmentObject var themeStore: ThemeStore

    var body: some View {
        let theme = themeStore.currentTheme
        RoundedRectangle(cornerRadius: 20)
            .fill(material(for: theme.blurStrength))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.tint.swiftUIColor.opacity(0.25))
            )
            .shadow(
                color: theme.tint.swiftUIColor.opacity(theme.glowIntensity * 0.6),
                radius: CGFloat(24 * theme.glowIntensity),
                x: 0,
                y: 0
            )
    }

    private func material(for blur: Double) -> Material {
        switch blur {
        case ..<0.2: return .ultraThin
        case ..<0.4: return .thin
        case ..<0.6: return .regular
        case ..<0.8: return .thick
        default: return .ultraThick
        }
    }
}
```

Update `TerminalViewHost.swift`:

```swift
import SwiftTerm
import SwiftUI

struct TerminalViewHost: NSViewRepresentable {
    let view: LocalProcessTerminalView
    let font: NSFont

    func makeNSView(context: Context) -> LocalProcessTerminalView {
        view
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        nsView.font = font
    }
}
```

Update `TerminalPanelView.swift`:

```swift
@EnvironmentObject var themeStore: ThemeStore
...
TerminalViewHost(view: session.view, font: themeStore.currentFont)
```

Update `PanelView.swift` to use `GlassBackgroundView()` in place of the rounded rectangle fill.

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/Theme Sources/KamiNotch/Terminal Sources/KamiNotch/UI Tests/KamiNotchTests

git commit -m "feat: apply theme to glass and terminal"
```

---

### Task 4: Theme settings UI and preset menu

**Files:**
- Create: `Sources/KamiNotch/Theme/ThemeSettingsView.swift`
- Create: `Sources/KamiNotch/Theme/ThemePresetMenuView.swift`
- Modify: `Sources/KamiNotch/Settings/SettingsView.swift`
- Modify: `Sources/KamiNotch/Terminal/TerminalPanelView.swift`
- Modify: `Sources/KamiNotch/AppDelegate.swift`
- Modify: `Sources/KamiNotch/UI/PanelWindowController.swift`
- Modify: `Sources/KamiNotch/KamiNotchApp.swift`
- Test: `Tests/KamiNotchTests/ThemeSettingsViewTests.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/ThemeSettingsViewTests.swift`:

```swift
import XCTest
@testable import KamiNotch

final class ThemeSettingsViewTests: XCTestCase {
    func test_theme_settings_view_exists() {
        _ = ThemeSettingsView()
        XCTAssertTrue(true)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'ThemeSettingsView'".

**Step 3: Write minimal implementation**

Create `ThemePresetMenuView.swift`:

```swift
import SwiftUI

struct ThemePresetMenuView: View {
    @EnvironmentObject var themeStore: ThemeStore

    var body: some View {
        Menu {
            ForEach(themeStore.presets) { preset in
                Button(preset.name) { themeStore.applyPreset(preset) }
            }
        } label: {
            Image(systemName: "paintpalette")
        }
    }
}
```

Create `ThemeSettingsView.swift`:

```swift
import SwiftUI

struct ThemeSettingsView: View {
    @EnvironmentObject var themeStore: ThemeStore
    @State private var presetName = ""

    var body: some View {
        Form {
            Section("Theme Presets") {
                Picker("Preset", selection: $themeStore.selectedPresetID) {
                    ForEach(themeStore.presets) { preset in
                        Text(preset.name).tag(Optional(preset.id))
                    }
                }
                Button("Apply") {
                    if let id = themeStore.selectedPresetID,
                       let preset = themeStore.presets.first(where: { $0.id == id }) {
                        themeStore.applyPreset(preset)
                    }
                }
                HStack {
                    TextField("New preset name", text: $presetName)
                    Button("Save") {
                        let trimmed = presetName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        themeStore.savePreset(name: trimmed)
                        presetName = ""
                    }
                }
            }

            Section("Theme Controls") {
                ColorPicker("Tint", selection: Binding(
                    get: { themeStore.currentTheme.tint.swiftUIColor },
                    set: { themeStore.updateTheme(themeStore.currentTheme.withTint($0)) }
                ))

                Slider(value: Binding(
                    get: { themeStore.currentTheme.blurStrength },
                    set: { themeStore.updateTheme(themeStore.currentTheme.withBlur($0)) }
                ), in: 0...1) {
                    Text("Blur")
                }

                Slider(value: Binding(
                    get: { themeStore.currentTheme.glowIntensity },
                    set: { themeStore.updateTheme(themeStore.currentTheme.withGlow($0)) }
                ), in: 0...1) {
                    Text("Glow")
                }

                TextField("Font", text: Binding(
                    get: { themeStore.currentTheme.fontName },
                    set: { themeStore.updateTheme(themeStore.currentTheme.withFontName($0)) }
                ))

                Slider(value: Binding(
                    get: { themeStore.currentTheme.fontSize },
                    set: { themeStore.updateTheme(themeStore.currentTheme.withFontSize($0)) }
                ), in: 10...18) {
                    Text("Font Size")
                }
            }
        }
        .padding(24)
        .frame(width: 420)
    }
}
```

Update `Theme` model with helpers in `ThemeModels.swift`:

```swift
extension Theme {
    func withTint(_ color: Color) -> Theme {
        var copy = self
        copy.tint = ThemeColor.from(color: color)
        return copy
    }

    func withBlur(_ value: Double) -> Theme {
        var copy = self
        copy.blurStrength = value
        return copy
    }

    func withGlow(_ value: Double) -> Theme {
        var copy = self
        copy.glowIntensity = value
        return copy
    }

    func withFontName(_ name: String) -> Theme {
        var copy = self
        copy.fontName = name
        return copy
    }

    func withFontSize(_ size: Double) -> Theme {
        var copy = self
        copy.fontSize = size
        return copy
    }
}
```

Update `SettingsView.swift` to include `ThemeSettingsView()` under a "Theme" section.

Update `TerminalPanelView.swift` top bar to show `ThemePresetMenuView()` on the right.

Update `AppDelegate.swift` to create a `ThemeStore` and pass it to `PanelWindowController`.

Update `PanelWindowController.swift` to inject `themeStore` into the environment.

Update `KamiNotchApp.swift` to pass `themeStore` into the Settings scene:

```swift
Settings {
    SettingsView().environmentObject(appDelegate.themeStore)
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch Tests/KamiNotchTests

git commit -m "feat: add theme settings and presets"
```
