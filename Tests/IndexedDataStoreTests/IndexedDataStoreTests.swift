import XCTest
@testable import IndexedDataStore

final class IndexedDataStoreTests: XCTestCase {
    private var dataStore: IndexedDataStore!
    
    override func setUpWithError() throws {
        dataStore = try IndexedDataStore(name: "Test")
    }
    
    override func tearDownWithError() throws {
        dataStore = nil
    }
    
    func testStoreAndLoad() throws {
        let storeExpectation = XCTestExpectation(description: "Store")
        dataStore.storeData({ return "Data".data(using: .utf8) }, identifier: "abc") { status in
            switch status {
            case .failed(let error):
                XCTFail("Store operation should not fail with error \(error)")
            case .noData:
                XCTFail("Store operation should not fail")
            case .success(let identifier):
                XCTAssertEqual(identifier, "abc")
                storeExpectation.fulfill()
            }
        }
        wait(for: [storeExpectation], timeout: 5)
        
        let loadExpectation = XCTestExpectation(description: "Load")
        dataStore.loadData(forIdentifier: "abc", dataTransformer: { data in String(data: data, encoding: .utf8) }) { string in
            XCTAssertEqual(string, "Data")
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5)
    }

    static var allTests = [
        ("testStoreAndLoad", testStoreAndLoad),
    ]
}
