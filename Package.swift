import PackageDescription

let package = Package(
  name: "Bulk",
  targets: [
    Target(name: "Bulk"),
    Target(name: "BulkDemo", dependencies: ["Bulk"]),
  ],
  dependencies: [
  ]
)
