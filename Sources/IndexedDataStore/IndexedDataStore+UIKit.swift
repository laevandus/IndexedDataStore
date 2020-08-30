//
//  IndexedDataStore+UIKit.swift
//  
//
//  Created by Toomas Vahter on 30.08.2020.
//

#if canImport(UIKit)
import UIKit

public extension IndexedDataStore {
    func loadImage(forIdentifier identifier: Identifier, completionHandler block: @escaping (UIImage?) -> (Void)) {
        loadData(forIdentifier: identifier, dataTransformer: { UIImage(data: $0) }, completionHandler: block)
    }

    func storeImage(_ image: UIImage, identifier: Identifier = UUID().uuidString, completionHandler handler: @escaping (StorageStatus) -> ()) {
        storeData({ image.jpegData(compressionQuality: 1.0) }, identifier: identifier, completionHandler: handler)
    }
}
#endif
