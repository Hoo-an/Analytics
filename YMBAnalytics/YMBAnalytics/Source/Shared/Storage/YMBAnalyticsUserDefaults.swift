//
//  YMBAnalyticsUserDefaults.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/21.
//

import Foundation

class YMBAnalyticsUserDefaults {
  
  static let shared = YMBAnalyticsUserDefaults()
  private let defaults: UserDefaults?
  
  private init() {
    defaults = UserDefaults(suiteName: YMBAnalyticsStorageConst.kUserDefaultSuiteName)
  }
  
  func write(key: String, value: Any?) {
    let sha1 = YMBAnalyticsSha1.sha1(key)
    if let value = value {
      defaults?.set(value, forKey: sha1)
    } else {
      defaults?.removeObject(forKey: sha1)
    }
    
    defaults?.synchronize()
  }
  
  func read(key: String) -> Any? {
    let sha1 = YMBAnalyticsSha1.sha1(key)
    let value = defaults?.object(forKey: sha1)
    guard let value = value else { return nil }
    return value
  }
  
  func remove(key: String) {
    let sha1 = YMBAnalyticsSha1.sha1(key)
    defaults?.removeObject(forKey: sha1)
    defaults?.synchronize()
  }
}
