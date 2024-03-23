//
//  YMBAnalyticsUserInfo.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/21.
//

import Foundation

class YMBAnalyticsUserInfo {
  private init() {}
  
  class func isFirstDay() -> Bool {
    let date = firstUseDate()
    return YMBAnalyticsDate.isToday(date: date, format: YMBAnalyticsDateConst.kFormatterYYYYMMdd)
  }
  
  class func isFirstUseApp() -> Bool {
    let isFirst = YMBAnalyticsUserDefaults.shared.read(key: YMBAnalyticsStorageConst.kSensorsFirstUseApp) as? Bool ?? true
    if isFirst {
      YMBAnalyticsUserDefaults.shared.write(key: YMBAnalyticsStorageConst.kSensorsFirstUseApp, value: false)
    }
    
    return isFirst
  }
  
  private class func firstUseDate() -> String {
    var date: String
    let cacheDate = YMBAnalyticsUserDefaults.shared.read(key: YMBAnalyticsStorageConst.kSensorsFirstUseDate) as? String
    if let cacheDate = cacheDate {
      date = cacheDate
    } else {
      date = YMBAnalyticsDate.toString(date: Date(), format: YMBAnalyticsDateConst.kFormatterYYYYMMdd)
      YMBAnalyticsUserDefaults.shared.write(key: YMBAnalyticsStorageConst.kSensorsFirstUseDate, value: date)
    }
    return date
  }
}
