// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sandbox",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        // Quiver — statistics, linear algebra, and machine learning
        .package(url: "https://github.com/waynewbishop/quiver.git", from: "1.1.0"),

        // Structures — data structures and algorithms (trees, heaps, tries, graphs, stacks, queues)
        .package(url: "https://github.com/waynewbishop/bishop-algorithms-swift-package.git", from: "0.5.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Runner",
            dependencies: [
                .product(name: "Quiver", package: "quiver"),
                .product(name: "Structures", package: "bishop-algorithms-swift-package")
            ],
            path: "Sources/Runner"
        )
    ]
)
