import XCTest
@testable import KamiNotch

@MainActor
final class ThemeStoreTests: XCTestCase {
    func test_default_theme_loaded_when_missing_file() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let fileURL = tempDir.appendingPathComponent("theme.json")
        let persistence = ThemePersistence(fileURL: fileURL)

        let store = ThemeStore(persistence: persistence)
        XCTAssertFalse(store.presets.isEmpty)
    }
}
