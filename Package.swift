// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "Bulk",
  platforms: [
    .macOS(.v11),
    .iOS(.v16),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(name: "Bulk", targets: ["Bulk"]),
    .library(name: "BulkLogger", targets: ["BulkLogger"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "Bulk", dependencies: []),
    .target(name: "BulkLogger", dependencies: ["Bulk"]),
    .testTarget(name: "BulkTests", dependencies: ["Bulk"]),
  ]
)
