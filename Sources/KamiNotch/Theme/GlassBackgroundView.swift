import SwiftUI

struct GlassBackgroundView: View {
    @EnvironmentObject var themeStore: ThemeStore

    var body: some View {
        let theme = themeStore.currentTheme
        let shape = NotchGlassShape(
            bottomCornerRadius: 20,
            notchWidth: NotchGeometry.width,
            notchHeight: NotchGeometry.height,
            notchCornerRadius: NotchGeometry.cornerRadius
        )
        shape
            .fill(material(for: theme.blurStrength), style: FillStyle(eoFill: true))
            .overlay(
                shape.fill(theme.tint.swiftUIColor.opacity(0.12), style: FillStyle(eoFill: true))
            )
            .overlay(
                shape.stroke(Color.white.opacity(0.22), lineWidth: 0.6)
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
