//
// Copyright (c) 2020 Hiroshi Kimura(Muukii) <muuki.app@gmail.com>
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

public final class FileBuffer<Element, Serializer: SerializerType>: Buffer where Serializer.Element == Element {

  public var hasSpace: Bool {
    return lineCount() < size
  }
  
  nonisolated(unsafe) private let fileManager = FileManager.default
  public let fileURL: URL
  
  nonisolated(unsafe)
  private var fileHandle: FileHandle?
  public let size: Int
  
  private let serializer: Serializer
  
  public init(
    size: Int,
    filePath: String,
    serializer: Serializer
  ) {
    // TODO: ~/ => /Users/FooBar
            
    self.size = size
    self.fileURL = URL(fileURLWithPath: (filePath as NSString).standardizingPath).standardized
    self.serializer = serializer
  }
  
  deinit {
    fileHandle?.closeFile()
  }
  
  public func write(element: Element) -> BufferResult<Element> {
    
    do {
      
      let data = try serializer.serialize(element: element)
                  
      let line = data.base64EncodedString() + "\n"
      
      if fileManager.fileExists(atPath: fileURL.path) == false {
        // create file if not existing

        try createSubfoldersBeforeCreatingFile(at: fileURL)
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
  
  public func purge() -> [Element] {
    
    var cursor = 0
    var serializedLines = ContiguousArray<String>(repeating: "", count: lineCount())
    
    do {
      
      try String(contentsOf: fileURL).enumerateLines { l, _ in
        serializedLines[cursor] = l
        cursor += 1
      }
                  
      let logs = serializedLines
        .compactMap { Data.init(base64Encoded: $0) }
        .map { try? serializer.deserialize(source: $0) }
        .compactMap { $0 }

      fileHandle?.closeFile()
      fileHandle = nil
      try fileManager.removeItem(at: fileURL)
      
      return .init(logs)
      
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

private func createSubfoldersBeforeCreatingFile(at url: URL) throws {
  do {
    let subfolderUrl = url.deletingLastPathComponent()
    var subfolderExists = false
    var isDirectory: ObjCBool = false
    if FileManager.default.fileExists(atPath: subfolderUrl.path, isDirectory: &isDirectory) {
      if isDirectory.boolValue {
        subfolderExists = true
      }
    }
    if !subfolderExists {
      try FileManager.default.createDirectory(at: subfolderUrl, withIntermediateDirectories: true, attributes: nil)
    }
  } catch {
    throw error
  }
}

