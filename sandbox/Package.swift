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
        .package(url: "https://github.com/waynewbishop/quiver.git", from: "1.6.0")
    ],
    targets: [
        .executableTarget(
            name: "Runner",
            dependencies: [
                .product(name: "Quiver", package: "quiver")
            ],
            path: "Sources/Runner"
        ),
        // Tests for the Dataset loading and editing calls. The Notebook builds
        // only the Runner product, so this target never slows a student's run.
        .testTarget(
            name: "RunnerTests",
            dependencies: ["Runner"],
            path: "Tests/RunnerTests"
        )
    ]
)
