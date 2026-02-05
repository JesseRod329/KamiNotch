import XCTest
@testable import KamiNotch

@MainActor
final class WorkspaceSwitcherViewTests: XCTestCase {
    func test_workspace_switcher_exists() {
        _ = WorkspaceSwitcherView()
        XCTAssertTrue(true)
    }
}
