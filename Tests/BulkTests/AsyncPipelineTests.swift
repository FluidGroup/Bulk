//
// AsyncPipelineTest.swift
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
import Dispatch

import XCTest

@testable import Bulk

class AsyncPipelineTests: XCTestCase {
  
  func testOnce() {
    
    let g = DispatchGroup()
    
    let log = Logger()
    
    let target = TestTarget()
    
    log.add(pipeline:
      AsyncPipeline(
        plugins: [],
        inputBuffer: PassthroughBuffer().wrapped(),
        inputTimebox: .seconds(0),
        outputBuffer: PassthroughBuffer().wrapped(),
        formatter: TestFormatter().wrapped(),
        target: target.wrapped(),
        queue: .global()
      )
    )
  
    g.enter()
    
    target.writed = {
      XCTAssert(Thread.isMainThread == false)
      g.leave()
    }

    log.debug("A")
    
    g.wait()
    
    XCTAssertEqual(target.writeCompletedCount, 1)
  }
  
  func testConcurrent_multi() {
    
    let g = DispatchGroup()
    
    let log = Logger()
    
    let target = TestTarget()
    
    log.add(pipeline:
      AsyncPipeline(
        plugins: [],
        inputBuffer: PassthroughBuffer().wrapped(),
        inputTimebox: .seconds(0),
        outputBuffer: PassthroughBuffer().wrapped(),
        formatter: TestFormatter().wrapped(),
        target: target.wrapped(),
        queue: .global()
      )
    )
    
    target.writed = {
//      print(Thread.current)
      g.leave()
    }
    
    for i in 0..<10 {
      
      g.enter()
      
      log.debug(i)
    }
    
    g.wait()
    
    XCTAssertEqual(target.writeCompletedCount, 10)
    XCTAssertEqual(target.results, ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])
  }
  
  func testMultiThread() {
    
    let g = DispatchGroup()
    
    let log = Logger()
    
    let target = TestTarget()
    
    log.add(pipeline:
      AsyncPipeline(
        plugins: [],
        inputBuffer: PassthroughBuffer().wrapped(),
        inputTimebox: .seconds(0),
        outputBuffer: PassthroughBuffer().wrapped(),
        formatter: TestFormatter().wrapped(),
        target: target.wrapped(),
        queue: .global()
      )
    )
    
    target.writed = {
//      print(Thread.current)
      g.leave()
    }
    
    for i in 0..<10 {
      
      g.enter()
      
      DispatchQueue.global().async {
        log.debug(i)
      }
    }
    
    g.wait()
    
    XCTAssertEqual(target.writeCompletedCount, 10)
    
    // target.results will be random
  }
}
