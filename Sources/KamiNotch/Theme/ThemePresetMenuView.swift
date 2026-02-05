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
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.18), lineWidth: 0.5)
                        )
                )
        }
    }
}
