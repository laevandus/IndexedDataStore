//
//  IndexedDataStore.swift
//  IndexedDataStore
//
//  Created by Toomas Vahter on 30.08.2020.
//

import Foundation

/// Persistent data store with data objects indexed by identifier.
public final class IndexedDataStore {
    
    // MARK: Creating the Data Store
    
    /// The name of the data store.
    public let name: String
    
    private let dataStoreURL: URL
    private let queue: DispatchQueue
    
    /// Creates a data store with the given name.
    /// - Parameter name: The name of the data store.
    public init(name: String) throws {
        self.name = name
        queue = DispatchQueue(label: "com.augmentedcode.indexeddatastore", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem)
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        dataStoreURL = documentsURL.appendingPathComponent(name, isDirectory: true)
        try FileManager.default.createDirectory(at: dataStoreURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func url(forIdentifier identifier: Identifier) -> URL {
        return dataStoreURL.appendingPathComponent(identifier.trimmingCharacters(in: .whitespacesAndNewlines), isDirectory: false)
    }
    
    // MARK: Loading Data
    
    /// Loads data asynchonously from the persistent data store.
    /// - Parameters:
    ///   - identifier: The identifier of the data.
    ///   - dataTransformer: Transforms data to a specified type.
    ///   - completionHandler: The block to execute after the operation’s main task is completed.
    public func loadData<T>(forIdentifier identifier: Identifier, dataTransformer: @escaping (Data) -> T?, completionHandler: @escaping (T?) -> Void) {
        queue.async {
            let url = self.url(forIdentifier: identifier)
            guard FileManager.default.fileExists(atPath: url.path) else {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
                return
            }
            do {
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                let object = dataTransformer(data)
                DispatchQueue.main.async {
                    completionHandler(object)
                }
            }
            catch {
                print("Failed reading data at URL \(url).")
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            }
        }
    }
    
    // MARK: Storing Data
    
    /// Value type of the identifier.
    public typealias Identifier = String
    
    /// Store data asynchronously in persistent data store.
    /// - Parameters:
    ///   - dataProvider: The block providing data. Runs on a background thread.
    ///   - identifier: The identifier of the data.
    ///   - completionHandler: The block to execute after the operation’s main task is completed.
    public func storeData(_ dataProvider: @escaping () -> Data?, identifier: Identifier = UUID().uuidString, completionHandler: @escaping (Result<Identifier, Error>) -> Void) {
        queue.async(flags: .barrier) {
            let url = self.url(forIdentifier: identifier)
            guard let data = dataProvider(), !data.isEmpty else {
                DispatchQueue.main.async {
                    completionHandler(.failure(IndexedDataStoreError.noDataProvided))
                }
                return
            }
            do {
                try data.write(to: url, options: .atomic)
                DispatchQueue.main.async {
                    completionHandler(.success(identifier))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    // MARK: Removing Data
    
    /// Removes data stored in the persistent data store.
    /// - Parameter identifier: The identifier of the data.
    public func removeData(forIdentifier identifier: Identifier) {
        queue.async(flags: .barrier) {
            let url = self.url(forIdentifier: identifier)
            guard FileManager.default.fileExists(atPath: url.path) else { return }
            do {
                try FileManager.default.removeItem(at: url)
            }
            catch {
                print("Failed removing file at URL \(url) with error \(error).")
            }
        }
    }
    
    /// Removes all the stored data objects.
    public func removeAll() {
        queue.async(flags: .barrier) {
            do {
                let urls = try FileManager.default.contentsOfDirectory(at: self.dataStoreURL, includingPropertiesForKeys: nil, options: [])
                try urls.forEach({ try FileManager.default.removeItem(at: $0) })
            }
            catch {
                print("Failed removing all files with error \(error).")
            }
        }
    }
}

/// Error indicating a reason why data was not written to the disk.
public enum IndexedDataStoreError: Error {
    /// Data provider did not return any data.
    case noDataProvided
}
