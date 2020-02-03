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

import RxSwift

import Bulk

public final class RxBulkSink<Element>: BulkSinkType {
  
  private let stream = PublishSubject<Element>()
  
  private let targetQueue = DispatchQueue.init(label: "me.muukii.bulk")
  
  private let output = PublishSubject<[Element]>()
  
  private let disposeBag = DisposeBag()
  
  private var timer: BulkBufferTimer!
  
  public init(
    buffer: AnyBuffer<Element>,
    debounceDueTime: DispatchTimeInterval = .seconds(10),
    targets: [AnyTarget<Element>]
  ) {
    
    self.timer = BulkBufferTimer(interval: debounceDueTime, queue: targetQueue) { [weak self] in
      guard let self = self else { return }
      let elements = buffer.purge()
      _ = self.output.onNext(elements)
    }
        
    output
      .observeOn(SerialDispatchQueueScheduler(queue: targetQueue, internalSerialQueueName: ""))
      .subscribe(onNext: { elements in
        targets.forEach {
          $0.write(formatted: elements)
        }
      })
      .disposed(by: disposeBag)
    
    stream
      .flatMap { element -> Maybe<[Element]> in
        switch buffer.write(element: element) {
        case .flowed(let elements):
          return .just(elements)
        case .stored:
          return .empty()
        }
    }
    .subscribe(onNext: { [weak self] elements in
      self?.output.onNext(elements)
    })
    .disposed(by: disposeBag)
    
  }
  
  public func send(_ element: Element) {
    stream.onNext(element)
  }
  
}

