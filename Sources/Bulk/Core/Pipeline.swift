//
// Pipeline.swift
//
// Copyright (c) 2017 muukii
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
import Dispatch

/**
 * Logs => plugins => Target
 */
public class Pipeline<Input> {

  private let plugins: [PluginWrapper<Input>]
  public let inputBuffer: BufferWrapper<Input>
  public let outbutBuffer: BufferWrapper<Input>
  
  private let lock = NSRecursiveLock()
  
  private var timer: Timer?
  
  public var isWritingTarget: Bool = false
  
  private var writeProcess: ((ContiguousArray<Input>) -> Void)!
  
  public init<Output>(
    plugins: [PluginWrapper<Input>],
    inputBuffer: BufferWrapper<Input>,
    inputTimebox: DispatchTimeInterval,
    outputBuffer: BufferWrapper<Input>,
    formatter: FormatterWrapper<Input, Output>,
    target: TargetWrapper<Output>
  ) {
    
    self.plugins = plugins
    self.outbutBuffer = outputBuffer
    self.inputBuffer = inputBuffer
    self.timer = Timer(
      interval: inputTimebox,
      queue: .global(),
      onTimeout: { [weak self] in
        self?.loadBuffer()
    })
        
    self.writeProcess = { [weak self] elements in
      
      guard let `self` = self else { return }
      
      guard elements.isEmpty == false else { return }
      
      if self.isWritingTarget == false {
        
        // to Target
        
        self.isWritingTarget = true
        
        let group = DispatchGroup()
        
        group.enter()
        
        let formatted = elements.map(formatter.format).compactMap { $0 }
                        
        target.write(formatted: formatted, completion: {
          group.leave()
        })
        
        _ = group.wait(timeout: DispatchTime.now() + .seconds(10))
        
        self.isWritingTarget = false
        self.__write(self.outbutBuffer.purge())
        
      } else {
        
        // to Buffer
        
        for _r in elements {
          _ = self.outbutBuffer.write(element: _r)
        }
      }
    }
    
    loadBuffer()
  }
  
  deinit {
    
    inputBuffer.purge().forEach {
      _ = outbutBuffer.write(element: $0)
    }
  }
  
  func loadBuffer() {
    lock.lock(); defer { lock.unlock() }
    __write(inputBuffer.purge())
  }
  
  func write(element: Input) {
    
    lock.lock(); defer { lock.unlock() }
    
    let appliedLog = plugins
      .reduce(element) { element, plugin in
        plugin.apply(element)
    }
    
    switch inputBuffer.write(element: appliedLog) {
    case .flowed(let logs):
      __write(logs)
    case .stored:
      break
    }
  }

  @inline(__always)
  private func __write(_ r: ContiguousArray<Input>) {
    lock.lock(); defer { lock.unlock() }
    timer?.tap()
    writeProcess(r)
  }
}
