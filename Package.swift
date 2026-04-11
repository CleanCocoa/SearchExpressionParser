// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SearchExpressionParser",
    platforms: [
      .macOS("13"),
    ],
    products: [
        .library(
            name: "SearchExpressionParser",
            targets: ["SearchExpressionParser"]),
    ],
    targets: [
        .target(
            name: "SearchExpressionParser",
            dependencies: []),
        .testTarget(
            name: "SearchExpressionParserTests",
            dependencies: ["SearchExpressionParser"]),
    ]
)
