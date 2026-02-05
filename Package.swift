// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KamiNotch",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "KamiNotch", targets: ["KamiNotch"])
    ],
    targets: [
        .executableTarget(
            name: "KamiNotch",
            path: "Sources/KamiNotch"
        ),
        .testTarget(
            name: "KamiNotchTests",
            dependencies: ["KamiNotch"],
            path: "Tests/KamiNotchTests"
        )
    ]
)
