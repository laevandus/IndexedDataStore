// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IndexedDataStore",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "IndexedDataStore",
            targets: ["IndexedDataStore"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
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
