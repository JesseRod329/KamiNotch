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

        if activeWorkspaceID == nil {
            activeWorkspaceID = workspaces.first?.id
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

    var activeWorkspaceName: String {
        activeWorkspace?.name ?? "Workspace"
    }

    var activeTabs: [WorkspaceTab] {
        activeWorkspace?.tabs ?? []
    }

    var activeTabID: UUID? {
        activeWorkspace?.activeTabID
    }

    func setActiveWorkspace(_ id: UUID) {
        activeWorkspaceID = id
        ensureInitialTabs()
        save()
    }

    func createTab() {
        guard var workspace = activeWorkspace else { return }
        let tab = WorkspaceTab(id: UUID(), title: "Shell")
        workspace.tabs.append(tab)
        workspace.activeTabID = tab.id
        updateWorkspace(workspace)
        terminalManager.createSession(workspaceID: workspace.id, tabID: tab.id)
        save()
    }

    func closeTab(_ id: UUID) {
        guard var workspace = activeWorkspace else { return }
        workspace.tabs.removeAll { $0.id == id }
        terminalManager.removeSession(workspaceID: workspace.id, tabID: id)
        if workspace.activeTabID == id {
            workspace.activeTabID = workspace.tabs.first?.id
        }
        updateWorkspace(workspace)
        save()
    }

    func setActiveTab(_ id: UUID) {
        guard var workspace = activeWorkspace else { return }
        workspace.activeTabID = id
        updateWorkspace(workspace)
        save()
    }

    func renameActiveWorkspace(to name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, var workspace = activeWorkspace else { return }
        workspace.name = trimmed
        updateWorkspace(workspace)
        save()
    }

    func deleteActiveWorkspace() {
        guard let id = activeWorkspaceID else { return }
        if let workspace = activeWorkspace {
            for tab in workspace.tabs {
                terminalManager.removeSession(workspaceID: workspace.id, tabID: tab.id)
            }
        }
        workspaces.removeAll { $0.id == id }
        if workspaces.isEmpty {
            let workspace = Workspace(id: UUID(), name: "Default", tabs: [], activeTabID: nil)
            workspaces = [workspace]
            activeWorkspaceID = workspace.id
        } else {
            activeWorkspaceID = workspaces.first?.id
        }
        ensureInitialTabs()
        save()
    }

    func nextWorkspaceName() -> String {
        "Workspace \(workspaces.count + 1)"
    }

    func ensureInitialTabs() {
        guard let workspace = activeWorkspace else { return }
        if workspace.tabs.isEmpty {
            createTab()
        } else if workspace.activeTabID == nil, let first = workspace.tabs.first?.id {
            setActiveTab(first)
        }
    }

    private var activeWorkspace: Workspace? {
        guard let id = activeWorkspaceID else { return nil }
        return workspaces.first { $0.id == id }
    }

    private func updateWorkspace(_ workspace: Workspace) {
        guard let index = workspaces.firstIndex(where: { $0.id == workspace.id }) else { return }
        workspaces[index] = workspace
    }
}
