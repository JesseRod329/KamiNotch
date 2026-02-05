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
