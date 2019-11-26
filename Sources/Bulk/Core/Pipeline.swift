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
  
  public struct BulkConfiguration {
    public let buffer: BufferWrapper<Input>
    public let timeout: DispatchTimeInterval

    public init(buffer: BufferWrapper<Input>, timeout: DispatchTimeInterval) {
      self.buffer = buffer
      self.timeout = timeout
    }
  }
  
  public struct TargetConfiguration<Output> {
    
    public let formatter: FormatterWrapper<Input, Output>
    public let target: TargetWrapper<Output>
    public let buffer: BufferWrapper<Input>
    
    public init(
      formatter: FormatterWrapper<Input, Output>,
      target: TargetWrapper<Output>,
      buffer: BufferWrapper<Input>
    ) {
      
      self.formatter = formatter
      self.target = target
      self.buffer = buffer
    }
  }

  private let plugins: [PluginWrapper<Input>]
  public let writeBuffer: BufferWrapper<Input>
  public let bulkBuffer: BufferWrapper<Input>
  
  private let lock = NSRecursiveLock()
  
  private var timer: Timer?
  
  public var isWritingTarget: Bool = false
  
  private var writeProcess: (([Input]) -> Void)!
  
  public init<Output>(
    plugins: [PluginWrapper<Input>],
    bulkConfiguration: BulkConfiguration,
    targetConfiguration: TargetConfiguration<Output>
  ) {
    
    self.plugins = plugins
    self.writeBuffer = targetConfiguration.buffer
    
    let formatter = targetConfiguration.formatter
    let target = targetConfiguration.target
    
    let c = bulkConfiguration
    self.bulkBuffer = c.buffer
    self.timer = Timer(
      interval: c.timeout,
      queue: .global(),
      timeouted: { [weak self] in
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
        
        let formatted = elements.map(formatter.format)
                
        target.write(formatted: formatted, completion: {
          group.leave()
        })
        
        _ = group.wait(timeout: DispatchTime.now() + .seconds(10))
        
        self.isWritingTarget = false
        self.__write(self.writeBuffer.purge())
        
      } else {
        
        // to Buffer
        
        for _r in elements {
          _ = self.writeBuffer.write(element: _r)
        }
      }
    }
    
    loadBuffer()
  }
  
  deinit {
    
    bulkBuffer.purge().forEach {
      _ = writeBuffer.write(element: $0)
    }
  }
  
  func loadBuffer() {
    lock.lock(); defer { lock.unlock() }
    __write(bulkBuffer.purge())
  }
  
  func write(element: Input) {
    
    lock.lock(); defer { lock.unlock() }
    
    let appliedLog = plugins
      .reduce(element) { element, plugin in
        plugin.apply(element)
    }
    
    switch bulkBuffer.write(element: appliedLog) {
    case .flowed(let logs):
      __write(logs)
    case .stored:
      break
    }
  }

  @inline(__always)
  private func __write(_ r: [Input]) {
    lock.lock(); defer { lock.unlock() }
    timer?.tap()
    writeProcess(r)
  }
}
