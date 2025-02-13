//
// BasicFormatter.swift
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

public struct LogBasicFormatter: Sendable {
      
  public struct LevelString: Sendable {
    public var verbose = "[VERBOSE]"
    public var debug = "[DEBUG]"
    public var info = "[INFO]"
    public var warn = "[WARN]"
    public var error = "[ERROR]"
  }
  
  public let dateFormatter: DateFormatter
  
  public var levelString = LevelString()
    
  public init() {
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    self.dateFormatter = formatter
    
  }
  
  public func format(element: LogData) -> String {
    
    let level: String = {
      switch element.level {
      case .verbose: return levelString.verbose
      case .debug: return levelString.debug
      case .info: return levelString.info
      case .warn: return levelString.warn
      case .error: return levelString.error
      }
    }()
    
    let timestamp = dateFormatter.string(from: element.date)
    
    let file = URL(string: element.file.description)?.deletingPathExtension()
    
    let string = "[\(timestamp)] \(level) \(file?.lastPathComponent ?? "???").\(element.function):\(element.line) \(element.body)"
    
    return string
  }
}
