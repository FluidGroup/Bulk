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
  
  func testNoBuffer() async {
    
    let sink = BulkSink<PassthroughBuffer<String>>.init(
      buffer: .init(),
      targets: [
        MyTarget<String>()
      ]
    )
    
    await sink.send("A")
    await sink.send("A")
    await sink.send("A")

//    sink.send("A")
//    sink.send("B")
//    sink.send("C")
  }
  
  
  func testMemoryBuffer() async {
    
    let sink = BulkSink<MemoryBuffer<String>>.init(
      buffer: .init(size: 10),
      targets: [
        MyTarget<String>()
      ]
    )
    
    await sink.send("A")
    await sink.send("A")
    await sink.send("A")
    
    try? await Task.sleep(for: .seconds(3))
    
    //    sink.send("A")
    //    sink.send("B")
    //    sink.send("C")
  }
  
}
