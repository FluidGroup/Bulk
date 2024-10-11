
public protocol BulkSinkType<Element>: Actor {
  
  associatedtype Element
  
  func send(_ element: Element)
}

public actor BulkSink<B: Buffer>: BulkSinkType {

  public typealias Element = B.Element

  private let targets: [any TargetType<Element>]

  private let timer: BulkBufferTimer

  private let buffer: B

  public init(
    buffer: B,
    debounceDueTime: Duration = .seconds(1),
    targets: [any TargetType<Element>]
  ) {

    self.buffer = buffer
    self.targets = targets
    
    weak var instance: BulkSink?
        
    self.timer = BulkBufferTimer(interval: debounceDueTime) { [instance] in
      await instance?.purge()
    }
        
    instance = self
            
  }
  
  deinit {
    
  }
  
  private func purge() {    
    let elements = buffer.purge()
    elements.forEach {
      self.send($0)
    }
  }

  public func send(_ newElement: Element) {
    timer.tap()
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
    timer.tap()
    let elements = buffer.purge()
    targets.forEach {
      $0.write(items: elements)
    }
  }
  
}
