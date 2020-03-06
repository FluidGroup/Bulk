//
//  TimerTests.swift
//  Bulk-Carthage
//
//  Created by muukii on 5/5/17.
//
//

import Foundation
import Dispatch
import XCTest

@testable import Bulk

class TimerTests: XCTestCase {
  
  func testTimer() {
    
    let g = DispatchGroup()
    
    g.enter()
    
    var count: Int = 0
    
    let timer = Bulk.BulkBufferTimer(interval: .milliseconds(100), queue: .global()) {
      count += 1
      g.leave()
    }
    
    timer.tap()
    Thread.sleep(forTimeInterval: 0.01)
    timer.tap()
    Thread.sleep(forTimeInterval: 0.09)
    timer.tap()
    
    g.wait()
    
    Thread.sleep(forTimeInterval: 1)
    
    XCTAssert(count == 1)
  }
}
