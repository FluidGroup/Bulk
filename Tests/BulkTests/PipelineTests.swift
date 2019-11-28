//
// PipelineTests.swift
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

class PipelineTests: XCTestCase {

  func testBasic() {
    
    let log = Logger()
    
    let target = TestTarget()
    
    log.add(pipeline:
      Pipeline(
        plugins: [],
        inputBuffer: PassthroughBuffer().wrapped(),
        inputTimebox: .seconds(0),
        outputBuffer: PassthroughBuffer().wrapped(),
        formatter: TestFormatter().wrapped(),
        target: target.wrapped()
      )
    )
    
    log.verbose("A")
    log.debug("B")
    log.info("C")
    log.warn("D")
    log.error("E")
    
    XCTAssert(target.results.count == 5)
    XCTAssert(target.results == ["A", "B", "C", "D", "E"])
  }
  
  func testMultiThread() {
    
    let log = Logger()
    
    let target = TestTarget()
    
    log.add(pipeline:
      Pipeline(
        plugins: [],
        inputBuffer: PassthroughBuffer().wrapped(),
        inputTimebox: .seconds(0),
        outputBuffer: PassthroughBuffer().wrapped(),
        formatter: TestFormatter().wrapped(),
        target: target.wrapped()
      )
    )
    
    let g = DispatchGroup()
    
    for i in 0..<10 {
      
      g.enter()
      
      DispatchQueue.global().async {
        log.debug(i)
        g.leave()
      }
    }
    
    g.wait()
    
    XCTAssertEqual(target.results.count, 10)
  }

  func testIsActive() {

    final class StringFilterPlugin : PluginType {
           
      func filter(element: LogData) -> Bool {
        !element.body.contains("[skip]")
      }
    }

    let log = Logger()
    let target = TestTarget()

    log.add(pipeline:
      Pipeline(
        plugins: [StringFilterPlugin().wrapped()],
        inputBuffer: PassthroughBuffer().wrapped(),
        inputTimebox: .seconds(0),
        outputBuffer: PassthroughBuffer().wrapped(),
        formatter: TestFormatter().wrapped(),
        target: target.wrapped()
      )
    )

    log.verbose("a")
    log.verbose("[skip]a")
    log.verbose("b")

    XCTAssertEqual(target.results, ["a", "b"])
  }

  func testContext() {

    let log = Logger()
    let contextLog = log.context(["Context"])
    let target = TestTarget()

    log.add(pipeline:
      Pipeline(
        plugins: [],
        inputBuffer: PassthroughBuffer().wrapped(),
        inputTimebox: .seconds(0),
        outputBuffer: PassthroughBuffer().wrapped(),
        formatter: TestFormatter().wrapped(),
        target: target.wrapped()
      )
    )

    log.verbose("boo")
    contextLog.verbose("hello")

    XCTAssertEqual(target.results, ["boo", "Context hello"])
  }
}
