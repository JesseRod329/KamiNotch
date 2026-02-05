import SwiftUI

struct WorkspaceSwitcherView: View {
    @EnvironmentObject var workspaceStore: WorkspaceStore
    @State private var isRenaming = false
    @State private var nameDraft = ""

    var body: some View {
        Menu {
            ForEach(workspaceStore.workspaces) { workspace in
                Button(workspace.name) { workspaceStore.setActiveWorkspace(workspace.id) }
            }
            Divider()
            Button("New Workspace") { workspaceStore.createWorkspace(name: workspaceStore.nextWorkspaceName()) }
            Button("Rename Workspace") { beginRename() }
            Button("Delete Workspace") { workspaceStore.deleteActiveWorkspace() }
        } label: {
            HStack(spacing: 6) {
                Text(workspaceStore.activeWorkspaceName)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.18), lineWidth: 0.5)
                    )
            )
        }
        .sheet(isPresented: $isRenaming) {
            VStack(spacing: 12) {
                Text("Rename Workspace").font(.headline)
                TextField("Name", text: $nameDraft)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Cancel") { isRenaming = false }
                    Button("Save") {
                        workspaceStore.renameActiveWorkspace(to: nameDraft)
                        isRenaming = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(20)
            .frame(width: 320)
        }
    }

    private func beginRename() {
        nameDraft = workspaceStore.activeWorkspaceName
        isRenaming = true
    }
}
