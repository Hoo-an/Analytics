//
//  YMBAnalyticsScreen.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/22.
//

import Foundation

protocol YMBAnalyticsScreenDelegate {
  func properties() -> YMBAnalyticsProperties?
  func screen() -> String?
  func screenEventName() -> String?
  func isIgnoreAnalytics() -> Bool
}

extension YMBAnalyticsScreenDelegate {
  
  func properties() -> YMBAnalyticsProperties? {
    return nil
  }
  
  func screen() -> String? {
    return nil
  }
  
  func screenEventName() -> String? {
    return nil
  }
  
  func isIgnoreAnalytics() -> Bool {
    return false
  }
  
}
