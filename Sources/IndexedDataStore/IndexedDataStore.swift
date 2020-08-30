import Foundation

public final class IndexedDataStore {
    
    // MARK: Creating the Data Store
    
    public let name: String
    private let dataStoreURL: URL
    private let queue: DispatchQueue
    
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
    
    public func loadData<T>(forIdentifier identifier: Identifier, dataTransformer: @escaping (Data) -> (T?), completionHandler block: @escaping (T?) -> ()) {
        queue.async {
            let url = self.url(forIdentifier: identifier)
            guard FileManager.default.fileExists(atPath: url.path) else {
                DispatchQueue.main.async {
                    block(nil)
                }
                return
            }
            do {
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                let object = dataTransformer(data)
                DispatchQueue.main.async {
                    block(object)
                }
            }
            catch {
                print("Failed reading data at URL \(url).")
                DispatchQueue.main.async {
                    block(nil)
                }
            }
        }
    }
    
    // MARK: Storing Data
    
    public typealias Identifier = String
    
    public enum StorageStatus {
        case failed(Error)
        case noData
        case success(Identifier)
    }
    
    public func storeData(_ dataProvider: @escaping () -> (Data?), identifier: Identifier = UUID().uuidString, completionHandler block: @escaping (StorageStatus) -> ()) {
        queue.async(flags: .barrier) {
            let url = self.url(forIdentifier: identifier)
            guard let data = dataProvider(), !data.isEmpty else {
                DispatchQueue.main.async {
                    block(.noData)
                }
                return
            }
            do {
                try data.write(to: url, options: .atomic)
                DispatchQueue.main.async {
                    block(.success(identifier))
                }
            }
            catch {
                DispatchQueue.main.async {
                    block(.failed(error))
                }
            }
        }
    }
    
    // MARK: Removing Data
    
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
