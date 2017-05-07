import Bulk
import Dispatch

#if os(macOS)
  
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
        target: ConsoleTarget()
      )
    )
    
    log.add(pipeline:
      Pipeline(
        plugins: [],
        formatter: BasicFormatter(),
        target: FileTarget(filePath: "/Users/muukii/Desktop/bulk.log")
      )
    )
    
    log.add(pipeline:
      AsyncPipeline(
        plugins: [
          MyPlugin(),
          ],
        formatter: BasicFormatter(),
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
  
  class AsyncConsoleTarget: Target {
    
    init() {
      
    }
    
    func write(formatted items: [String], completion: @escaping () -> Void) {
      DispatchQueue.global(qos: .utility).async {
        strings.forEach {
          print($0)
        }
        completion()
      }
    }
  }
  
  
  func buffer() {
    
    let log = Logger()
    
//    log.add(pipeline:
//      Pipeline(
//        plugins: [],
//        formatter: BasicFormatter(),
//        bulkBuffer: MemoryBuffer(size: 2),
//        writeBuffer: FileBuffer(size: 4, filePath: "/Users/muukii/Desktop/bulk-buffer.log"),
//        target: ConsoleTarget()
//      )
//    )
    
      log.add(pipeline:
        AsyncPipeline(
          plugins: [],
          formatter: BasicFormatter(),
          bulkBuffer: MemoryBuffer(size: 2),
          writeBuffer: FileBuffer(size: 4, filePath: "/Users/muukii/Desktop/bulk-buffer.log"),
          target: AsyncConsoleTarget(),
          queue: DispatchQueue.init(label: "me.muukii.balk")
        )
      )
    
    for i in 0..<23 {
      log.debug("\(i)\n\(i)")
      print("---")
    }
  }
    
  //basic()
buffer()
  
sleep(1)
  
#endif
