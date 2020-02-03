//
//  BulkSink.swift
//  Bulk
//
//  Created by muukii on 2020/02/04.
//

import Foundation

public final class BulkSink<Element>: BulkSinkType {
    
  private let targetQueue = DispatchQueue.init(label: "me.muukii.bulk")
  
  private let targets: [AnyTarget<Element>]
  
  private var timer: BulkBufferTimer!
  
  private let input: (Element) -> Void
    
  public init(
    buffer: AnyBuffer<Element>,
    debounceDueTime: DispatchTimeInterval = .seconds(10),
    targets: [AnyTarget<Element>]
  ) {
    
    self.targets = targets
    
    let output: ([Element]) -> Void = { elements in
      targets.forEach {
        $0.write(formatted: elements)
      }
    }
    
    self.timer = BulkBufferTimer(interval: debounceDueTime, queue: targetQueue) {
      let elements = buffer.purge()
      output(elements)
    }
          
    input = { element in
      
      switch buffer.write(element: element) {
      case .flowed(let elements):
        // TODO: align interface of Collection
        return output(elements.map { $0 })
      case .stored:
        break
      }
      
    }
            
  }
  
  deinit {
    
  }
  
  public func send(_ element: Element) {
    targetQueue.async {
      self.input(element)
    }
  }
  
}
