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
