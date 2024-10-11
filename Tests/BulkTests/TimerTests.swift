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
  
  func testTimer() async {
    
    var count: Int = 0
    
    let timer = Bulk.BulkBufferTimer(interval: .milliseconds(100)) {
      count += 1
    }
    
    await timer.tap()
    try? await Task.sleep(for: .milliseconds(10))
    await timer.tap()
    try? await Task.sleep(for: .milliseconds(10))
    await timer.tap()
        
    try? await Task.sleep(for: .milliseconds(1000))
        
    XCTAssert(count == 1)
  }
}
