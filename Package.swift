// swift-tools-version:5.0

import PackageDescription
let package = Package(
  name: "Bulk",
  products: [
    .library(
      name: "Bulk",
      targets: ["Bulk"]
    )
  ],
  targets: [
    .target(
      name: "Bulk",
      path: "Sources/Bulk"
    )
  ],
  swiftLanguageVersions: [.v5]
)
