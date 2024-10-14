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

@_exported import Bulk
import Foundation

public final class Logger: Sendable {

  public var isEnabled: Bool {
    get {
      lock.lock()
      defer {
        lock.unlock()
      }
      return _isEnabled
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      _isEnabled = newValue
    }
  }

  // MARK: - Properties

  private nonisolated(unsafe) var sinks: [any BulkSinkType<LogData>]
  private nonisolated(unsafe) var _isEnabled: Bool = true
  private let lock = NSLock()

  public let context: [String]

  // MARK: - Initializers

  public init(context: String, sinks: [any BulkSinkType<LogData>]) {
    self.context = [context]
    self.sinks = sinks
  }

  private init(context: String, source: Logger) {
    self.context = source.context + CollectionOfOne(context)
    self.sinks = source.sinks
  }

  // MARK: - Functions

  @inline(__always)
  func _write(
    level: LogData.Level,
    _ items: [Any],
    file: StaticString,
    function: StaticString,
    line: UInt,
    dsoHandle: UnsafeRawPointer
  ) {

    guard isEnabled else { return }

    let now = Date()

    let body =
      items
      .map { String(describing: $0) }
      .joined(separator: " ")

    let log = LogData(
      context: context,
      level: level,
      date: now,
      body: body,
      file: file.description,
      function: function.description,
      line: line
    )
    
    lock.lock()
    
    let usingSinks = self.sinks

    lock.unlock()
    
    Task { [usingSinks] in
      for sink in usingSinks {
        await sink.send(log)
      }
    }
  }

  public func write(
    level: LogData.Level,
    _ items: [Any],
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    dsoHandle: UnsafeRawPointer = #dsohandle
  ) {
    _write(level: level, items, file: file, function: function, line: line, dsoHandle: dsoHandle)
  }

  /// Verbose
  public func verbose(
    _ items: Any...,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    dsoHandle: UnsafeRawPointer = #dsohandle
  ) {
    _write(level: .verbose, items, file: file, function: function, line: line, dsoHandle: dsoHandle)
  }

  /// Debug
  public func debug(
    _ items: Any...,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    dsoHandle: UnsafeRawPointer = #dsohandle
  ) {
    _write(level: .debug, items, file: file, function: function, line: line, dsoHandle: dsoHandle)
  }

  /// Info
  public func info(
    _ items: Any...,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    dsoHandle: UnsafeRawPointer = #dsohandle
  ) {
    _write(level: .info, items, file: file, function: function, line: line, dsoHandle: dsoHandle)
  }

  /// Warning
  public func warn(
    _ items: Any...,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    dsoHandle: UnsafeRawPointer = #dsohandle
  ) {
    _write(level: .warn, items, file: file, function: function, line: line, dsoHandle: dsoHandle)
  }

  /// Error
  public func error(
    _ items: Any...,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    dsoHandle: UnsafeRawPointer = #dsohandle
  ) {
    _write(level: .error, items, file: file, function: function, line: line, dsoHandle: dsoHandle)
  }

  public func addSink(_ sink: any BulkSinkType<LogData>) {
    lock.lock()
    defer {
      lock.unlock()
    }
    sinks.append(sink)
  }
  
  public func makeContextualLogger(context: String) -> Logger {
    return .init(context: context, source: self)
  }

  public func setIsEnabled(_ flag: Bool) -> Logger {
    isEnabled = flag
    return self
  }
}
