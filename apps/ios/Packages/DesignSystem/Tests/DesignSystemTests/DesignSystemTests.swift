import XCTest
@testable import DesignSystem

final class DesignSystemTests: XCTestCase {
    func testMoodScaleHasTenStops() {
        XCTAssertEqual(CopeMood.colors.count, 10)
        XCTAssertEqual(CopeMood.words.count, 10)
    }

    func testMoodLookupClampsOutOfRange() {
        // Values outside 1...10 clamp to the ends rather than crashing.
        XCTAssertEqual(CopeMood.word(for: 0), CopeMood.words.first)
        XCTAssertEqual(CopeMood.word(for: 99), CopeMood.words.last)
    }
}
