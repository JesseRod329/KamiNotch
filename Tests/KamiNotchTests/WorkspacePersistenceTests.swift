import XCTest
@testable import KamiNotch

final class WorkspacePersistenceTests: XCTestCase {
    func test_save_and_load_roundtrip() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let fileURL = tempDir.appendingPathComponent("workspaces.json")
        let persistence = WorkspacePersistence(fileURL: fileURL)

        let state = WorkspaceState(
            activeWorkspaceID: UUID(),
            workspaces: [Workspace(id: UUID(), name: "Default", tabs: [], activeTabID: nil)]
        )

        try persistence.save(state)
        let loaded = try persistence.load()
        XCTAssertEqual(loaded, state)
    }
}
