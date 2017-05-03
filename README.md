# Bulk

[![Version](https://img.shields.io/cocoapods/v/Bulk.svg?style=flat)](http://cocoapods.org/pods/Bulk)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-333333.svg)
---

> ⚠️ WARNING ⚠️ This project is in a prerelease state. There is active work going on that will result in API changes that can/will break code while things are finished. Use with caution.

---

Bulk is **powerful & flexible logging framework**

<img width=382 src="arch.png">

# Usage

## Basic Usage

```swift
let Log = Logger()

// Setup output targets

// Logging synchronously
Log.add(pipeline:
  Pipeline(
    plugins: [
      MyPlugin()
    ],
    formatter: BasicFormatter(),
    target: ConsoleTarget()
  )
)

Log.add(pipeline:
  Pipeline(
    plugins: [],
    formatter: BasicFormatter(),
    target:
    FileTarget(filePath: "/Users/muukii/Desktop")
  )
)

// Logging asynchronously

Log.add(pipeline:
  AsyncPipeline( // <-- 😎< asynchronously
    plugins: [],
    formatter: BasicFormatter(),
    target: ConsoleTarget(),
    queue: DispatchQueue.global() // <-- 🤓< Specify DispatchQueue
  )
)
Log.verbose("Something log")
Log.debug("Something log")
Log.info("Something log")
Log.warn("Something log")
Log.error("Something log")

// We can use this like Swift.print()

Log.verbose("a", "b", 1, 2, 3, ["a", "b"]) // => a b 1 2 3 ["a", "b"]
```

## Plugins

```swift

class MyPlugin: Plugin {
  func map(log: Log) -> Log {
    var log = log
    log.body = "Tweaked:: " + log.body
    return log
  }
}

Log.add(pipeline: Pipeline(plugins: [MyPlugin()], formatter: BasicFormatter(), target: ConsoleTarget()))

```

## Create CustomTarget

You can create customized `Target`

Example

```swift
open class ConsoleTarget: Target {
    
  public init() {
    
  }
  
  open func write(formatted string: String) {
    print(string)
  }
}
```

# Installation

## CocoaPods

```
pod "Bulk"
```

## Carthage

```
github "muukii/Bulk"
```

## SwiftPackageManager

```swift
import PackageDescription

let package = Package(
  name: "MyApp",
  dependencies: [
    .Package(url: "https://github.com/muukii/Bulk.git", majorVersion: 0),
  ]
)
```

# LICENSE

Bulk Framework is released under the MIT License.
