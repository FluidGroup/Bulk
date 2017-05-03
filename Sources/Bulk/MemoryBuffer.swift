//
// MemoryBuffer.swift
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

public final class MemoryBuffer: Buffer {
  
  var buffer: [String]
  let size: Int
  let lock = NSRecursiveLock()
  var cursor: Int = 0
  
  public init(size: Int) {
    self.size = size
    self.buffer = [String].init(repeating: "", count: size)
  }
  
  public func write(formatted string: String) -> [String] {
    lock.lock()
    defer {
      lock.unlock()
    }
    
    buffer[cursor] = string
    
    cursor += 1
    
    if cursor == size {
      return purge()
    } else {
      return []
    }
  }
  
  public func purge() -> [String] {
    let _buffer = buffer
    for i in 0..<size {
      buffer[i] = ""
    }
    cursor = 0
    return _buffer.filter { $0.isEmpty == false }
  }
}
