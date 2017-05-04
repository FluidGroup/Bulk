// FileTarget.swift
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

open class FileTarget: Target {
  
  private let fileManager = FileManager.default
  public let fileURL: URL
  private var fileHandle: FileHandle?
  
  public init(filePath: String) {
    
    // TODO: ~/ => /Users/FooBar
    
    self.fileURL = URL(fileURLWithPath: filePath).standardized
  }
  
  deinit {
    fileHandle?.closeFile()
  }
  
  open func write(formatted strings: [String]) {
    
    strings.forEach { string in
      
      do {
        if fileManager.fileExists(atPath: fileURL.path) == false {
          // create file if not existing
          let line = string + "\n"
          try line.write(to: fileURL, atomically: true, encoding: .utf8)
          
        } else {
          // append to end of file
          if fileHandle == nil {
            // initial setting of file handle
            fileHandle = try FileHandle(forWritingTo: fileURL)
          }
          if let fileHandle = fileHandle {
            let _ = fileHandle.seekToEndOfFile()
            let line = string + "\n"
            if let data = line.data(using: .utf8) {
              fileHandle.write(data)
            }
          }
        }
      } catch {
        
        print("[Bulk] Failed to write log : \(error)")
      }
    }
    
  }
}

