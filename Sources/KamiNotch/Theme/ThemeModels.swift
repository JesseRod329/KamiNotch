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
