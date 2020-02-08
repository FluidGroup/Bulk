//
//  OSLogTarget.swift
//  BulkLogger
//
//  Created by muukii on 2020/02/04.
//

import Foundation

import os

open class OSLogTarget: TargetType {
  
  private let oslog: OSLog
  
  public let dateFormatter: DateFormatter
  
  public init(subsystem: String, category: String) {
    self.oslog = OSLog(subsystem: subsystem, category: category)
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    self.dateFormatter = formatter
  }
  
  open func write(formatted items: [LogData]) {
    items.forEach { item in
      
      let timestamp = dateFormatter.string(from: item.date)
      
      let body: String
      if item.context.isEmpty {
        body = "[\(item.context.joined(separator: "::"))] item.body)"
      } else {
        body = item.body
      }
      
      os_log("%{public}@ %{public}@ %{public}@ %{public}d %{public}@", log: oslog, type: item.level.asOSLogLevel(), timestamp, item.file, item.function, item.line, body)
    }
  }
}

extension LogData.Level {
  fileprivate func asOSLogLevel() -> OSLogType {
    switch self {
    case .verbose: return .default
    case .debug: return .default
    case .info: return .default
    case .warn: return .error
    case .error: return .fault
    }
  }
}
