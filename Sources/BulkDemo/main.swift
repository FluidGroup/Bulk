import Bulk
import Dispatch

func basic() {
  
  class MyPlugin: Plugin {
    func map(log: Log) -> Log {
      var log = log
      log.body = "Tweaked:: " + log.body
      return log
    }
  }
  
  let log = Logger()
  
  log.add(pipeline:
    Pipeline(
      plugins: [
        MyPlugin()
      ],
      formatter: BasicFormatter(),
      buffer: nil,
      target: ConsoleTarget()
    )
  )
  
  log.add(pipeline:
    Pipeline(
      plugins: [],
      formatter: BasicFormatter(),
      buffer: nil,
      target: FileTarget(filePath: "/Users/muukii/Desktop/bulk.log")
    )
  )
  
  log.add(pipeline:
    AsyncPipeline(
      plugins: [
        MyPlugin(),
        ],
      formatter: BasicFormatter(),
      buffer: nil,
      target: ConsoleTarget(),
      queue: DispatchQueue.global()
    )
  )
  
  log.verbose("test-verbose", 1, 2, 3)
  log.debug("test-debug", 1, 2, 3)
  log.info("test-info", 1, 2, 3)
  log.warn("test-warn", 1, 2, 3)
  log.error("test-error", 1, 2, 3)
  
  log.verbose("a", "b", 1, 2, 3, ["a", "b"])
  
}

func buffer() {
  
  let log = Logger()
  
//  log.add(pipeline:
//    Pipeline(
//      plugins: [],
//      formatter: BasicFormatter(),
//      buffer: MemoryBuffer(size: 4),
//      target: ConsoleTarget()
//    )
//  )
  
  log.add(pipeline:
    Pipeline(
      plugins: [],
      formatter: BasicFormatter(),
      buffer: FileBuffer(size: 4, filePath: "/Users/muukii/Desktop/bulk-buffer.log"),
      target: ConsoleTarget()
    )
  )
  
  for i in 0..<23 {
    log.debug(i)
    print("---")
  }
  
}

//basic()
buffer()
