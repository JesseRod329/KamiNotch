import XCTest
@testable import KamiNotch

final class AppPreferencesTests: XCTestCase {
    func test_default_hotkey_setup_is_false() {
        let prefs = AppPreferences(userDefaults: .init(suiteName: "AppPreferencesTests")!)
        prefs.reset()
        XCTAssertFalse(prefs.hasCompletedHotkeySetup)
    }
}
