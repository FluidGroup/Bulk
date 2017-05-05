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
  
  public struct TargetConfiguration {
    public let buffer: Buffer
    public let target: Target
    
    /// Init
    ///
    /// - Parameters:
    ///   - target: output Target
    ///   - buffer: default is NoBuffer()
    public init(target: Target, buffer: Buffer = NoBuffer()) {
      self.buffer = buffer
      self.target = target
    }
  }

  public let plugins: [Plugin]
  public let formatter: Formatter
  public let writeBuffer: Buffer
  public let bulkBuffer: Buffer
  public let target: Target
  
  private let lock = NSRecursiveLock()
  
  private var timer: Timer?
  
  public var isWritingTarget: Bool = false
  
  public init(
    plugins: [Plugin],
    formatter: Formatter,
    bulkConfiguration: BulkConfiguration? = nil,
    targetConfiguration: TargetConfiguration
    ) {
    
    self.plugins = plugins
    self.formatter = formatter
    self.target = targetConfiguration.target
    self.writeBuffer = targetConfiguration.buffer
    
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
    
    loadBuffer()
  }
  
  deinit {
    
    bulkBuffer.purge().forEach {
      _ = writeBuffer.write(formatted: $0)
    }
  }
  
  func loadBuffer() {
    lock.lock(); defer { lock.unlock() }
    __write(self.writeBuffer.purge())
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
    
    let formatted = formatter.format(log: appliedLog)
    
    let r = bulkBuffer.write(formatted: formatted)
    
    __write(r)
  }
  
  private func __write(_ r: [String]) {
    
    lock.lock(); defer { lock.unlock() }
    
    timer?.tap()
    
    guard r.isEmpty == false else { return }
    
    if isWritingTarget == false {
      
      // to Target
      
      isWritingTarget = true
      
      let group = DispatchGroup()

      group.enter()
      
      target.write(formatted: r, completion: {
        
        group.leave()
        
      })
      
      _ = group.wait(timeout: DispatchTime.now() + .seconds(10))
            
      self.isWritingTarget = false
      self.__write(self.writeBuffer.purge())   
      
    } else {
      
      // to Buffer
      
      for _r in r {
        _ = writeBuffer.write(formatted: _r)
      }
    }    
  }
}
