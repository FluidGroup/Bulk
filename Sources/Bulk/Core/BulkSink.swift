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

  private let buffer: AnyBuffer<Element>
    
  public init(
    buffer: AnyBuffer<Element>,
    debounceDueTime: DispatchTimeInterval = .seconds(10),
    targets: [AnyTarget<Element>]
  ) {

    self.buffer = buffer
    self.targets = targets

    self.timer = BulkBufferTimer(interval: debounceDueTime) { [weak self] in

      guard let self else { return }

      let elements = buffer.purge()

      self.targets.forEach {
        $0.write(items: elements)
      }

      self.timer.tap()
    }
            
  }
  
  deinit {
    
  }
  
  public func send(_ newElement: Element) {
    targetQueue.async { [self] in
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
  }

  public func flush() {
    targetQueue.async { [self] in
      let elements = buffer.purge()
      targets.forEach {
        $0.write(items: elements)
      }
    }
  }
  
}
