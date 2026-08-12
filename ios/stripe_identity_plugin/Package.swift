// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "stripe_identity_plugin",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "stripe-identity-plugin", targets: ["stripe_identity_plugin"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/stripe/stripe-ios.git", from: "25.14.0")
    ],
    targets: [
        .target(
            name: "stripe_identity_plugin",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "StripeIdentity", package: "stripe-ios")
            ],
            resources: []
        )
    ]
)
