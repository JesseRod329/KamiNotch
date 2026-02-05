import XCTest
@testable import KamiNotch

@MainActor
final class ThemeSettingsViewTests: XCTestCase {
    func test_theme_settings_view_exists() {
        _ = ThemeSettingsView()
        XCTAssertTrue(true)
    }
}
