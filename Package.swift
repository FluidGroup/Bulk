// swift-tools-version:5.6
import PackageDescription

let package = Package(
  name: "Bulk",  
  platforms: [
    .macOS(.v10_12),
    .iOS(.v10),
    .tvOS(.v10),
    .watchOS(.v3)
  ],
  products: [
    .library(name: "Bulk", targets: ["Bulk"]),
    .library(name: "BulkLogger", targets: ["BulkLogger"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "Bulk", dependencies: []),
    .target(name: "BulkLogger", dependencies: ["Bulk"]),
    .testTarget(name: "BulkTests", dependencies: ["Bulk"]),
  ]
)
