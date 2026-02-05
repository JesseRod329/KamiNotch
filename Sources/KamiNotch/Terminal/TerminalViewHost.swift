import SwiftTerm
import SwiftUI

struct TerminalViewHost: NSViewRepresentable {
    let view: LocalProcessTerminalView

    func makeNSView(context: Context) -> LocalProcessTerminalView {
        view
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
    }
}
