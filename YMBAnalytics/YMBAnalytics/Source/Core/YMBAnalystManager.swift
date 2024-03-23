//
//  YMBAnalystManager.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/16.
//

import Foundation

struct YMBAnalystManagerConst {
  static let kLoggerName = "Analytics"
  static let kLockLabel = "analytics.core.manager.analyst.lock"
  static let kAnalyticsQueueLabel = "analytics.core.manager.analyst.queue"
}

final class YMBAnalystManager {
  
  static let shared = YMBAnalystManager()
  
  private var analysts: [String: YMBAnalyst]
  private var `default`: YMBAnalyst?
  private let lock: YMBAnalyticsReadWriteLock
  private let queue: DispatchQueue
  
  private init() {
    YMBLogger.add(YMBLoggingConsole(name: YMBAnalystManagerConst.kLoggerName))
    analysts = [String: YMBAnalyst]()
    lock = YMBAnalyticsReadWriteLock(label: YMBAnalystManagerConst.kLockLabel)
    queue = DispatchSerialQueue(label: YMBAnalystManagerConst.kAnalyticsQueueLabel, qos: .utility, autoreleaseFrequency: .workItem)
  }
  
  func initialize(configuration: YMBAnalyticsConfiguration) -> YMBAnalyst {
    queue.sync {
      if let analuyst = analysts[configuration.name] {
        `default` = analuyst
        return
      }
      let analuyst = YMBAnalyst(configuration: configuration)
      lock.write {
        analysts[configuration.name] = analuyst
        `default` = analuyst
      }
    }
    return `default`!
  }
  
  
  func get(name: String) -> YMBAnalyst? {
    var analyst: YMBAnalyst?
    lock.read {
      analyst = analysts[name]
    }
    if let analyst = analyst {
      return analyst
    } else {
      YMBLogger.warn(message: "not found analyst by \(name)")
      return nil
    }
  }
  
  func main() -> YMBAnalyst? {
    return `default`
  }
  
  func main(name: String) {
    var analyst: YMBAnalyst?
    lock.read {
      analyst = analysts[name]
    }
    if let analyst = analyst {
      `default` = analyst
    } else {
      YMBLogger.warn(message: "set default analyst failed, not found \(name) in analysts")
    }
  }
  
  func all() -> [YMBAnalyst]? {
    var analysts: [YMBAnalyst]?
    lock.read {
      analysts = Array(self.analysts.values)
    }
    return analysts
  }
  
  func remove(name: String) {
    lock.write {
      if analysts[name] === `default` {
        `default` = nil
      }
      analysts[name] = nil
    }
  }
  
}
