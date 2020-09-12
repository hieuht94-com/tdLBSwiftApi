// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tdLBApi",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "tdLBApi",
            targets: ["Api", "Geometry", "OutputData", "QVecOutputDir"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        //        .package(url: "https://github.com/apple/swift-numerics", from: "0.0.5"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Api",
            dependencies: []),
        .target(
            name: "Geometry",
            dependencies: ["Api"]),
        .target(
            name: "OutputData",
            dependencies: ["Api"]),
        .target(
            name: "QVecOutputDir",
            dependencies: ["Api"]),
        
        .testTarget(
            name: "ApiTests",
            dependencies: ["Api"]),
        .testTarget(
            name: "GeometryTests",
            dependencies: ["Api"]),
        .testTarget(
            name: "OutputDataTests",
            dependencies: ["Api"]),
        .testTarget(
            name: "QVecOutputDirTests",
            dependencies: ["Api"])
    ]
)
