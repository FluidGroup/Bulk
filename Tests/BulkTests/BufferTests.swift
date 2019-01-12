//
// FileBufferTests.swift
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

class BufferTests: XCTestCase {
  
  var fileBuffer: FileBuffer!
  var memoryBuffer: MemoryBuffer!
  
  override func setUp() {
    fileBuffer = FileBuffer(size: 5, filePath: "/var/tmp/bulk-test.log")
    _ = fileBuffer.purge()
    
    memoryBuffer = MemoryBuffer(size: 5)
  }
  
  func testFileBuffer() {
    
    beStored(fileBuffer.write(log: create()))
    beStored(fileBuffer.write(log: create()))
    beStored(fileBuffer.write(log: create()))
    beStored(fileBuffer.write(log: create()))
    
    beFlowed(fileBuffer.write(log: create()))
    
    beStored(fileBuffer.write(log: create()))
    beStored(fileBuffer.write(log: create()))
    beStored(fileBuffer.write(log: create()))
    beStored(fileBuffer.write(log: create()))
    
    beFlowed(fileBuffer.write(log: create()))
  }
  
  func testMemoryBuffer() {
    
    beStored(memoryBuffer.write(log: create()))
    beStored(memoryBuffer.write(log: create()))
    beStored(memoryBuffer.write(log: create()))
    beStored(memoryBuffer.write(log: create()))
    
    beFlowed(memoryBuffer.write(log: create()))
    
    beStored(memoryBuffer.write(log: create()))
    beStored(memoryBuffer.write(log: create()))
    beStored(memoryBuffer.write(log: create()))
    beStored(memoryBuffer.write(log: create()))
    
    beFlowed(memoryBuffer.write(log: create()))
  }
  
  public func beStored(_ r: BufferResult) {
    guard case .stored = r else {
      XCTFail("")
      return
    }
  }
  
  public func beFlowed(_ r: BufferResult) {
    guard case .flowed = r else {
      XCTFail("")
      return
    }
  }
  
  private func create() -> LogData {
    return LogData(level: .verbose, date: Date(), body: "", file: "", function: "", line: 10, isActive: true)
  }
}

