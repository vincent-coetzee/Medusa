// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MedusaObjectModel",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MedusaObjectModel",
            targets: ["MedusaObjectModel"]),
    ],
    dependencies: [
        .package(path: "../MedusaCore"),
        .package(path: "../MedusaStorage")
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MedusaObjectModel",
            dependencies: [
                .product(name: "MedusaCore",package: "MedusaCore"),
                .product(name: "MedusaStorage",package: "MedusaStorage")
                ]),
        .testTarget(
            name: "MedusaObjectModelTests",
            dependencies: ["MedusaObjectModel"]),
    ]
)
