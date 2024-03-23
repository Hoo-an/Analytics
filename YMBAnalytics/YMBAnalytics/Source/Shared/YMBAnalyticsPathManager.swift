//
//  YMBAnalyticsPathManager.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/21.
//

import Foundation

class YMBAnalyticsPathManager {
  
  static let shared = YMBAnalyticsPathManager()
  
  private var _title: String?
  private var _url: String?
  private var _referrerTitle: String?
  private var _referrerUrl: String?
  
  var title: String? {
    get {
      return _title
    } set {
      _referrerTitle = _title
      _title = newValue
    }
  }
  
  var url: String? {
    get {
      return _url
    } set {
      _referrerUrl = _url
      _url = newValue
    }
  }
  
  var referrerTitle: String? {
    get {
      return _referrerTitle
    } set {
      _referrerTitle = newValue
    }
  }
  var referrerUrl: String? {
    get {
      return _referrerUrl
    } set {
      _referrerUrl = newValue
    }
  }
  
}
