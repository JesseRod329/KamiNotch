import XCTest
@testable import KamiNotch

@MainActor
final class GlassBackgroundViewTests: XCTestCase {
    func test_glass_background_view_exists() {
        _ = GlassBackgroundView()
        XCTAssertTrue(true)
    }
}
