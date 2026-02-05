import Foundation

@MainActor
final class WorkspaceStore: ObservableObject {
    @Published private(set) var workspaces: [Workspace] = []
    @Published var activeWorkspaceID: UUID?

    private let persistence: WorkspacePersistence
    private let terminalManager: TerminalSessionManager

    init(persistence: WorkspacePersistence = WorkspacePersistence(), terminalManager: TerminalSessionManager) {
        self.persistence = persistence
        self.terminalManager = terminalManager
        load()
    }

    private func load() {
        if let state = try? persistence.load() {
            workspaces = state.workspaces
            activeWorkspaceID = state.activeWorkspaceID
        }

        if workspaces.isEmpty {
            let workspace = Workspace(id: UUID(), name: "Default", tabs: [], activeTabID: nil)
            workspaces = [workspace]
            activeWorkspaceID = workspace.id
        }

        hydrateSessions()
        save()
    }

    private func save() {
        let state = WorkspaceState(activeWorkspaceID: activeWorkspaceID, workspaces: workspaces)
        try? persistence.save(state)
    }

    private func hydrateSessions() {
        for workspace in workspaces {
            terminalManager.hydrate(workspaceID: workspace.id, tabs: workspace.tabs)
        }
    }

    func createWorkspace(name: String) {
        let workspace = Workspace(id: UUID(), name: name, tabs: [], activeTabID: nil)
        workspaces.append(workspace)
        activeWorkspaceID = workspace.id
        save()
    }
}
