import XCTest
@testable import KamiNotch

@MainActor
final class HotkeySetupFlowTests: XCTestCase {
    func test_setup_completed_after_confirm() {
        let prefs = AppPreferences(userDefaults: .init(suiteName: "HotkeySetupFlowTests")!)
        prefs.reset()
        let viewModel = HotkeySetupViewModel(preferences: prefs)
        viewModel.confirmSetup()
        XCTAssertTrue(prefs.hasCompletedHotkeySetup)
    }
}
