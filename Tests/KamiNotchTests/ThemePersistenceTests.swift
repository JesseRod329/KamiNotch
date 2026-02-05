import XCTest
@testable import KamiNotch

final class ThemePersistenceTests: XCTestCase {
    func test_save_and_load_roundtrip() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let fileURL = tempDir.appendingPathComponent("theme.json")
        let persistence = ThemePersistence(fileURL: fileURL)

        let theme = Theme(
            tint: ThemeColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.8),
            blurStrength: 0.5,
            glowIntensity: 0.4,
            fontName: "Menlo",
            fontSize: 12
        )
        let preset = ThemePreset(id: UUID(), name: "Default", theme: theme)
        let state = ThemeState(currentTheme: theme, selectedPresetID: preset.id, presets: [preset])

        try persistence.save(state)
        let loaded = try persistence.load()
        XCTAssertEqual(loaded, state)
    }
}
