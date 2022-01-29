//
//  Test.swift
//  IndexedDataStoreTests.swift
//
//  Created by Toomas Vahter on 12.09.2020.
//

@testable import IndexedDataStore
import XCTest

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
        dataStore.storeData({ "Data".data(using: .utf8) }, identifier: "abc") { result in
            switch result {
            case .success(let identifier):
                XCTAssertEqual(identifier, "abc")
                storeExpectation.fulfill()
            case .failure(let error):
                XCTFail("Store operation should not fail with error \(error)")
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
    
    func testStoreAndLoadAsync() async throws {
        let identifier = try await dataStore.storeData({ "Data".data(using: .utf8) }, identifier: "abc")
        XCTAssertEqual(identifier, "abc")
        let string = await dataStore.loadData(forIdentifier: "abc", dataTransformer: { String(decoding: $0, as: UTF8.self) })
        XCTAssertEqual(string, "Data")
    }
}
