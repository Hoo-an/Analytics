//
//  YMBAnalyticsApplicationInfo.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/19.
//

import Foundation

struct YMBAnalyticsApplicationInfoConst {
  private init() {}
  static let kLibVersion = "1.0.0"
  static let kUnknown = "Unknown"
}

class YMBAnalyticsApplicationInfo {
  
  private init() {}
  
  class func appVersion() -> String {
    let infoDict = Bundle.main.infoDictionary ?? [:]
    return infoDict["CFBundleShortVersionString"] as? String ?? YMBAnalyticsApplicationInfoConst.kUnknown
  }
  
  class func appBuildNumber() -> String {
    let infoDict = Bundle.main.infoDictionary ?? [:]
    return infoDict["CFBundleVersion"] as? String ?? YMBAnalyticsApplicationInfoConst.kUnknown
  }
  
  class func libVersion() -> String {
    return YMBAnalyticsApplicationInfoConst.kLibVersion
  }
}
