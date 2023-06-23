import Foundation

public struct BulkBufferTimer {

  private let interval: DispatchTimeInterval

  private let onTimeout: @Sendable () async -> Void
  private var item: Task<(), Never>?

  public init(
    interval: DispatchTimeInterval,
    @_inheritActorContext onTimeout: @escaping @Sendable () async -> Void
  ) {

    self.interval = interval
    self.onTimeout = onTimeout

    refresh()
  }

  public mutating func tap() {
    refresh()
  }

  private mutating func refresh() {

    self.item?.cancel()

    let task = Task { [onTimeout, interval] in

      try? await Task.sleep(nanoseconds: interval.makeNanoseconds())

      guard Task.isCancelled == false else { return }

      await onTimeout()
    }

    self.item = task
  }

}

extension DispatchTimeInterval {

  fileprivate func makeNanoseconds() -> UInt64 {

    switch self {
    case .nanoseconds(let v): return UInt64(v)
    case .microseconds(let v): return UInt64(v) * 1_000
    case .milliseconds(let v): return UInt64(v) * 1_000_000
    case .seconds(let v): return UInt64(v) * 1_000_000_000
    case .never: return UInt64.max
    @unknown default:
      assertionFailure()
      return 0
    }

  }

}
