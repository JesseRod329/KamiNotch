import SwiftTerm
import SwiftUI

struct TerminalViewHost: NSViewRepresentable {
    func makeNSView(context: Context) -> TerminalView {
        TerminalView(frame: .zero)
    }

    func updateNSView(_ nsView: TerminalView, context: Context) {
    }
}
