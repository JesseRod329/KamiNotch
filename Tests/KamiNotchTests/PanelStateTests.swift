import XCTest
@testable import KamiNotch

@MainActor
final class PanelStateTests: XCTestCase {
    func test_default_visibility_is_false() {
        let state = PanelState()
        XCTAssertFalse(state.isVisible)
    }

    func test_toggle_changes_visibility() {
        let state = PanelState()
        state.toggle()
        XCTAssertTrue(state.isVisible)
    }

    func test_default_size_is_compact() {
        let state = PanelState()
        XCTAssertEqual(state.sizePreset, .compact)
    }
}
