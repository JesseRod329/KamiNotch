import SwiftUI

struct NotchGlassShape: Shape {
    let cornerRadius: CGFloat
    let notchWidth: CGFloat
    let notchHeight: CGFloat
    let notchCornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let clampedNotchWidth = min(notchWidth, rect.width - cornerRadius * 2)
        let clampedNotchHeight = min(notchHeight, rect.height * 0.5)

        path.addRoundedRect(
            in: rect,
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
        )

        let notchRect = CGRect(
            x: rect.midX - clampedNotchWidth / 2,
            y: rect.minY,
            width: clampedNotchWidth,
            height: clampedNotchHeight
        )
        path.addRoundedRect(
            in: notchRect,
            cornerSize: CGSize(width: notchCornerRadius, height: notchCornerRadius)
        )
        return path
    }
}
