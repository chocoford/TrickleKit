// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrickleKit",
    platforms: [
        .iOS(.v16),
        .watchOS(.v6),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "TrickleKit", targets: ["TrickleEditor", "TrickleAWS", "TrickleStore", "TrickleUI"]),
        .library(name: "TrickleCore", targets: ["TrickleCore"]),
        .library(name: "TrickleEditor", targets: ["TrickleEditor"]),
        .library(name: "TrickleSocketSupport", targets: ["TrickleSocketSupport"]),
        //        .library(name: "TrickleCore", targets: ["TrickleCore"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/chocoford/ChocofordKit.git", branch: "main"),
//        .package(url: "https://github.com/chocoford/ImageViewer.git", branch: "main"),
        .package(path: "../ImageViewer"),
        .package(url: "https://github.com/chocoford/WebProvider.git", branch: "main"),
        .package(url: "https://github.com/raspu/Highlightr.git", from: "2.1.2"),
        //        .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.0"),
        //        .package(url: "https://github.com/soto-project/soto.git", from: "6.5.0"),
        //        .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "0.16.0"),
            .package(url: "https://github.com/Kitura/Swift-JWT.git", from: "4.0.0"),
        .package(url: "https://github.com/socketio/socket.io-client-swift", from: "16.1.0"),
        //        .package(url: "https://github.com/aws-amplify/aws-sdk-ios-spm", from: "2.33.7")
//        .package(url: "https://github.com/awslabs/aws-sdk-swift.git", from: "0.33.0")
            .package(url: "https://github.com/soto-project/soto.git", from: "7.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TrickleCore",
            dependencies: [
                .product(name: "ChocofordEssentials", package: "ChocofordKit"),
            ],
            path: "Sources/TrickleCore"
        ),
        .target(
            name: "TrickleAuth",
            dependencies: [
                "TrickleCore",
                .product(
                    name: "SwiftJWT",
                    package: "Swift-JWT"
                ),
            ],
            path: "Sources/TrickleAuth"
        ),
        .target(name: "TrickleSocketSupport", dependencies: ["TrickleCore"], path: "Sources/TrickleSocketSupport"),
        .target(name: "TrickleStore",
                dependencies: ["TrickleSocketSupport", "WebProvider", "TrickleAuth", .product(name: "SocketIO", package: "socket.io-client-swift")],
                path: "Sources/Store",
                resources: [
                    .process("Resources")
                ]),
        .target(name: "TrickleUI",
                dependencies: [
                    "TrickleCore",
                    .product(name: "ChocofordUI", package: "ChocofordKit"),
                ],
                path: "Sources/TrickleUI"),
        .target(name: "TrickleAWS",
                dependencies: [
                    "TrickleCore",
//                    .product(name: "AWSS3", package: "aws-sdk-swift"),
//                    .product(name: "AWSCognitoIdentity", package: "aws-sdk-swift"),
//                    .product(name: "AWSCore", package: "aws-sdk-ios-spm"),
//                    .product(name: "AWSS3", package: "aws-sdk-ios-spm"),
//                    .product(name: "AWSCognitoAuth", package: "aws-sdk-ios-spm")
                        .product(name: "SotoS3", package: "soto"),
                        .product(name: "SotoCognitoIdentity", package: "soto")
                ], path: "Sources/TrickleAWS"),
        .target(
            name: "TrickleEditor",
            dependencies: [
                "TrickleCore",
                "TrickleUI",
                "TrickleAWS",
                .product(name: "ChocofordUI", package: "ChocofordKit"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                "Highlightr",
                "ImageViewer"
            ],
            path: "Sources/TrickleEditor",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(name: "TrickleKitTests", dependencies: ["TrickleCore", "TrickleEditor"]),
    ]
)
