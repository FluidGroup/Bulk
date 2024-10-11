
import Foundation

public actor BulkSink<Buffer: Buffer>: BulkSinkType {

  public typealias Element = Buffer.Element

  private let targets: [AnyTarget<Element>]

  private let timer: BulkBufferTimer

  private let buffer: Buffer

  public init(
    buffer: Buffer,
    debounceDueTime: Duration = .seconds(10),
    targets: [AnyTarget<Element>]
  ) {

    self.buffer = buffer
    self.targets = targets
    
    weak var instance: BulkSink?
        
    self.timer = BulkBufferTimer(interval: debounceDueTime) { [instance] in
      await instance?.purge()
    }
    
    Task {
      await timer.tap()
    }
    
    instance = self
            
  }
  
  deinit {
    
  }
  
  private func purge() {    
    let elements = buffer.purge(isolation: #isolation)
    elements.forEach {
      self.send($0)
    }
  }

  public func send(_ newElement: Element) {
    switch buffer.write(element: newElement, isolation: #isolation) {
    case .flowed(let elements):
      // TODO: align interface of Collection
      targets.forEach {
        $0.write(items: elements)
      }
    case .stored:
      break
    }
  }

  public func flush() {
    let elements = buffer.purge(isolation: #isolation)
    targets.forEach {
      $0.write(items: elements)
    }
  }
  
}
