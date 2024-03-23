//
//  YMBAnalyticsConfiguration.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/16.
//

import Foundation

struct YMBAnalyticsConfigurationConst {
  private init() {}
  static let kFlushBatchSize = 50
  static let kFlushInterval = 0.5
  static let kFlushDefaultLimit = 1
}

class YMBAnalyticsConfiguration {
  
  let name: String
  let url: String
  let logEnable: Bool
  let flushInterval: TimeInterval
  let flushBatchSize: Int
  let flushLimit: Int
  weak var automaticPropertiesDelegate: YMBAnalyticsAutomaticPropertiesDelegate?
  
  
  init(name: String, 
       url: String,
       logEnable: Bool = false,
       flushInterval: TimeInterval = YMBAnalyticsConfigurationConst.kFlushInterval,
       flushBatchSize: Int = YMBAnalyticsConfigurationConst.kFlushBatchSize,
       flushLimit: Int = YMBAnalyticsConfigurationConst.kFlushDefaultLimit,
       automaticPropertiesDelegate: YMBAnalyticsAutomaticPropertiesDelegate? = nil) {
    self.name = name
    self.url = url
    self.logEnable = logEnable
    self.flushInterval = flushInterval
    self.flushLimit = flushLimit
    self.flushBatchSize = min(flushBatchSize, YMBAnalyticsConfigurationConst.kFlushBatchSize)
    self.automaticPropertiesDelegate = automaticPropertiesDelegate
  }
}
