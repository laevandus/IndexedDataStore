//
//  IndexedDataStore+UIKit.swift
//  IndexedDataStore
//
//  Created by Toomas Vahter on 12.09.2020.
//

#if canImport(UIKit)
import UIKit

public extension IndexedDataStore {
    
    // MARK: Loading Images
    
    /// Loads image asynchonously from persistent data store.
    /// - Parameters:
    ///   - identifier: The identifier of the image.
    ///   - completionHandler: The block to execute after the operation’s main task is completed.
    func loadImage(forIdentifier identifier: Identifier, completionHandler: @escaping (UIImage?) -> Void) {
        loadData(forIdentifier: identifier, dataTransformer: { UIImage(data: $0) }, completionHandler: completionHandler)
    }
        
    // MARK: Storing Images
    
    /// Store data asynchronously in persistent data store.
    /// - Parameters:
    ///   - image: UIImage to store.
    ///   - identifier: The identifier of the image.
    ///   - completionHandler: The block to execute after the operation’s main task is completed.
    func storeImage(_ image: UIImage, identifier: Identifier = UUID().uuidString, completionHandler: @escaping (Result<Identifier, Error>) -> Void) {
        storeData({ image.jpegData(compressionQuality: 1.0) }, identifier: identifier, completionHandler: completionHandler)
    }
}
#endif

#if compiler(>=5.5) && canImport(UIKit)
extension IndexedDataStore {
    /// Loads image asynchonously from persistent data store.
    /// - Parameters:
    ///   - identifier: The identifier of the image.
    @available(iOS 15.0.0, *)
    func loadImage(forIdentifier identifier: Identifier) async -> UIImage? {
        return await loadData(forIdentifier: identifier, dataTransformer: { UIImage(data: $0) })
    }
    
    @available(iOS 15.0.0, *)
    func storeImage(_ image: UIImage, identifier: Identifier = UUID().uuidString) async throws -> Identifier {
        return try await storeData({ image.jpegData(compressionQuality: 1.0) }, identifier: identifier)
    }
}
#endif

