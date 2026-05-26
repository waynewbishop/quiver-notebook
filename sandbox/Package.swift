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
        .package(url: "https://github.com/waynewbishop/quiver.git", from: "1.2.5")
    ],
    targets: [
        .executableTarget(
            name: "Runner",
            dependencies: [
                .product(name: "Quiver", package: "quiver")
            ],
            path: "Sources/Runner"
        )
    ]
)
