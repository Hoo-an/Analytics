//
//  YMBAnalyticsDate.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/21.
//

import Foundation

struct YMBAnalyticsDateConst {
  private init() {}
  
  static let kLocalEnUsPosix = "en_US_POSIX"
  static let kFormatterYYYYMMdd = "yyyy-MM-dd"
}

class YMBAnalyticsDate {
  
  private init() {}
  
  class func isToday(date: String, format: String) -> Bool {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.locale = Locale(identifier: YMBAnalyticsDateConst.kLocalEnUsPosix)
    
    if let date = formatter.date(from: date) {
      return Calendar.current.isDateInToday(date)
    }
    
    return false
  }
  
  class func toString(date: Date, format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.locale = Locale(identifier: YMBAnalyticsDateConst.kLocalEnUsPosix)
    return formatter.string(from: date)
  }
  
}
