import SwiftUI

struct GlassBackgroundView: View {
    @EnvironmentObject var themeStore: ThemeStore

    var body: some View {
        let theme = themeStore.currentTheme
        RoundedRectangle(cornerRadius: 20)
            .fill(material(for: theme.blurStrength))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.tint.swiftUIColor.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.22), lineWidth: 0.6)
            )
            .shadow(
                color: theme.tint.swiftUIColor.opacity(theme.glowIntensity * 0.6),
                radius: CGFloat(16 * theme.glowIntensity),
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
