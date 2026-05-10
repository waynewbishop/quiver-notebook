// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "quiver-notebook",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Pelican",
            path: "Sources/Pelican"
        ),
        .executableTarget(
            name: "App",
            dependencies: ["Pelican"],
            path: "Sources/App"
        ),
        .testTarget(
            name: "PelicanTests",
            dependencies: ["Pelican"],
            path: "Tests/PelicanTests"
        )
    ]
)
