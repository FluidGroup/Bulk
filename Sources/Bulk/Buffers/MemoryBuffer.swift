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

public actor MemoryBuffer<Element>: BufferType {
  
  public var hasSpace: Bool {
    return cursor < size
  }
  
  var buffer: ContiguousArray<Element?>
  let size: Int
  var cursor: Int = 0
  
  public init(size: Int) {
    self.size = size
    self.buffer = ContiguousArray<Element?>.init(repeating: nil, count: size)
  }
  
  public func write(element: Element) -> BufferResult<Element> {
    
    buffer[cursor] = .some(element)
    
    cursor += 1
    
    if cursor == size {
      return .flowed(purge())
    } else {
      return .stored
    }
  }
  
  public func purge() -> [Element] {
    let _buffer = buffer
    for i in 0..<size {
      buffer[i] = nil
    }
    cursor = 0
    return .init(_buffer.compactMap { $0 })
  }
}
