import SwiftUI

struct TerminalPanelView: View {
    @EnvironmentObject var terminalManager: TerminalSessionManager
    @EnvironmentObject var workspaceStore: WorkspaceStore

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                WorkspaceSwitcherView()
                Spacer()
            }

            TabBarView()

            Group {
                if let workspaceID = workspaceStore.activeWorkspaceID,
                   let session = terminalManager.session(workspaceID: workspaceID, tabID: workspaceStore.activeTabID) {
                    TerminalViewHost(view: session.view)
                } else {
                    Text("No session")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            workspaceStore.ensureInitialTabs()
        }
    }
}
