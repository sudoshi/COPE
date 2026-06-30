// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)  // macOS support is verification-only — lets `swift build` type-check the UI layer.
    ],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    targets: [
        .target(
            name: "DesignSystem"
            // When Fraunces/Figtree .ttf assets are added, bundle them here with
            // `resources: [.process("Resources")]` — see CopeFontRegistration.swift.
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"]
        )
    ]
)
