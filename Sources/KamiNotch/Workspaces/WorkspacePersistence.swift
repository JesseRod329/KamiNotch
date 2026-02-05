import Foundation

struct WorkspacePersistence {
    let fileURL: URL

    init(fileURL: URL = WorkspacePersistence.defaultFileURL()) {
        self.fileURL = fileURL
    }

    static func defaultFileURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupport.appendingPathComponent("KamiNotch", isDirectory: true)
            .appendingPathComponent("workspaces.json")
    }

    func save(_ state: WorkspaceState) throws {
        let dir = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(state)
        try data.write(to: fileURL, options: [.atomic])
    }

    func load() throws -> WorkspaceState {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(WorkspaceState.self, from: data)
    }
}
