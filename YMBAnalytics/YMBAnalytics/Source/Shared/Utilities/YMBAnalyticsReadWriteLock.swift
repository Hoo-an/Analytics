//
//  YMBAnalyticsReadWriteLock.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/16.
//

import Foundation

class YMBAnalyticsReadWriteLock {
  private let concurrentQueue: DispatchQueue

  init(label: String) {
      concurrentQueue = DispatchQueue(label: label, qos: .utility, attributes: .concurrent, autoreleaseFrequency: .workItem)
  }

  func read(closure: () -> Void) {
      concurrentQueue.sync {
          closure()
      }
  }
  func write(closure: () -> Void) {
      concurrentQueue.sync(flags: .barrier, execute: {
          closure()
      })
  }
}
