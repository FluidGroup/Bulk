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
