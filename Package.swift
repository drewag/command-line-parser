// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "CommandLineParser",
    products: [
        .library(name: "CommandLineParser", targets: ["CommandLineParser"]),
    ],
    targets: [
        .target(name: "CommandLineParser", path: "Sources"),
        .testTarget(name: "CommandLineParserTests", dependencies: ["CommandLineParser"]),
    ]
)
