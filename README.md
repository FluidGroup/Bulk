# Bulk / BulkLogger

[![Version](https://img.shields.io/cocoapods/v/Bulk.svg?style=flat)](http://cocoapods.org/pods/Bulk)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-333333.svg)

Bulk is a library for buffering the objects.
Pipeline(Sink) receives the object and emits the object bulked.

## What is for?

To pack a lot of elements would be helpful in several cases.
For example, sending the analytics events for your products with in house API.

- collect the many events
- pack it into one
- send these events as a set of events.

## Bulk module

### Make a sink

We call the pipeline that receives the object as `Sink`.

`Sink` receives the objects and emits the bulked object to multiple targets.

1. Select the buffer.

To create a bulk, we can choose several types of the buffer.<br>
Currently, Bulk provides 2 types below.

- MemoryBuffer
- FileBuffer

In this tutorial, we select MemoryBuffer.

2. Create the target

Target receives the bulked object from Sink.

Bulk does not privides default implemented Target.<br>
For now, you need to create it.

```swift
public protocol TargetType {

  associatedtype Element

  func write(items: [Element])
}
```

```swift
struct MyTarget<Element>: TargetType {

  func write(items: [Element]) {
    print(items)
  }
}
```

And finally, create BulkSink object.

```swift
let sink = BulkSink<String>(
  buffer: MemoryBuffer.init(size: 10).asAny(),
  targets: [
    MyTarget<String>().asAny()
  ]
)
```

Send the objects

```swift
sink.send("A")
sink.send("B")
sink.send("C")
```

`sink` sends the bulked object when Buffer receives the objects up to the specified size (10 elements in the example).

## BulkLogger module

The Logger as a library on top of Bulk.

BulkLogger provies `Logger` object that wraps `Sink` inside.

```swift
let logger = Logger(context: "", sinks: [
  BulkSink<LogData>(
    buffer: MemoryBuffer.init(size: 10).asAny(),
    targets: [

      TargetUmbrella.init(
        transform: LogBasicFormatter().format,
        targets: [
          LogConsoleTarget.init().asAny()
        ]
      ).asAny(),

      OSLogTarget(subsystem: "BulkDemo", category: "Demo").asAny()
    ]
  )
    .asAny()
])
```

Logger object send the log data to 2 targets (LogConsoleTarget and OSLogTarget)

```swift
logger.verbose("Hello")
```

# LICENSE

Bulk Framework is released under the MIT License.
