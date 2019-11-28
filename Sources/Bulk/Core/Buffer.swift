//
// Buffer.swift
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

public enum BufferResult<Element> {
  case stored
  case flowed(ContiguousArray<Element>)
}

public protocol BufferType {
  
  associatedtype Element
    
  ///
  var hasSpace: Bool { get }
  
  /// Buffer item
  ///
  /// - Parameter string:
  /// - Returns: 
  func write(element: Element) -> BufferResult<Element>
  
  /// Purge buffered items
  ///
  /// - Returns: purged items
  func purge() -> ContiguousArray<Element>
}

extension BufferType {
  
  public func wrapped() -> BufferWrapper<Element> {
    .init(backing: self)
  }
}

public struct BufferWrapper<Element>: BufferType {
  
  private let _hasSpace: () -> Bool
  private let _purge: () -> ContiguousArray<Element>
  private let _write: (_ element: Element) -> BufferResult<Element>
  
  public init<Buffer: BufferType>(backing: Buffer) where Buffer.Element == Element {
    self._hasSpace = {
      backing.hasSpace
    }
    self._purge = backing.purge
    self._write = backing.write
  }
  
  public var hasSpace: Bool {
    _hasSpace()
  }
  
  public func write(element: Element) -> BufferResult<Element> {
    _write(element)
  }
  
  public func purge() -> ContiguousArray<Element> {
    _purge()
  }
        
}
