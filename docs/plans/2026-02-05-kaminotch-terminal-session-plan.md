# Terminal Session Manager Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Embed a real terminal using SwiftTerm with PTY-backed sessions and a simple tab bar.

**Architecture:** SwiftTerm provides the terminal renderer. A session manager owns PTY processes and terminal views. SwiftUI hosts the terminal view through `NSViewRepresentable` and a simple tab strip.

**Tech Stack:** Swift 6, SwiftUI, AppKit, SwiftTerm, Swift Package Manager

---

### Task 1: Add SwiftTerm dependency and terminal view host

**Files:**
- Modify: `Package.swift`
- Create: `Sources/KamiNotch/Terminal/TerminalViewHost.swift`
- Test: `Tests/KamiNotchTests/TerminalViewHostTests.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/TerminalViewHostTests.swift`:

```swift
import XCTest
@testable import KamiNotch

final class TerminalViewHostTests: XCTestCase {
    func test_terminal_view_host_initializes() {
        _ = TerminalViewHost()
        XCTAssertTrue(true)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'TerminalViewHost'".

**Step 3: Write minimal implementation**

Update `Package.swift`:

```swift
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftTerm", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "KamiNotch",
            dependencies: ["SwiftTerm"],
            path: "Sources/KamiNotch"
        ),
```

Create `Sources/KamiNotch/Terminal/TerminalViewHost.swift`:

```swift
import SwiftTerm
import SwiftUI

struct TerminalViewHost: NSViewRepresentable {
    func makeNSView(context: Context) -> TerminalView {
        TerminalView(frame: .zero)
    }

    func updateNSView(_ nsView: TerminalView, context: Context) {
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Package.swift Sources/KamiNotch/Terminal Tests/KamiNotchTests

git commit -m "feat: add SwiftTerm dependency"
```

---

### Task 2: Add PTY launcher utility

**Files:**
- Create: `Sources/KamiNotch/Terminal/PTYLauncher.swift`
- Test: `Tests/KamiNotchTests/PTYLauncherTests.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/PTYLauncherTests.swift`:

```swift
import XCTest
@testable import KamiNotch

final class PTYLauncherTests: XCTestCase {
    func test_launch_returns_valid_fd() {
        let result = PTYLauncher.launchLoginShell()
        XCTAssertTrue(result.masterFD >= 0)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'PTYLauncher'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Terminal/PTYLauncher.swift`:

```swift
import Foundation

struct PTYLaunchResult {
    let masterFD: Int32
    let processID: pid_t
}

enum PTYLauncher {
    static func launchLoginShell() -> PTYLaunchResult {
        var master: Int32 = 0
        var slave: Int32 = 0
        openpty(&master, &slave, nil, nil, nil)

        let pid = fork()
        if pid == 0 {
            setsid()
            dup2(slave, STDIN_FILENO)
            dup2(slave, STDOUT_FILENO)
            dup2(slave, STDERR_FILENO)
            close(master)

            let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
            execl(shell, shell, "-l", nil)
            exit(0)
        } else {
            close(slave)
            return PTYLaunchResult(masterFD: master, processID: pid)
        }
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/Terminal Tests/KamiNotchTests

git commit -m "feat: add PTY launcher"
```

---

### Task 3: Terminal session manager

**Files:**
- Create: `Sources/KamiNotch/Terminal/TerminalSession.swift`
- Create: `Sources/KamiNotch/Terminal/TerminalSessionManager.swift`
- Test: `Tests/KamiNotchTests/TerminalSessionManagerTests.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/TerminalSessionManagerTests.swift`:

```swift
import XCTest
@testable import KamiNotch

final class TerminalSessionManagerTests: XCTestCase {
    func test_create_session_adds_session() {
        let manager = TerminalSessionManager()
        manager.createSession()
        XCTAssertEqual(manager.sessions.count, 1)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'TerminalSessionManager'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Terminal/TerminalSession.swift`:

```swift
import Foundation

struct TerminalSession: Identifiable {
    let id: UUID
    let title: String
    let masterFD: Int32
    let processID: pid_t
}
```

Create `Sources/KamiNotch/Terminal/TerminalSessionManager.swift`:

```swift
import Foundation

@MainActor
final class TerminalSessionManager: ObservableObject {
    @Published private(set) var sessions: [TerminalSession] = []
    @Published var activeSessionID: UUID?

    func createSession() {
        let result = PTYLauncher.launchLoginShell()
        let session = TerminalSession(
            id: UUID(),
            title: "Shell",
            masterFD: result.masterFD,
            processID: result.processID
        )
        sessions.append(session)
        activeSessionID = session.id
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/Terminal Tests/KamiNotchTests

git commit -m "feat: add terminal session manager"
```

---

### Task 4: Wire terminal view into the panel UI

**Files:**
- Modify: `Sources/KamiNotch/UI/PanelView.swift`
- Modify: `Sources/KamiNotch/AppDelegate.swift`
- Create: `Sources/KamiNotch/Terminal/TerminalPanelView.swift`
- Test: `Tests/KamiNotchTests/TerminalPanelViewTests.swift`

**Step 1: Write the failing test**

Create `Tests/KamiNotchTests/TerminalPanelViewTests.swift`:

```swift
import XCTest
@testable import KamiNotch

final class TerminalPanelViewTests: XCTestCase {
    func test_terminal_panel_view_exists() {
        _ = TerminalPanelView()
        XCTAssertTrue(true)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "cannot find type 'TerminalPanelView'".

**Step 3: Write minimal implementation**

Create `Sources/KamiNotch/Terminal/TerminalPanelView.swift`:

```swift
import SwiftUI

struct TerminalPanelView: View {
    @EnvironmentObject var terminalManager: TerminalSessionManager

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button("+") { terminalManager.createSession() }
                Spacer()
            }

            TerminalViewHost()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            if terminalManager.sessions.isEmpty {
                terminalManager.createSession()
            }
        }
    }
}
```

Update `PanelView.swift` to embed `TerminalPanelView`:

```swift
struct PanelView: View {
    @EnvironmentObject var panelState: PanelState
    @EnvironmentObject var terminalManager: TerminalSessionManager

    var body: some View {
        VStack(spacing: 12) {
            Picker("Size", selection: $panelState.sizePreset) {
                ForEach(PanelSizePreset.allCases, id: \.self) { preset in
                    Text(preset.rawValue.capitalized).tag(preset)
                }
            }
            .pickerStyle(.segmented)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                TerminalPanelView()
                    .padding(12)
            }
            .frame(width: 600, height: 320)
        }
        .padding(16)
    }
}
```

Update `AppDelegate.swift`:

```swift
private let terminalManager = TerminalSessionManager()
```

Pass environment object into panel controller.

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/KamiNotch/AppDelegate.swift Sources/KamiNotch/UI/PanelView.swift Sources/KamiNotch/Terminal Tests/KamiNotchTests

git commit -m "feat: embed terminal panel view"
```
