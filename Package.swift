// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "quiver-notebook",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // Vapor — HTTP server and routing
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),

        // Leaf — HTML template rendering
        .package(url: "https://github.com/vapor/leaf.git", from: "4.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
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
