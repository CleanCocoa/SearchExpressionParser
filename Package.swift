// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SearchExpressionParser",
    platforms: [
      .macOS("10.13"),
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
