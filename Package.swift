import PackageDescription

let package = Package(
  name: "Zap",
  targets: [
    Target(name: "Zap"),
    Target(name: "ZapDemo", dependencies: ["Zap"]),
  ],
  dependencies: [
  ]
)
