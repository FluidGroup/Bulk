//
//  BasicTests.swift
//  BulkTests
//
//  Created by muukii on 2020/03/07.
//

import Foundation

import XCTest

import Bulk

final class BasicTests: XCTestCase {
  
  struct MyTarget<Element>: TargetType {
    
    func write(items: [Element]) {
      print(items)
    }
  }
  
  func testSimple() {
    
    let sink = BulkSink<String>(
      buffer: MemoryBuffer<String>.init(size: 1).asAny(),
      targets: [
        MyTarget<String>().asAny()
      ]
    )

    sink.send("A")
    sink.send("B")
    sink.send("C")
  }
}
