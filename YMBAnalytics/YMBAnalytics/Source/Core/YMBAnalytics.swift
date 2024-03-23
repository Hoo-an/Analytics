//
//  YMBAnalytics.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/16.
//

import Foundation

class YMBAnalytics {
  
  private init() {}
  
  @discardableResult
  class func initialize(configuration: YMBAnalyticsConfiguration) -> YMBAnalyst {
    return YMBAnalystManager.shared.initialize(configuration: configuration)
  }
  
  class func analyst(name: String) -> YMBAnalyst? {
    return YMBAnalystManager.shared.get(name: name)
  }
  
  class func defaultAnalyst() -> YMBAnalyst? {
    return YMBAnalystManager.shared.main()
  }

  class func defaultAnalyst(name: String) {
    YMBAnalystManager.shared.main(name: name)
  }
  
  class func removeAnalyst(name: String) {
    YMBAnalystManager.shared.remove(name: name)
  }
  
}
