import XCTest
import SwiftTerm
@testable import KamiNotch

@MainActor
final class TerminalSessionManagerTests: XCTestCase {
    func test_create_session_adds_session() {
        let manager = TerminalSessionManager(factory: {
            TerminalSession(id: UUID(), title: "Test", view: LocalProcessTerminalView(frame: .zero))
        })
        manager.createSession()
        XCTAssertEqual(manager.sessions.count, 1)
    }
}
