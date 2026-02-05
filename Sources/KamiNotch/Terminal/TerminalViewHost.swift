import SwiftTerm
import SwiftUI

struct TerminalViewHost: NSViewRepresentable {
    func makeNSView(context: Context) -> LocalProcessTerminalView {
        let view = LocalProcessTerminalView(frame: .zero)
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        view.startProcess(executable: shell, args: ["-l"])
        return view
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
    }
}
