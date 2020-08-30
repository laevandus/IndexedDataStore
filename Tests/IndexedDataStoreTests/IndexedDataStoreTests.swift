import XCTest
@testable import IndexedDataStore

final class IndexedDataStoreTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(IndexedDataStore().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
