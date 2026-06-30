// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FeatureToday",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "FeatureToday", targets: ["FeatureToday"])
    ],
    dependencies: [
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "FeatureToday",
            dependencies: ["DesignSystem"]
        )
    ]
)
