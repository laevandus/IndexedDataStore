// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IndexedDataStore",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "IndexedDataStore",
            targets: ["IndexedDataStore"])
    ],
    targets: [
        .target(
            name: "IndexedDataStore",
            dependencies: [],
            path: "IndexedDataStore"
        ),
        .testTarget(
            name: "IndexedDataStoreTests",
            dependencies: ["IndexedDataStore"],
            path: "IndexedDataStoreTests"
        )
    ]
)
