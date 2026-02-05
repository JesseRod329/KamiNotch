import XCTest
@testable import KamiNotch

@MainActor
final class HotkeyManagerTests: XCTestCase {
    func test_register_calls_handler() {
        let handler = HotkeyHandlerSpy()
        let manager = HotkeyManager(register: handler.register)
        manager.registerToggle(action: { handler.called = true })
        handler.trigger()
        XCTAssertTrue(handler.called)
    }
}

final class HotkeyHandlerSpy {
    var called = false
    private var callback: (() -> Void)?

    func register(_ name: String, _ block: @escaping () -> Void) {
        callback = block
    }

    func trigger() {
        callback?()
    }
}
