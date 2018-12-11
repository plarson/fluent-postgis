// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "FluentPostGIS",
    products: [
        // FluentPostgreSQL support for PostGIS
        .library(
            name: "FluentPostGIS",
            targets: ["FluentPostGIS"]),
    ],
    dependencies: [
        // Swift ORM framework (queries, models, and relations) for building NoSQL and SQL database integrations.
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0"),

        // 🐘 Non-blocking, event-driven Swift client for PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),

        // Well Known Binary Encoding and Decoding
        .package(url: "https://github.com/plarson/WKCodable", .branch("master")),
    ],
    targets: [
        .target(
            name: "FluentPostGIS",
            dependencies: ["FluentPostgreSQL", "WKCodable"]),
        .testTarget(
            name: "FluentPostGISTests",
            dependencies: ["FluentBenchmark", "FluentPostGIS"]),
    ]
)
