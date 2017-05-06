//
// SeparatorLogSerializer.swift
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

public struct SeparatorLogSerializer: LogSerializer {
  
  public enum Error: Swift.Error {
    case serializedDataIsBroken
  }
  
  private enum Position: Int {
    case level = 0
    case date = 1
    case body = 2
    case file = 3
    case function = 4
    case line = 5
  }
  
  public typealias SerializedType = String
  
  public init() {}
  
  public func deserialize(source: String) throws -> Log {

    let s = source.characters.split(separator: "\t").map { String($0) }
    
    guard s.count == 6 else {
      throw Error.serializedDataIsBroken
    }
    
    guard let level = Int(s[Position.level.rawValue]).map(Log.Level.init(__int: )) else {
      throw Error.serializedDataIsBroken
    }
    guard let date = TimeInterval(s[Position.date.rawValue]).map(Date.init(timeIntervalSince1970: )) else {
      throw Error.serializedDataIsBroken
    }
    let body = s[Position.body.rawValue].replacingOccurrences(of: "\\n", with: "\n")
    let file = s[Position.file.rawValue]
    let function = s[Position.function.rawValue]
    
    guard let line = UInt(s[Position.line.rawValue]) else {
      throw Error.serializedDataIsBroken
    }
        
    return Log(
      level: level,
      date: date,
      body: body,
      file: file,
      function: function,
      line: line,
      isActive: true
    )
  }
  
  public func serialize(log: Log) throws -> String {
    
    let level = log.level.__int.description
    let date = log.date.timeIntervalSince1970.description
    let body = log.body.replacingOccurrences(of: "\n", with: "\\n")
    let file = log.file.description
    let function = log.function.description
    let line = log.line.description
    
    return [
      level,
      date,
      body,
      file,
      function,
      line,
      ]
      .joined(separator: "\t")
  }
}

fileprivate extension Log.Level {
  
  fileprivate var __int: Int {
    switch self {
    case .verbose: return 0
    case .debug: return 1
    case .info: return 2
    case .warn: return 3
    case .error: return 4
    }
  }
  
  fileprivate init(__int: Int) {
    switch __int {
    case 0:
      self = .verbose
    case 1:
      self = .debug
    case 2:
      self = .info
    case 3:
      self = .warn
    case 4:
      self = .error
    default:
      assertionFailure()
      self = .verbose
    }
  }
}

