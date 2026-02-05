import XCTest
import SwiftTerm
@testable import KamiNotch

@MainActor
final class TerminalSessionManagerTests: XCTestCase {
    func test_sessions_scoped_to_workspace() {
        let manager = TerminalSessionManager(factory: { id in
            TerminalSession(id: id, title: "Test", view: LocalProcessTerminalView(frame: .zero))
        })
        let workspaceA = UUID()
        let workspaceB = UUID()
        manager.createSession(workspaceID: workspaceA, tabID: UUID())
        manager.createSession(workspaceID: workspaceB, tabID: UUID())
        XCTAssertEqual(manager.sessions(for: workspaceA).count, 1)
        XCTAssertEqual(manager.sessions(for: workspaceB).count, 1)
    }
}
