# Workspaces + Tab Persistence Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add workspace management with per-workspace tabs and JSON persistence.

**Architecture:** A `WorkspaceStore` loads/saves a JSON file in Application Support, manages workspaces/tabs, and coordinates with `TerminalSessionManager` to create sessions for each tab. The HUD adds a workspace dropdown and a tab bar.

**Tech Stack:** Swift 6, SwiftUI, AppKit, SwiftTerm

---

### Task 1: Workspace models + persistence helper

**Files:**
- Create: `Sources/KamiNotch/Workspaces/WorkspaceModels.swift`
- Create: `Sources/KamiNotch/Workspaces/WorkspacePersistence.swift`
- Test: `Tests/KamiNotchTests/WorkspacePersistenceTests.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/WorkspacePersistenceTests.swift`:

```swift
import XCTest
@testable import KamiNotch

final class WorkspacePersistenceTests: XCTestCase {
    func test_save_and_load_roundtrip() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let fileURL = tempDir.appendingPathComponent("workspaces.json")
        let persistence = WorkspacePersistence(fileURL: fileURL)

        let state = WorkspaceState(
            activeWorkspaceID: UUID(),
            workspaces: [Workspace(id: UUID(), name: "Default", tabs: [], activeTabID: nil)]
        )

        try persistence.save(state)
        let loaded = try persistence.load()
        XCTAssertEqual(loaded, state)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'WorkspacePersistence'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Workspaces/WorkspaceModels.swift`:

```swift
import Foundation

struct WorkspaceTab: Codable, Equatable, Identifiable {
    let id: UUID
    var title: String
}

struct Workspace: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var tabs: [WorkspaceTab]
    var activeTabID: UUID?
}

struct WorkspaceState: Codable, Equatable {
    var activeWorkspaceID: UUID?
    var workspaces: [Workspace]
}
```

Create `Sources/KamiNotch/Workspaces/WorkspacePersistence.swift`:

```swift
import Foundation

struct WorkspacePersistence {
    let fileURL: URL

    init(fileURL: URL = WorkspacePersistence.defaultFileURL()) {
        self.fileURL = fileURL
    }

    static func defaultFileURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupport.appendingPathComponent("KamiNotch", isDirectory: true)
            .appendingPathComponent("workspaces.json")
    }

    func save(_ state: WorkspaceState) throws {
        let dir = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(state)
        try data.write(to: fileURL, options: [.atomic])
    }

    func load() throws -> WorkspaceState {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(WorkspaceState.self, from: data)
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/Workspaces Tests/KamiNotchTests

git commit -m "feat: add workspace models and persistence"
```

---

### Task 2: WorkspaceStore with autosave

**Files:**
- Create: `Sources/KamiNotch/Workspaces/WorkspaceStore.swift`
- Test: `Tests/KamiNotchTests/WorkspaceStoreTests.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/WorkspaceStoreTests.swift`:

```swift
import XCTest
@testable import KamiNotch

@MainActor
final class WorkspaceStoreTests: XCTestCase {
    func test_creates_default_workspace_on_empty_load() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let fileURL = tempDir.appendingPathComponent("workspaces.json")
        let persistence = WorkspacePersistence(fileURL: fileURL)
        let terminalManager = TerminalSessionManager(factory: { TerminalSession(id: UUID(), title: "Test", view: .init(frame: .zero)) })

        let store = WorkspaceStore(persistence: persistence, terminalManager: terminalManager)
        XCTAssertEqual(store.workspaces.count, 1)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'WorkspaceStore'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Workspaces/WorkspaceStore.swift`:

```swift
import Foundation

@MainActor
final class WorkspaceStore: ObservableObject {
    @Published private(set) var workspaces: [Workspace] = []
    @Published var activeWorkspaceID: UUID?

    private let persistence: WorkspacePersistence
    private let terminalManager: TerminalSessionManager

    init(persistence: WorkspacePersistence = WorkspacePersistence(), terminalManager: TerminalSessionManager) {
        self.persistence = persistence
        self.terminalManager = terminalManager
        load()
    }

    private func load() {
        if let state = try? persistence.load() {
            workspaces = state.workspaces
            activeWorkspaceID = state.activeWorkspaceID
        }

        if workspaces.isEmpty {
            let workspace = Workspace(id: UUID(), name: "Default", tabs: [], activeTabID: nil)
            workspaces = [workspace]
            activeWorkspaceID = workspace.id
        }

        hydrateSessions()
        save()
    }

    private func save() {
        let state = WorkspaceState(activeWorkspaceID: activeWorkspaceID, workspaces: workspaces)
        try? persistence.save(state)
    }

    private func hydrateSessions() {
        for workspace in workspaces {
            terminalManager.hydrate(workspaceID: workspace.id, tabs: workspace.tabs)
        }
    }

    func createWorkspace(name: String) {
        let workspace = Workspace(id: UUID(), name: name, tabs: [], activeTabID: nil)
        workspaces.append(workspace)
        activeWorkspaceID = workspace.id
        save()
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/Workspaces Tests/KamiNotchTests

git commit -m "feat: add workspace store"
```

---

### Task 3: Extend TerminalSessionManager for workspaces

**Files:**
- Modify: `Sources/KamiNotch/Terminal/TerminalSessionManager.swift`
- Modify: `Sources/KamiNotch/Terminal/TerminalSession.swift`
- Test: `Tests/KamiNotchTests/TerminalSessionManagerTests.swift`

**Step 1: Write the failing test**

Update `Tests/KamiNotchTests/TerminalSessionManagerTests.swift`:

