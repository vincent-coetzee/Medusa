// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MedusaNetworking",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MedusaNetworking",
            targets: ["MedusaNetworking"]),
    ],
    dependencies: [
        .package(path: "../MedusaCore"),
        .package(path: "../MedusaStorage"),
        .package(path: "../MedusaObjectModel"),
        .package(path: "../MedusaPaging"),
        .package(path: "../Fletcher")
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MedusaNetworking",
            dependencies: [
                .product(name: "MedusaCore",package: "MedusaCore"),
                .product(name: "MedusaStorage",package: "MedusaStorage"),
                .product(name: "MedusaObjectModel",package: "MedusaObjectModel"),
                .product(name: "MedusaPaging",package: "MedusaPaging"),
                .product(name: "Fletcher",package: "Fletcher")
                ]),
        .testTarget(
            name: "MedusaNetworkingTests",
            dependencies: ["MedusaNetworking"]),
    ]
)
