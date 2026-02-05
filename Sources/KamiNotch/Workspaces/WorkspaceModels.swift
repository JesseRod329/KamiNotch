import Foundation

struct WorkspaceTab: Codable, Equatable, Identifiable {
    let id: UUID
    var title: String
}

struct Workspace: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var tabs: [WorkspaceTab]
    var activeTabID: UUID?
}

struct WorkspaceState: Codable, Equatable {
    var activeWorkspaceID: UUID?
    var workspaces: [Workspace]
}
