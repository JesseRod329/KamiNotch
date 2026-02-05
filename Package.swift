// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KamiNotch",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "KamiNotch", targets: ["KamiNotch"])
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "1.16.0"),
        .package(url: "https://github.com/migueldeicaza/SwiftTerm", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "KamiNotch",
            dependencies: ["KeyboardShortcuts", "SwiftTerm"],
            path: "Sources/KamiNotch"
        ),
        .testTarget(
            name: "KamiNotchTests",
            dependencies: ["KamiNotch"],
            path: "Tests/KamiNotchTests"
        )
    ]
)
