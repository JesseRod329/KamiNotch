import XCTest
@testable import KamiNotch

@MainActor
final class HotkeyNameTests: XCTestCase {
    func test_globalHotkey_name_is_stable() {
        XCTAssertEqual(HotkeyName.globalToggle.rawValue, "globalToggle")
    }
}
