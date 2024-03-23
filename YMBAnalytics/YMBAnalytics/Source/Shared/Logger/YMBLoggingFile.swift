//
//  YMBLoggingFile.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/16.
//

import Foundation

class YMBLoggingFile: YMBLogging {
  
  private let fileHandle: FileHandle
  private let name: String
  init(name: String = "YMBLogger", path: String) {
    self.name = name
    if let handle = FileHandle(forWritingAtPath: path) {
      fileHandle = handle
    } else {
      fileHandle = FileHandle.standardError
    }
    
    fileHandle.seekToEndOfFile()
  }
  
  deinit {
    fileHandle.closeFile()
  }

  func log(_ message: YMBLoggerMessage) {
    let content = "[Analytics] [\(message.level.rawValue)] [\(message.date)] [\(message.file)] [\(message.function)] \(message.text)"
    if let data = content.data(using: String.Encoding.utf8) {
      fileHandle.write(data)
    }
  }
}
