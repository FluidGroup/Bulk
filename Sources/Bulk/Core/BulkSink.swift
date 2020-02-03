//
// Copyright (c) 2020 Hiroshi Kimura(Muukii) <muuki.app@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public protocol BulkSinkType {
  
  associatedtype Element
    
  func send(_ element: Element)
}

extension BulkSinkType {
  
  public func wrapped() -> AnyBulkSink<Element> {
    .init(self)
  }
}

public final class AnyBulkSink<Element>: BulkSinkType {
  
  private let _send: (Element) -> Void

  public init<Sink: BulkSinkType>(_ source: Sink) where Sink.Element == Element {
    self._send = source.send
  }
  
  public func send(_ element: Element) {
    _send(element)
  }
  
}

#if canImport(Combine)

import Combine

@available(iOS 13, macOS 10.15, *)
public final class BulkSink<Element>: BulkSinkType {
  
  private let stream = PassthroughSubject<Element, Never>()
  
  private let targetQueue = DispatchQueue.init(label: "me.muukii.bulk")
  
  private let targets: [TargetWrapper<Element>]
  
  private var subscriptions = Set<AnyCancellable>()
  
  public init(
    buffer: BufferWrapper<Element>,
    debounceDueTime: DispatchTimeInterval = .seconds(10),
    targets: [TargetWrapper<Element>]
  ) {
    
    self.targets = targets
    
    stream
      .useBuffer(buffer, debounceDueTime: debounceDueTime, queue: targetQueue)
      .sink { (elements) in
        
        targets.forEach {
          // TODO: align interface of Collection
          $0.write(formatted: elements.map { $0 }) {
            // TODO:
          }
        }
    }
    .store(in: &subscriptions)
    
  }
  
  deinit {
    
  }
  
  public func send(_ element: Element) {
    
    stream.send(element)
  }
  
}

@available(iOS 13.0, *)
extension Publisher where Failure == Never {
  
  fileprivate func useBuffer(
    _ buffer: BufferWrapper<Output>,
    debounceDueTime: DispatchTimeInterval,
    queue: DispatchQueue
  ) -> UsingBuffer<Self, Output> {
    .init(
      upstream: self,
      buffer: buffer,
      debounceDueTime: debounceDueTime,
      queue: queue
    )
  }
  
}

@available(iOS 13.0, *)
fileprivate struct UsingBuffer<Upstream: Publisher, Element>: Publisher where Upstream.Output == Element, Upstream.Failure == Never {
  
  typealias Output = ContiguousArray<Element>
  typealias Failure = Never
  
  private let upstream: Upstream
  private let buffer: BufferWrapper<Element>
  private let interval: DispatchTimeInterval
  private let queue: DispatchQueue
  
  init(
    upstream: Upstream,
    buffer: BufferWrapper<Element>,
    debounceDueTime: DispatchTimeInterval,
    queue: DispatchQueue
  ) {
    self.upstream = upstream
    self.buffer = buffer
    self.interval = debounceDueTime
    self.queue = queue
  }
  
  func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
    let inner = Inner(downstream: subscriber, buffer: buffer, interval: interval, queue: queue)
    upstream.subscribe(inner)
  }
  
  @available(iOS 13.0, *)
  final class Inner<Downstream: Subscriber, Element>: Subscriber where Upstream.Output == Element, Downstream.Input == ContiguousArray<Element>, Downstream.Failure == Never {
      
    typealias Input = Element
    typealias Failure = Never
    
    private let downstream: Downstream
    private let buffer: BufferWrapper<Element>
    private var timer: BulkBufferTimer!
    
    init(
      downstream: Downstream,
      buffer: BufferWrapper<Element>,
      interval: DispatchTimeInterval,
      queue: DispatchQueue
    ) {
      
      self.downstream = downstream
      self.buffer = buffer
      
      self.timer = BulkBufferTimer(interval: interval, queue: queue) { [weak self] in
        guard let self = self else { return }
        let elements = self.buffer.purge()
        _ = self.downstream.receive(elements)
      }
      
    }
        
    func receive(subscription: Subscription) {
      downstream.receive(subscription: subscription)
    }
    
    func receive(_ input: Element) -> Subscribers.Demand {
      
      timer.tap()
      switch buffer.write(element: input) {
      case .stored:
        return .unlimited
      case .flowed(let elements):
        return downstream.receive(elements)
      }
      
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
      downstream.receive(completion: completion)
    }
           
  }
}



#endif
