import SwiftUI

struct GlassPillButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(0.9))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(
                                Color.white.opacity(isSelected ? 0.35 : 0.18),
                                lineWidth: 0.5
                            )
                    )
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
