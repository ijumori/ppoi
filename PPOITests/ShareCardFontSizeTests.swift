import XCTest
@testable import PPOI

final class ShareCardFontSizeTests: XCTestCase {
    // MARK: - Without reflection

    func test_veryShort_noReflection_returns80() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 8, hasReflection: false), 80)
    }

    func test_short_noReflection_returns72() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 15, hasReflection: false), 72)
    }

    func test_medium_noReflection_returns64() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 20, hasReflection: false), 64)
    }

    func test_long_noReflection_returns56() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 30, hasReflection: false), 56)
    }

    func test_veryLong_noReflection_returns48() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 50, hasReflection: false), 48)
    }

    // MARK: - Boundaries (no reflection)

    func test_boundary12_noReflection_returns80() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 12, hasReflection: false), 80)
    }

    func test_boundary13_noReflection_returns72() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 13, hasReflection: false), 72)
    }

    func test_boundary18_noReflection_returns72() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 18, hasReflection: false), 72)
    }

    func test_boundary19_noReflection_returns64() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 19, hasReflection: false), 64)
    }

    // MARK: - With reflection

    func test_veryShort_withReflection_returns64() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 8, hasReflection: true), 64)
    }

    func test_short_withReflection_returns56() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 15, hasReflection: true), 56)
    }

    func test_medium_withReflection_returns48() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 22, hasReflection: true), 48)
    }

    func test_long_withReflection_returns40() {
        XCTAssertEqual(ShareCardExportView.quoteFontSize(textLength: 40, hasReflection: true), 40)
    }

    // MARK: - Compact vs full mode comparison

    func test_compactAlwaysSmallerThanFull_sameLengths() {
        for length in [5, 12, 18, 26, 40] {
            let compact = ShareCardExportView.quoteFontSize(textLength: length, hasReflection: true)
            let full = ShareCardExportView.quoteFontSize(textLength: length, hasReflection: false)
            XCTAssertLessThan(compact, full, "length=\(length): compact should be smaller than full")
        }
    }
}
