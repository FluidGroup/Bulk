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

public final class BulkBufferTimer {

  private var interval: Duration

  private var onTimeout: (isolated (any Actor)?) async -> Void
  private var item: Task<(), Never>?

  public init(
    interval: Duration,
    onTimeout: sending @escaping () async -> Void
  ) {

    self.interval = interval
    self.onTimeout = { a in 
      await onTimeout()
    }
  
  }

  public func tap(isolation: isolated (any Actor)? = #isolation) {
    refresh(isolation: isolation)
  }

  private func refresh(isolation: isolated (any Actor)? = #isolation) {

    self.item?.cancel()

    let task = Task { [onTimeout, interval] in

      try? await Task.sleep(for: interval)

      guard Task.isCancelled == false else { return }

      await onTimeout(isolation)
    }

    self.item = task
  }

}
