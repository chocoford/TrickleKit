// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrickleKit",
    platforms: [
        .iOS(.v15), .watchOS(.v6), .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "TrickleKit", targets: ["TrickleCore", "TrickleAuth", "TrickleSocket"]),
        .library(name: "TrickleEditor", targets: ["TrickleEditor"]),
        .library(name: "TrickleSocket", targets: ["TrickleSocket"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/chocoford/ChocofordKit.git", branch: "main"),
        .package(url: "https://github.com/chocoford/CFWebRepositoryProvider.git", branch: "main"),
        .package(url: "https://github.com/auth0/JWTDecode.swift.git", from: "3.0.0"),
        .package(url: "https://github.com/raspu/Highlightr.git", from: "2.1.2"),
        .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.5.0"),
//        .package(url: "https://github.com/socketio/socket.io-client-swift", .upToNextMinor(from: "16.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TrickleCore",
            dependencies: [
                .product(name: "ChocofordTools", package: "ChocofordKit"),
                "CFWebRepositoryProvider",
                .product(name: "JWTDecode", package: "JWTDecode.swift"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "SotoS3", package: "soto"),
                .product(name: "SotoCognitoIdentity", package: "soto"),
            ],
            path: "Sources/TrickleCore",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "TrickleEditor",
            dependencies: [
                .product(name: "ChocofordUI", package: "ChocofordKit"),
                "Highlightr",
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "SotoS3", package: "soto"),
                .product(name: "SotoCognitoIdentity", package: "soto"),
            ],
            path: "Sources/TrickleEditor"
        ),
        .target(name: "TrickleSocket", dependencies: ["TrickleCore"], path: "Sources/SocketRepository"),
        .target(name: "TrickleAuth", path: "Sources/TrickleAuth"),
        .testTarget(name: "TrickleKitTests", dependencies: ["TrickleCore"]),
    ]
)
