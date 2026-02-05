import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var workspaceStore: WorkspaceStore

    var body: some View {
        HStack(spacing: 8) {
            ForEach(workspaceStore.activeTabs) { tab in
                HStack(spacing: 4) {
                    Button(tab.title) { workspaceStore.setActiveTab(tab.id) }
                        .buttonStyle(.bordered)
                    Button("×") { workspaceStore.closeTab(tab.id) }
                }
            }
            Button("+") { workspaceStore.createTab() }
            Spacer()
        }
    }
}
