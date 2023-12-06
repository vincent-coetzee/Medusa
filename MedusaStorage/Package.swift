// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MedusaStorage",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "Fletcher",targets: ["Fletcher"]),
        .library(name: "MedusaStorage",targets: ["MedusaStorage","Fletcher"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "Fletcher",dependencies: []),
        .target(name: "MedusaStorage",dependencies: ["Fletcher"])
    ]
)
