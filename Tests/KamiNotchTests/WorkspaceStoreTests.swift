import XCTest
import SwiftTerm
@testable import KamiNotch

@MainActor
final class WorkspaceStoreTests: XCTestCase {
    func test_creates_default_workspace_on_empty_load() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let fileURL = tempDir.appendingPathComponent("workspaces.json")
        let persistence = WorkspacePersistence(fileURL: fileURL)
        let terminalManager = TerminalSessionManager(factory: { id in
            TerminalSession(id: id, title: "Test", view: LocalProcessTerminalView(frame: .zero))
        })

        let store = WorkspaceStore(persistence: persistence, terminalManager: terminalManager)
        XCTAssertEqual(store.workspaces.count, 1)
    }
}
