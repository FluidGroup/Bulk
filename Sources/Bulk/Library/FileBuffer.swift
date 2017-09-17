//
// FileBuffer.swift
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

public final class FileBuffer: Buffer {
  
  public var hasSpace: Bool {
    return lineCount() < size
  }
  
  private let fileManager = FileManager.default
  public let fileURL: URL
  private var fileHandle: FileHandle?
  public let size: Int
  
  private let serializer = SeparatorBasedLogSerializer()
  
  public init(size: Int, filePath: String) {
    // TODO: ~/ => /Users/FooBar
    
    self.size = size
    self.fileURL = URL(fileURLWithPath: filePath).standardized
  }
  
  deinit {
    fileHandle?.closeFile()
  }
  
  public func write(log: Log) -> BufferResult {
    
    do {
      
      let s = try serializer.serialize(log: log)
      
      let line = s + "\n"
      
      if fileManager.fileExists(atPath: fileURL.path) == false {
        // create file if not existing
        try line.write(to: fileURL, atomically: true, encoding: .utf8)
        
      } else {
        // append to end of file
        if fileHandle == nil {
          // initial setting of file handle
          fileHandle = try FileHandle(forWritingTo: fileURL)
        }
        if let fileHandle = fileHandle {
          let _ = fileHandle.seekToEndOfFile()
          if let data = line.data(using: .utf8) {
            fileHandle.write(data)
          }
        }
      }
    } catch {
      
      print("[Bulk] Failed to write buffer : \(error)")
    }
    
    if lineCount() == size {
      return .flowed(purge())
    } else {
      return .stored
    }
  }
  
  public func purge() -> [Log] {
    
    var cursor = 0
    var serializedLines = [String].init(repeating: "", count: lineCount())
    
    do {
      
      try String(contentsOf: fileURL).enumerateLines { l, _ in
        serializedLines[cursor] = l
        cursor += 1
      }
      
      let logs = serializedLines.map { try? serializer.deserialize(source: $0) }.flatMap { $0 }

      fileHandle?.closeFile()
      fileHandle = nil
      try fileManager.removeItem(at: fileURL)
      
      return logs
      
    } catch {
             
      if error._code == NSFileReadNoSuchFileError {
        return []
      }
      
      assertionFailure()
      return []
    }
  }
  
  private func lineCount() -> Int {
    do {
      var lineCount = 0
      
      try String(contentsOf: fileURL).enumerateLines { _, _ in
        lineCount += 1
      }
      
      return lineCount
    } catch {
      
      return 0
    }
  }
  
}
