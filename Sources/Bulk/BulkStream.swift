//
//  BulkStream.swift
//  Bulk
//
//  Created by muukii on 2020/02/03.
//

import Foundation

#if canImport(Combine)

import Combine

@available(iOS 13, macOS 10.15, *)
public final class BulkStream<Element> {
  
  private let stream = PassthroughSubject<Element, Never>()
  
  private let targetQueue = DispatchQueue.init(label: "me.muukii.bulk")
  
  private let targets: [TargetWrapper<Element>]
  
  private var subscriptions = Set<AnyCancellable>()
  
  public init(
    buffer: BufferWrapper<Element>,
    maxInterval: DispatchTimeInterval = .seconds(10),
    targets: [TargetWrapper<Element>]
  ) {
    
    self.targets = targets
    
    stream
      .useBuffer(buffer, interval: maxInterval, queue: targetQueue)
      .sink { (elements) in
        
        targets.forEach {
          // TODO: align interface of Collection
          $0.write(formatted: elements.map { $0 }) {
            
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
  
  func useBuffer(
    _ buffer: BufferWrapper<Output>,
    interval: DispatchTimeInterval,
    queue: DispatchQueue
  ) -> UsingBuffer<Self, Output> {
    .init(upstream: self, buffer: buffer, interval: interval, queue: queue)
  }
  
}

@available(iOS 13.0, *)
struct UsingBuffer<Upstream: Publisher, Element>: Publisher where Upstream.Output == Element, Upstream.Failure == Never {
  
  typealias Output = ContiguousArray<Element>
  typealias Failure = Never
  
  private let upstream: Upstream
  private let buffer: BufferWrapper<Element>
  private let interval: DispatchTimeInterval
  private let queue: DispatchQueue
  
  init(
    upstream: Upstream,
    buffer: BufferWrapper<Element>,
    interval: DispatchTimeInterval,
    queue: DispatchQueue
  ) {
    self.upstream = upstream
    self.buffer = buffer
    self.interval = interval
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
    private var timer: Timer!
    
    init(
      downstream: Downstream,
      buffer: BufferWrapper<Element>,
      interval: DispatchTimeInterval,
      queue: DispatchQueue
    ) {
      
      self.downstream = downstream
      self.buffer = buffer
      
      self.timer = Timer(interval: interval, queue: queue) { [weak self] in
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
