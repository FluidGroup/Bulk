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
  
  private let _send: (Element) -> Void
  private let _onFlush: () -> Void

  private let buffer: AnyBuffer<Element>
    
  public init(
    buffer: AnyBuffer<Element>,
    debounceDueTime: DispatchTimeInterval = .seconds(10),
    targets: [AnyTarget<Element>]
  ) {

    self.buffer = buffer
    self.targets = targets
    
    let output: ([Element]) -> Void = { elements in
      targets.forEach {
        $0.write(items: elements)
      }
    }
    
    self.timer = BulkBufferTimer(interval: debounceDueTime, queue: targetQueue) {
      let elements = buffer.purge()
      output(elements)
    }
          
    self._send = { [targetQueue] newElement in

      targetQueue.async {
        switch buffer.write(element: newElement) {
        case .flowed(let elements):
          // TODO: align interface of Collection
          return output(elements.map { $0 })
        case .stored:
          break
        }
      }      
      
    }

    self._onFlush = {
      let elements = buffer.purge()
      output(elements)
    }
            
  }
  
  deinit {
    
  }
  
  public func send(_ element: Element) {
    targetQueue.async {
      self._send(element)
    }
  }

  public func flush() {
    targetQueue.async {
      self._onFlush()
    }
  }
  
}
