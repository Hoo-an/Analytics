//
//  YMBLogger.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/16.
//

import Foundation

class YMBLogger {
  private static var loggers = [YMBLogging]()
  private static var levels = Set<YMBLoggerLevel>()
  private static var lock = YMBAnalyticsReadWriteLock(label: "shared.logger.lock")
  
  class func add(_ logging: YMBLogging) {
    lock.write {
      loggers.append(logging)
    }
  }
  
  class func enable(_ level: YMBLoggerLevel) {
    lock.write {
      levels.insert(level)
    }
  }
  
  class func disable(_ level: YMBLoggerLevel) {
    lock.write {
      levels.remove(level)
    }
  }
  
  class func debug(message: @autoclosure() -> Any, _ path: String = #file, _ function: String = #function) {
    log(message: "\(message())", path: path, function: function, level: .debug)
  }
  
  class func info(message: @autoclosure() -> Any, _ path: String = #file, _ function: String = #function) {
    log(message: "\(message())", path: path, function: function, level: .info)
  }
  
  class func warn(message: @autoclosure() -> Any, _ path: String = #file, _ function: String = #function) {
    log(message: "\(message())", path: path, function: function, level: .warn)
  }
  
  class func error(message: @autoclosure() -> Any, _ path: String = #file, _ function: String = #function) {
    log(message: "\(message())", path: path, function: function, level: .error)
  }
  
  
  private class func log(message: String, path: String, function: String, level: YMBLoggerLevel) {
    var levels = Set<YMBLoggerLevel>()
    lock.read {
      levels = self.levels
    }
    guard levels.contains(level) else { return }
    log(message: YMBLoggerMessage(path: path, function: function, text: message, level: level))
  }
  
  private class func log(message: YMBLoggerMessage) {
    var loggers = [YMBLogging]()
    lock.read {
      loggers = self.loggers
    }
    lock.write {
      loggers.forEach {  $0.log(message) }
    }
  }
}
