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
        // Pinned below 4.122 to avoid the swift-configuration transitive dependency,
        // which requires a newer Swift toolchain than some educator machines have.
        .package(url: "https://github.com/vapor/vapor.git", "4.89.0" ..< "4.122.0"),

        // Leaf — HTML template rendering
        .package(url: "https://github.com/vapor/leaf.git", "4.3.0" ..< "5.0.0")
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
