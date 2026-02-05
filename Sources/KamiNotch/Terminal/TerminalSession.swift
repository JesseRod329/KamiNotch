import Foundation
import SwiftTerm

@MainActor
final class TerminalSession: Identifiable {
    let id: UUID
    let title: String
    let view: LocalProcessTerminalView

    init(id: UUID, title: String, view: LocalProcessTerminalView) {
        self.id = id
        self.title = title
        self.view = view
    }

    static func makeDefault(id: UUID) -> TerminalSession {
        let view = LocalProcessTerminalView(frame: .zero)
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        view.startProcess(executable: shell, args: ["-l"])
        return TerminalSession(id: id, title: "Shell", view: view)
    }
}