```swift
@MainActor
func test_sessions_scoped_to_workspace() {
    let manager = TerminalSessionManager(factory: { id in
        TerminalSession(id: id, title: "Test", view: .init(frame: .zero))
    })
    let workspaceA = UUID()
    let workspaceB = UUID()
    manager.createSession(workspaceID: workspaceA, tabID: UUID())
    manager.createSession(workspaceID: workspaceB, tabID: UUID())
    XCTAssertEqual(manager.sessions(for: workspaceA).count, 1)
    XCTAssertEqual(manager.sessions(for: workspaceB).count, 1)
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with missing methods.

**Step 3: Write minimal implementation**

Update `TerminalSession.swift`:

```swift
@MainActor
final class TerminalSession: Identifiable {
    let id: UUID
    let title: String
    let view: LocalProcessTerminalView

    init(id: UUID, title: String, view: LocalProcessTerminalView) {
        self.id = id
        self.title = title
        self.view = view
    }

    static func makeDefault(id: UUID) -> TerminalSession {
        let view = LocalProcessTerminalView(frame: .zero)
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        view.startProcess(executable: shell, args: ["-l"])
        return TerminalSession(id: id, title: "Shell", view: view)
    }
}
```

Update `TerminalSessionManager.swift`:

```swift
@MainActor
final class TerminalSessionManager: ObservableObject {
    @Published private(set) var sessionsByWorkspace: [UUID: [TerminalSession]] = [:]
    private let factory: (UUID) -> TerminalSession

    init(factory: @escaping (UUID) -> TerminalSession = { TerminalSession.makeDefault(id: $0) }) {
        self.factory = factory
    }

    func hydrate(workspaceID: UUID, tabs: [WorkspaceTab]) {
        sessionsByWorkspace[workspaceID] = tabs.map { factory($0.id) }
    }

    func sessions(for workspaceID: UUID) -> [TerminalSession] {
        sessionsByWorkspace[workspaceID] ?? []
    }

    func createSession(workspaceID: UUID, tabID: UUID) {
        var sessions = sessionsByWorkspace[workspaceID] ?? []
        sessions.append(factory(tabID))
        sessionsByWorkspace[workspaceID] = sessions
    }

    func removeSession(workspaceID: UUID, tabID: UUID) {
        sessionsByWorkspace[workspaceID] = sessions(for: workspaceID).filter { $0.id != tabID }
    }

    func session(workspaceID: UUID, tabID: UUID?) -> TerminalSession? {
        guard let tabID else { return nil }
        return sessions(for: workspaceID).first { $0.id == tabID }
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/Terminal Tests/KamiNotchTests/TerminalSessionManagerTests.swift

git commit -m "feat: scope terminal sessions by workspace"
```

---

### Task 4: Add workspace switcher and tab bar UI

**Files:**
- Create: `Sources/KamiNotch/Workspaces/WorkspaceSwitcherView.swift`
- Create: `Sources/KamiNotch/Workspaces/TabBarView.swift`
- Modify: `Sources/KamiNotch/Terminal/TerminalPanelView.swift`
- Modify: `Sources/KamiNotch/UI/PanelView.swift`
- Modify: `Sources/KamiNotch/AppDelegate.swift`
- Modify: `Sources/KamiNotch/UI/PanelWindowController.swift`
- Test: `Tests/KamiNotchTests/WorkspaceSwitcherViewTests.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/WorkspaceSwitcherViewTests.swift`:

```swift
import XCTest
@testable import KamiNotch

final class WorkspaceSwitcherViewTests: XCTestCase {
    func test_workspace_switcher_exists() {
        _ = WorkspaceSwitcherView()
        XCTAssertTrue(true)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'WorkspaceSwitcherView'".

**Step 3: Write minimal implementation**

Create `WorkspaceSwitcherView.swift`:

```swift
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
        }
        .sheet(isPresented: $isRenaming) {
            VStack(spacing: 12) {
                Text("Rename Workspace").font(.headline)
                TextField("Name", text: $nameDraft)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Cancel") { isRenaming = false }
                    Button("Save") { workspaceStore.renameActiveWorkspace(to: nameDraft); isRenaming = false }
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
```

Create `TabBarView.swift`:

```swift
import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var workspaceStore: WorkspaceStore

    var body: some View {
        HStack(spacing: 8) {
            ForEach(workspaceStore.activeTabs) { tab in
                Button(tab.title) { workspaceStore.setActiveTab(tab.id) }
                    .buttonStyle(.bordered)
                Button("×") { workspaceStore.closeTab(tab.id) }
            }
            Button("+") { workspaceStore.createTab() }
            Spacer()
        }
    }
}
```

Update `TerminalPanelView.swift`:

```swift
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
                    Text("No session").foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { workspaceStore.ensureInitialTabs() }
    }
}
```

Update `PanelView.swift` to keep size picker and embed `TerminalPanelView` (already present).

Update `AppDelegate.swift`:

```swift
private let terminalManager = TerminalSessionManager()
private let workspaceStore: WorkspaceStore

init() {
    terminalManager = TerminalSessionManager()
    workspaceStore = WorkspaceStore(terminalManager: terminalManager)
}
```

Update `PanelWindowController.swift` to pass `workspaceStore` as environment object.

Add helper methods to `WorkspaceStore`:
- `setActiveWorkspace(_ id: UUID)`
- `activeWorkspaceName`
- `activeTabs`
- `activeTabID`
- `createTab()`
- `closeTab(_:)`
- `renameActiveWorkspace(to:)`
- `deleteActiveWorkspace()`
- `nextWorkspaceName()`
- `ensureInitialTabs()`

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch Tests/KamiNotchTests

git commit -m "feat: add workspace switcher and tabs"
```
