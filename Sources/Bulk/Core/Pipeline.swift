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
public class Pipeline {
  
  public struct BulkConfiguration {
    public let buffer: Buffer
    public let timeout: DispatchTimeInterval

    public init(buffer: Buffer, timeout: DispatchTimeInterval) {
      self.buffer = buffer
      self.timeout = timeout
    }
  }
  
  public struct TargetConfiguration<F: Formatter, T: Target> where F.FormatType == T.FormatType {
    
    public let formatter: F
    public let target: T
    public let buffer: Buffer
    
    public init(formatter: F, target: T, buffer: Buffer = NoBuffer()) {
      
      self.formatter = formatter
      self.target = target
      self.buffer = buffer
    }
  }

  public let plugins: [Plugin]
  public let writeBuffer: Buffer
  public let bulkBuffer: Buffer
  
  private let lock = NSRecursiveLock()
  
  private var timer: Timer?
  
  public var isWritingTarget: Bool = false
  
  private var writeProcess: (([Log]) -> Void)!
  
  public init<F, T>(
    plugins: [Plugin],
    bulkConfiguration: BulkConfiguration? = nil,
    targetConfiguration: TargetConfiguration<F, T>
    ) {
    
    self.plugins = plugins
    self.writeBuffer = targetConfiguration.buffer
    
    let formatter = targetConfiguration.formatter
    let target = targetConfiguration.target
    
    if let c = bulkConfiguration {
      self.bulkBuffer = c.buffer
      self.timer = Timer(
        interval: c.timeout,
        queue: .global(),
        timeouted: { [weak self] in
          self?.loadBuffer()
      })
    } else {
      self.bulkBuffer = NoBuffer()
      self.timer = nil
    }
    
    self.writeProcess = { [weak self] r in
      
      guard let `self` = self else { return }
      
      guard r.isEmpty == false else { return }
      
      if self.isWritingTarget == false {
        
        // to Target
        
        self.isWritingTarget = true
        
        let group = DispatchGroup()
        
        group.enter()
        
        let formattedLogs = r.map(formatter.format(log: ))
        
        target.write(formatted: formattedLogs, completion: {
          group.leave()
        })
        
        _ = group.wait(timeout: DispatchTime.now() + .seconds(10))
        
        self.isWritingTarget = false
        self.__write(self.writeBuffer.purge())
        
      } else {
        
        // to Buffer
        
        for _r in r {
          _ = self.writeBuffer.write(log: _r)
        }
      }
    }
    
    loadBuffer()
  }
  
  deinit {
    
    bulkBuffer.purge().forEach {
      _ = writeBuffer.write(log: $0)
    }
  }
  
  func loadBuffer() {
    lock.lock(); defer { lock.unlock() }
    __write(bulkBuffer.purge())
  }
  
  func write(log: Log) {
    
    lock.lock(); defer { lock.unlock() }
    
    let appliedLog = plugins
      .reduce(log) { log, plugin in
        plugin.apply(log: log)
    }
    
    guard appliedLog.isActive == true else {
      return
    }
    
    switch bulkBuffer.write(log: appliedLog) {
    case .flowed(let logs):
      __write(logs)
    case .stored:
      break
    }
  }

  @inline(__always)
  private func __write(_ r: [Log]) {
    lock.lock(); defer { lock.unlock() }
    timer?.tap()
    writeProcess(r)
  }
}
