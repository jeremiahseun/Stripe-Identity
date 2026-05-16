// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "stripe_identity_plugin",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "stripe-identity-plugin", targets: ["stripe_identity_plugin"])
    ],
    dependencies: [
        .package(name: "FlutterMacOSFramework", path: "../FlutterMacOSFramework"),
        .package(url: "https://github.com/stripe/stripe-ios.git", from: "25.14.0")
    ],
    targets: [
        .target(
            name: "stripe_identity_plugin",
            dependencies: [
                .product(name: "FlutterMacOSFramework", package: "FlutterMacOSFramework"),
                .product(name: "StripeIdentity", package: "stripe-ios")
            ],
            resources: []
        )
    ]
)
