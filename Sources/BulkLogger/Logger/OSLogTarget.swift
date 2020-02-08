//
//  OSLogTarget.swift
//  BulkLogger
//
//  Created by muukii on 2020/02/04.
//

import Foundation

import os

open class OSLogTarget: TargetType {
  
  private static let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return dateFormatter
  }()
  
  public static func basicFormat(log: LogData) -> String {
    let timestamp = dateFormatter.string(from: log.date)
    
    let body: String
    if log.context.isEmpty {
      body = "[\(log.context.joined(separator: "::"))] item.body)"
    } else {
      body = log.body
    }
    return "\(body)\n\nLog_Info=>\(timestamp) \(log.file)::\(log.function)::\(log.line)"
  }
  
  private let oslog: OSLog
  public let formatter: (LogData) -> String
  
  public init(
    subsystem: String,
    category: String,
    formatter: @escaping (LogData) -> String = { basicFormat(log: $0) }
  ) {
    self.oslog = OSLog(subsystem: subsystem, category: category)
    self.formatter = formatter
  }
  
  open func write(formatted items: [LogData]) {
    items.forEach { item in
      
      os_log("%{public}@", log: oslog, type: item.level.asOSLogLevel(), formatter(item))
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
