//
//  IndexedDataStore+UIKit.swift
//  IndexedDataStore
//
//  Created by Toomas Vahter on 12.09.2020.
//

#if canImport(UIKit)
import UIKit

public extension IndexedDataStore {
    /// Loads image asynchonously from persistent data store.
    /// - Parameters:
    ///   - identifier: The identifier of the image.
    ///   - completionHandler: The block to execute after the operation’s main task is completed.
    func loadImage(forIdentifier identifier: Identifier, completionHandler: @escaping (UIImage?) -> Void) {
        loadData(forIdentifier: identifier, dataTransformer: { UIImage(data: $0) }, completionHandler: completionHandler)
    }
    
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
