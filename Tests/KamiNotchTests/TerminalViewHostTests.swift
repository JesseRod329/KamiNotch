import XCTest
import SwiftTerm
@testable import KamiNotch

@MainActor
final class TerminalViewHostTests: XCTestCase {
    func test_terminal_view_host_initializes() {
        _ = TerminalViewHost(view: LocalProcessTerminalView(frame: .zero))
        XCTAssertTrue(true)
    }
}
