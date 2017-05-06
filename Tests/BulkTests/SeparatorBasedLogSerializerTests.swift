//
// SeparatorBasedLogSerializer.swift
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

import XCTest

@testable import Bulk

class SeparatorBasedLogSerializerTests: XCTestCase {
  
  let serializer = SeparatorBasedLogSerializer()
  
  func testEmptySerialize() {
    
    _success(Log(level: .verbose, date: Date(), body: "", file: "", function: "", line: 0, isActive: true))
    _success(Log(level: .debug, date: Date(), body: "", file: "", function: "", line: 0, isActive: true))
    _success(Log(level: .info, date: Date(), body: "", file: "", function: "", line: 0, isActive: true))
    _success(Log(level: .warn, date: Date(), body: "", file: "", function: "", line: 0, isActive: true))
    _success(Log(level: .error, date: Date(), body: "", file: "", function: "", line: 0, isActive: true))

  }
  
  func testBodySerialize() {
    
    _success(Log(level: .verbose, date: Date(), body: "abc,def", file: "", function: "", line: 0, isActive: true))
    _success(Log(level: .verbose, date: Date(), body: "abc\ndef", file: "", function: "", line: 0, isActive: true))

  }
  
  func testIncludeSeparator() {
    _fail(Log(level: .verbose, date: Date(), body: "abc\tdef", file: "", function: "", line: 0, isActive: true))
  }
  
  func create() -> Log {
    return Log(level: .verbose, date: Date(), body: "abc,def", file: "Sample.swift", function: "viewDidLoad()", line: 100, isActive: true)
  }
  
  func testPerformance_100() {
    
    measure {
      for _ in 0..<100 {
        self._success(self.create())
      }
    }
  }
  
  func testPerformance_1000() {
    
    measure {
      for _ in 0..<1000 {
        self._success(self.create())
      }
    }
  }
  
  func testPerformance_10000() {
    
    measure {
      for _ in 0..<10000 {
        self._success(self.create())
      }
    }
  }
  
  func _success(_ log: Log) {
    do {
      let r = try serializer.serialize(log: log)
      let _r = try serializer.deserialize(source: r)
      
      XCTAssertEqual(log, _r)
      
    } catch {
      XCTFail("\(error)")
    }
  }
  
  func _fail(_ log: Log) {
    do {
      let r = try serializer.serialize(log: log)
      let _r = try serializer.deserialize(source: r)
      
      XCTAssertEqual(log, _r)
      XCTFail("Wrong")
      
    } catch {

    }
  }
}

extension Log: Equatable {
  
  public static func == (lhs: Log, rhs: Log) -> Bool {
    
    guard
      lhs.body == rhs.body,
      lhs.date == rhs.date,
      lhs.file == rhs.file,
      lhs.function == rhs.function,
      lhs.level == rhs.level,
      lhs.isActive == rhs.isActive else {
        return false
    }
    
    return true
  }
}
