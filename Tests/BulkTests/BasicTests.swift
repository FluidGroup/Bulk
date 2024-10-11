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
  
  func testSimple() async {
    
    let sink = BulkSink<PassthroughBuffer<String>>.init(
      buffer: .init(),
      targets: [
        .init(backing: MyTarget<String>())
      ]
    )
    
    await sink.send("A")
    await sink.send("A")
    await sink.send("A")

//    sink.send("A")
//    sink.send("B")
//    sink.send("C")
  }
  
}
