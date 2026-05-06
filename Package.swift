// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "quiver-notebook",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        // Vapor — HTTP server and routing
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),

        // Leaf — HTML template rendering
        .package(url: "https://github.com/vapor/leaf.git", from: "4.3.0")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf")
            ],
            path: "Sources/App"
        )
    ]
)
