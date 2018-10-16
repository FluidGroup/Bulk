//
//  OSLogTarget.swift
//  Bulk-Carthage
//
//  Created by muukii on 10/16/18.
//

#if canImport(os)

import Foundation
import os.log

@available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public struct OSLogFormatter : Formatter {

  public struct OSLogData {
    public let body: String
    public let level: OSLogType
  }

  public init() {

  }

  public func format(log: Log) -> OSLogData {

    let file = URL(string: log.file.description)?.deletingPathExtension()
    let body = "\(file?.lastPathComponent ?? "").\(log.function):\(log.line) \(log.body)"

    return OSLogData(body: body, level: log.level.asOSLogType())
  }
}

@available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public struct OSLogTarget : Target {

  public init() {

  }

  public func write(formatted items: [OSLogFormatter.OSLogData], completion: @escaping () -> Void) {

    for log in items {

      os_log("%@", type: log.level, log.body)
    }
  }
}

@available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
extension Log.Level {

  func asOSLogType() -> OSLogType {

    switch self {
    case .verbose:
      return .default
    case .debug:
      return .debug
    case .info:
      return .info
    case .warn:
      return .error
    case .error:
      return .fault
    }
  }
}

#endif

