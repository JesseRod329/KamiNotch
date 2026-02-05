import Foundation

@MainActor
final class TerminalSessionManager: ObservableObject {
    @Published private(set) var sessions: [TerminalSession] = []
    @Published var activeSessionID: UUID?

    private let factory: () -> TerminalSession

    init(factory: @escaping () -> TerminalSession = { TerminalSession.makeDefault() }) {
        self.factory = factory
    }

    func createSession() {
        let session = factory()
        sessions.append(session)
        activeSessionID = session.id
    }

    func hydrate(workspaceID: UUID, tabs: [WorkspaceTab]) {
    }

    var activeSession: TerminalSession? {
        sessions.first { $0.id == activeSessionID }
    }
}
