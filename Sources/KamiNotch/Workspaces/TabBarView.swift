import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var workspaceStore: WorkspaceStore

    var body: some View {
        HStack(spacing: 6) {
            ForEach(workspaceStore.activeTabs) { tab in
                HStack(spacing: 4) {
                    Button(tab.title) { workspaceStore.setActiveTab(tab.id) }
                        .buttonStyle(GlassPillButtonStyle(isSelected: workspaceStore.activeTabID == tab.id))
                    Button("×") { workspaceStore.closeTab(tab.id) }
                        .buttonStyle(GlassPillButtonStyle(isSelected: false))
                }
            }
            Button("+") { workspaceStore.createTab() }
                .buttonStyle(GlassPillButtonStyle(isSelected: false))
            Spacer()
        }
    }
}
