// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "security_plus",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "security_plus", targets: ["security_plus"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "security_plus",
            dependencies: [],
            resources: []
        )
    ]
)
