//
//  ContentView.swift
//  BulkDemo
//
//  Created by muukii on 2020/02/03.
//

import BulkLogger
import SwiftUI

let logger = Logger(
  context: "",
  sinks: [
    BulkSink(
      buffer: MemoryBuffer(size: 3).asAny(),
      debounceDueTime: .seconds(3),
      targets: [
        OSLogTarget(subsystem: "a", category: "a").asAny()
      ]
    )
    .asAny()
  ]
)

struct ContentView: View {
  var body: some View {
    VStack {
      Text("Hello, World!")
      Button(action: {
        logger.verbose("Verbose")
      }) {
        Text("Verbose")
      }
      Button(action: {
        logger.debug("Debug")
      }) {
        Text("Debug")
      }

      Button(action: {
        logger.warn("Warn")
      }) {
        Text("Error")
      }

      Button(action: {
        logger.error("Error")
      }) {
        Text("Fault")
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
