// Bulk.swift
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

public final class Logger {
  
  // MARK: - Properties
  
  private(set) public var pipelines: [Pipeline] = []
  
  // MARK: - Initializers
  
  public init() {
    
  }
  
  // MARK: - Functions
  
  @inline(__always)
  private func _write(level: Log.Level, _ items: [Any], file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    
    let now = Date()
    
    let body = items.map { String(describing: $0) }.joined(separator: " ")
    
    let log = Log(level: level, date: now, body: body, file: file, function: function, line: line, isActive: true)
    
    pipelines.forEach { target in
      target.write(log: log)
    }
  }
  
  public func write(level: Log.Level, _ items: Any..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    _write(level: level, items, file: file, function: function, line: line)
  }
  
  /// Verbose
  public func verbose(_ items: Any..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    _write(level: .verbose, items, file: file, function: function, line: line)
  }
  
  /// Debug
  public func debug(_ items: Any..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    _write(level: .debug, items, file: file, function: function, line: line)
  }

  /// Info
  public func info(_ items: Any..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    _write(level: .info, items, file: file, function: function, line: line)
  }

  /// Warning
  public func warn(_ items: Any..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    _write(level: .warn, items, file: file, function: function, line: line)
  }

  /// Error
  public func error(_ items: Any..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    _write(level: .error, items, file: file, function: function, line: line)
  }
  
  public func add(pipeline: Pipeline) {
    pipelines.append(pipeline)
  }
}
