import Bulk
import Dispatch

let bulk = Logger()

class MyPlugin: Plugin {
  func map(log: Log) -> Log {
    var log = log
    log.body = "Tweaked:: " + log.body
    return log
  }
}

bulk.add(pipeline:
  Pipeline(
    plugins: [
      MyPlugin()
    ],
    formatter: BasicFormatter(),
    target: ConsoleTarget()
  )
)

bulk.add(pipeline:
  Pipeline(
    plugins: [],
    formatter: BasicFormatter(),
    target:
    FileTarget(filePath: "/Users/muukii/Desktop")
  )
)

bulk.add(pipeline:
  AsyncPipeline(
    plugins: [
      MyPlugin(),
    ],
    formatter: BasicFormatter(),
    target: ConsoleTarget(),
    queue: DispatchQueue.global()
  )
)

bulk.verbose("test-verbose", 1, 2, 3)
bulk.debug("test-debug", 1, 2, 3)
bulk.info("test-info", 1, 2, 3)
bulk.warn("test-warn", 1, 2, 3)
bulk.error("test-error", 1, 2, 3)

bulk.verbose("a", "b", 1, 2, 3, ["a", "b"])

