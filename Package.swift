// swift-tools-version:5.6
import PackageDescription

let package = Package(
  name: "Bulk",  
  platforms: [
    .macOS(.v11),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6)
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
