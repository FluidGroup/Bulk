//
//  ContextLogger.swift
//  Bulk-Carthage
//
//  Created by muukii on 10/23/17.
//

import Foundation

public final class ContextLogger {

  public let logger: Logger
  private let prefixItemsClosure: () -> [Any]

  public init(logger: Logger, prefixItemsClosure: @autoclosure @escaping () -> [Any]) {
    self.logger = logger
    self.prefixItemsClosure = prefixItemsClosure
  }

  @inline(__always)
  private func _write(level: Log.Level, _ items: [Any], file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {

    logger._write(level: level, prefixItemsClosure() + items, file: file, function: function, line: line)
  }

  public func write(level: Log.Level, _ items: [Any], file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
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
}
