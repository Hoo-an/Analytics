//
//  YMBAnalyticsAutomaticProperties.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/19.
//

import Foundation

protocol YMBAnalyticsAutomaticPropertiesDelegate: AnyObject {
  
  /// Read extra properties, eg: user info
  /// - Returns: Key in``YMBAnalyticsPropertiesConst``, Value in ``YMBAnalyticsType`` On ``YMBAnalyticsProperties``
  func properties() -> YMBAnalyticsProperties?
}

class YMBAnalyticsAutomaticProperties {
  
  static let shared = YMBAnalyticsAutomaticProperties()
  
  weak var delegate: YMBAnalyticsAutomaticPropertiesDelegate?
  private let lock = YMBAnalyticsReadWriteLock(label: "analytics.shared.properties.lock")
  private var data = YMBAnalyticsProperties()
  
  private init() {
    var map = YMBAnalyticsProperties()
    // Device Info
    map[YMBAnalyticsPropertiesConst.kPlatform] = YMBAnalyticsDeviceInfo.platform()
    map[YMBAnalyticsPropertiesConst.kOs] = YMBAnalyticsDeviceInfo.os()
    map[YMBAnalyticsPropertiesConst.kOsVersion] = YMBAnalyticsDeviceInfo.osVersion()
    map[YMBAnalyticsPropertiesConst.kScreenHeight] = YMBAnalyticsDeviceInfo.screenHeight()
    map[YMBAnalyticsPropertiesConst.kScreenWidth] = YMBAnalyticsDeviceInfo.screenWidth()
    map[YMBAnalyticsPropertiesConst.kBrand] = YMBAnalyticsDeviceInfo.brand()
    map[YMBAnalyticsPropertiesConst.kModel] = YMBAnalyticsDeviceInfo.deviceModel()
    map[YMBAnalyticsPropertiesConst.kDeviceId] = YMBAnalyticsDeviceInfo.deviceId()
    map[YMBAnalyticsPropertiesConst.kSensorsDeviceId] = YMBAnalyticsDeviceInfo.sensorsDeviceId()
    // Application Info
    map[YMBAnalyticsPropertiesConst.kAppVersion] = YMBAnalyticsApplicationInfo.appVersion()
    map[YMBAnalyticsPropertiesConst.kAppBuildNumber] = YMBAnalyticsApplicationInfo.appBuildNumber()
    map[YMBAnalyticsPropertiesConst.kLibVersion] = YMBAnalyticsApplicationInfo.libVersion()
    
    // Write Properties
    lock.write { [weak self] in
      guard let self = self else { return }
      self.data = map
    }
  }
  
  
  /// Set Shared Property
  /// - Parameters:
  ///   - key: String in ``YMBAnalyticsPropertiesConst``
  ///   - value: Value in ``YMBAnalyticsType``
  func set(key: String, value: YMBAnalyticsType) {
    set(properties: [key: value])
  }
  
  
  /// Set Shared Properties
  /// - Parameter properties: Key in``YMBAnalyticsPropertiesConst``, Value in ``YMBAnalyticsType`` On ``YMBAnalyticsProperties``
  func set(properties: YMBAnalyticsProperties) {
    assertProperties(properties)
    lock.write { [weak self] in
      guard let self = self else { return }
      properties.forEach { key, value in
        self.data[key] = value
      }
    }
  }
  
  /// Read Automatic Properties
  func properties() -> YMBAnalyticsProperties {
    var map = YMBAnalyticsProperties()
    /// Create Variable Data
    map[YMBAnalyticsPropertiesConst.kCarrier] = YMBAnalyticsDeviceInfo.carrier()
    map[YMBAnalyticsPropertiesConst.kNetworkType] = YMBAnalyticsDeviceInfo.networkType()
    map[YMBAnalyticsPropertiesConst.kTimezoneOffset] = YMBAnalyticsDeviceInfo.timezoneOffset()
    map[YMBAnalyticsPropertiesConst.kWiFi] = YMBAnalyticsReachability.shared.wifi ?? false
    map[YMBAnalyticsPropertiesConst.kIsFirstDay] = YMBAnalyticsUserInfo.isFirstDay()
    map[YMBAnalyticsPropertiesConst.kIsFirstTime] = YMBAnalyticsUserInfo.isFirstUseApp()
    map[YMBAnalyticsPropertiesConst.kMessageId] = UUID().uuidString
    
    /// Create Extra Data
    if let delegate = delegate,let extra = delegate.properties() {
      extra.forEach { key, value in
        map[key] = value
      }
    }
    
    /// Title & Url
    map[YMBAnalyticsPropertiesConst.kTitle] = YMBAnalyticsPathManager.shared.title
    map[YMBAnalyticsPropertiesConst.kUrl] = YMBAnalyticsPathManager.shared.url
    map[YMBAnalyticsPropertiesConst.kReferrerTitle] = YMBAnalyticsPathManager.shared.referrerTitle
    map[YMBAnalyticsPropertiesConst.kReferrerUrl] = YMBAnalyticsPathManager.shared.referrerUrl
    
    /// Create Shared Data
    lock.read { [weak self] in
      guard let self = self else { return }
      self.data.forEach { key, value in
        map[key] = value
      }
    }
    assertProperties(map)
    return map
  }
  
}
