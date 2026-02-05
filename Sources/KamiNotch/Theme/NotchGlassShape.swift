import SwiftUI

struct NotchGlassShape: Shape {
    let bottomCornerRadius: CGFloat
    let notchWidth: CGFloat
    let notchHeight: CGFloat
    let notchCornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = UnevenRoundedRectangle(
            cornerRadii: RectangleCornerRadii(
                topLeading: 0,
                bottomLeading: bottomCornerRadius,
                bottomTrailing: bottomCornerRadius,
                topTrailing: 0
            ),
            style: .continuous
        ).path(in: rect)
        let clampedNotchWidth = min(notchWidth, rect.width - 8)
        let clampedNotchHeight = min(notchHeight, rect.height * 0.5)

        let notchRect = CGRect(
            x: rect.midX - clampedNotchWidth / 2,
            y: rect.minY,
            width: clampedNotchWidth,
            height: clampedNotchHeight
        )
        let notchCutout = UnevenRoundedRectangle(
            cornerRadii: RectangleCornerRadii(
                topLeading: 0,
                bottomLeading: notchCornerRadius,
                bottomTrailing: notchCornerRadius,
                topTrailing: 0
            ),
            style: .continuous
        )
        path.addPath(notchCutout.path(in: notchRect))
        return path
    }
}
