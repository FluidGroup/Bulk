
import Foundation

public actor BulkSink<Buffer: BufferType>: BulkSinkType {

  public typealias Element = Buffer.Element

  private let targets: [AnyTarget<Element>]

  private var timer: BulkBufferTimer!

  private let buffer: Buffer

  public init(
    buffer: Buffer,
    debounceDueTime: DispatchTimeInterval = .seconds(10),
    targets: [AnyTarget<Element>]
  ) {

    self.buffer = buffer
    self.targets = targets
    
    self.timer = BulkBufferTimer(interval: debounceDueTime) { [weak self] in
      guard let self = self else { return }

      await self.batch { `self` in
        let elements = buffer.purge()
        elements.forEach {
          self.send($0)
        }
      }
    }
            
  }
  
  deinit {
    
  }

  private func batch(_ thunk: (isolated BulkSink) -> Void) {
    thunk(self)
  }

  public func send(_ newElement: Element) {
    switch buffer.write(element: newElement) {
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
    let elements = buffer.purge()
    targets.forEach {
      $0.write(items: elements)
    }
  }
  
}
