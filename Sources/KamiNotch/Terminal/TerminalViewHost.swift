import SwiftTerm
import SwiftUI

struct TerminalViewHost: NSViewRepresentable {
    let view: LocalProcessTerminalView
    let font: NSFont

    func makeNSView(context: Context) -> LocalProcessTerminalView {
        view
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        nsView.font = font
        if nsView.window?.firstResponder !== nsView {
            nsView.window?.makeFirstResponder(nsView)
        }
    }
}
