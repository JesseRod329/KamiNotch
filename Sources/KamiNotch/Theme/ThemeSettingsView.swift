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
