import Foundation

@MainActor
final class TerminalSessionManager: ObservableObject {
    @Published private(set) var sessionsByWorkspace: [UUID: [TerminalSession]] = [:]
    @Published var activeSessionID: UUID?

    private let factory: (UUID) -> TerminalSession
    private let legacyWorkspaceID = UUID()

    init(factory: @escaping (UUID) -> TerminalSession = { TerminalSession.makeDefault(id: $0) }) {
        self.factory = factory
    }

    func hydrate(workspaceID: UUID, tabs: [WorkspaceTab]) {
        sessionsByWorkspace[workspaceID] = tabs.map { factory($0.id) }
    }

    func sessions(for workspaceID: UUID) -> [TerminalSession] {
        sessionsByWorkspace[workspaceID] ?? []
    }

    func createSession(workspaceID: UUID, tabID: UUID) {
        var sessions = sessionsByWorkspace[workspaceID] ?? []
        sessions.append(factory(tabID))
        sessionsByWorkspace[workspaceID] = sessions
    }

    func removeSession(workspaceID: UUID, tabID: UUID) {
        sessionsByWorkspace[workspaceID] = sessions(for: workspaceID).filter { $0.id != tabID }
    }

    func session(workspaceID: UUID, tabID: UUID?) -> TerminalSession? {
        guard let tabID else { return nil }
        return sessions(for: workspaceID).first { $0.id == tabID }
    }

    var sessions: [TerminalSession] {
        sessions(for: legacyWorkspaceID)
    }

    func createSession() {
        let tabID = UUID()
        createSession(workspaceID: legacyWorkspaceID, tabID: tabID)
        activeSessionID = tabID
    }

    var activeSession: TerminalSession? {
        session(workspaceID: legacyWorkspaceID, tabID: activeSessionID)
    }
}
