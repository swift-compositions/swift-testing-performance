// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-testing-performance",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "TestingPerformance",
            targets: ["TestingPerformance"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-numeric.git", branch: "main")
    ],
    targets: [
        .target(
            name: "MemoryAllocation",
            dependencies: [
                .target(name: "CAllocationTracking", condition: .when(platforms: [.linux]))
            ],
            path: "Sources/MemoryAllocation"
        ),
        .target(
            name: "CAllocationTracking",
            path: "Sources/CAllocationTracking",
            linkerSettings: [
                .linkedLibrary("dl", .when(platforms: [.linux]))
            ]
        ),
        .target(
            name: "TestingPerformance",
            dependencies: [
                .product(name: "Numeric", package: "swift-numeric"),
                .target(name: "MemoryAllocation")
            ]
        ),
        .testTarget(
            name: "TestingPerformance Tests",
            dependencies: ["TestingPerformance"]
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
