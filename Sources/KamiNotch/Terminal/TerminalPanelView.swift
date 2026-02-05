import SwiftUI

struct TerminalPanelView: View {
    @EnvironmentObject var terminalManager: TerminalSessionManager

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button("+") { terminalManager.createSession() }
                Spacer()
            }

            Group {
                if let session = terminalManager.activeSession {
                    TerminalViewHost(view: session.view)
                } else {
                    Text("No session")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            if terminalManager.sessions.isEmpty {
                terminalManager.createSession()
            }
        }
    }
}
