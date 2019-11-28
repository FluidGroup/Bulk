//
// Formatter.swift
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

public protocol FormatterType {
  
  associatedtype Element
  associatedtype FormatType
  
  func format(element: Element) -> FormatType
}

extension FormatterType {
  
  public func wrapped() -> FormatterWrapper<Element, FormatType> {
    .init(backing: self)
  }
}

public struct FormatterWrapper<Element, FormatType>: FormatterType {
  
  private let _format: (_ element: Element) -> FormatType
  
  public init<Formatter: FormatterType>(backing: Formatter) where Formatter.Element == Element, Formatter.FormatType == FormatType {
    self._format = backing.format
  }
  
  public func format(element: Element) -> FormatType {
    _format(element)
  }
  
}
