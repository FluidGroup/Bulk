//
//  ContentView.swift
//  BulkDemo
//
//  Created by muukii on 2020/02/03.
//

import SwiftUI

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
