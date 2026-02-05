import SwiftUI

struct TerminalPanelView: View {
    @EnvironmentObject var terminalManager: TerminalSessionManager
    @EnvironmentObject var workspaceStore: WorkspaceStore
    @EnvironmentObject var themeStore: ThemeStore

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
                    TerminalViewHost(view: session.view, font: themeStore.currentFont)
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
