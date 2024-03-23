//
//  YMBLoggingConsole.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/16.
//

import Foundation

class YMBLoggingConsole: YMBLogging {
  
  private let name: String
  init(name: String = "YMBLogger") {
    self.name = name
  }
  
  func log(_ message: YMBLoggerMessage) {
    print("[\(name)] [\(message.level.rawValue)] [\(message.date)] [\(message.file)] [\(message.function)] \(message.text)")
  }
}
