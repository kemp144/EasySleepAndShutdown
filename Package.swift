// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "EasySleepShutdown",
    platforms: [
        .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "EasySleepShutdown",
            path: "Sources/EasySleepShutdown",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
