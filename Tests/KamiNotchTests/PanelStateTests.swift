import XCTest
@testable import KamiNotch

@MainActor
final class PanelStateTests: XCTestCase {
    func test_default_visibility_is_false() {
        let state = PanelState()
        XCTAssertFalse(state.isVisible)
    }
}
