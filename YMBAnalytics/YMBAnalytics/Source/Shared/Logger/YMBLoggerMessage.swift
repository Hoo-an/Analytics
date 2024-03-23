//
//  YMBLoggerMessage.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/16.
//

import Foundation

struct YMBLoggerMessage {
  let file: String
  let function: String
  let text: String
  let level: YMBLoggerLevel
  let date = Date()
  
  init(path: String, function: String, text: String, level: YMBLoggerLevel) {
    if let file = path.components(separatedBy: "/").last {
      self.file = file
    } else {
      self.file = path
    }
    self.function = function
    self.text = text
    self.level = level
  }
}
