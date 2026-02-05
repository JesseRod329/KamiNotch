import XCTest
@testable import KamiNotch

@MainActor
final class TerminalPanelViewTests: XCTestCase {
    func test_terminal_panel_view_exists() {
        _ = TerminalPanelView()
        XCTAssertTrue(true)
    }
}
