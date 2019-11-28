//
// AsyncPipeline.swift
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

public final class AsyncPipeline<Input>: Pipeline<Input> {
  
  public let queue: DispatchQueue
  private let inputQueue: DispatchQueue
  
  public init<Output>(
    plugins: [PluginWrapper<Input>],
    inputBuffer: BufferWrapper<Input>,
    inputTimebox: DispatchTimeInterval,
    outputBuffer: BufferWrapper<Input>,
    formatter: FormatterWrapper<Input, Output>,
    target: TargetWrapper<Output>,
    queue: DispatchQueue
    ) {
    
    self.queue = queue

    self.inputQueue = DispatchQueue.init(
      label: "me.muukii.Bulk.AsyncPipeline.input",
      qos: .default,
      attributes: [],
      autoreleaseFrequency: .inherit,
      target: queue
    )

    super.init(
      plugins: plugins,
      inputBuffer: inputBuffer,
      inputTimebox: inputTimebox,
      outputBuffer: outputBuffer,
      formatter: formatter,
      target: target
    )

  }
  
  override func write(element: Input) {
    inputQueue.async(flags: .barrier) {
      super.write(element: element)
    }
  }
  
  override func loadBuffer() {
    
    inputQueue.async(flags: .barrier) {
      super.loadBuffer()
    }
  }
  
  public func waitUntilAllWritingAreProcessed() {
    inputQueue.sync(flags: .barrier, execute: {})
  }
}
