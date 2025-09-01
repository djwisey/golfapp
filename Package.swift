// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "golfy",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "golfy", targets: ["golfy"])
    ],
    targets: [
        .target(
            name: "golfy",
            path: "golfy/golfy",
            resources: [
                .process("course.json"),
                .process("Assets.xcassets"),
                .process("golfy.xcdatamodeld")
            ]
        ),
        .testTarget(
            name: "golfyTests",
            dependencies: ["golfy"],
            path: "golfy/golfyTests"
        ),
        .testTarget(
            name: "golfyUITests",
            dependencies: ["golfy"],
            path: "golfy/golfyUITests"
        )
    ]
)
