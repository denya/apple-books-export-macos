// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AppleBooksExport",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "AppleBooksExport",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            path: "Sources/AppleBooksExport",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ])
    ]
)
