//
//  YMBAnalyticsPropertiesConst.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/19.
//

import Foundation

struct YMBAnalyticsPropertiesConst {
  private init() {}
}

/// Device Info Keys
extension YMBAnalyticsPropertiesConst {
  static let kPlatform = "platform"
  static let kDeviceId = "device_id"
  static let kOs = "$os"
  static let kOsVersion = "$os_version"
  static let kSensorsDeviceId = "sensors_device_id"
  static let kScreenHeight = "$screen_height"
  static let kScreenWidth = "$screen_width"
  static let kTimezoneOffset = "$timezone_offset"
  static let kBrand = "$brand"
  static let kModel = "$model"
  static let kWiFi = "$wifi"
  static let kCarrier = "$carrier"
  static let kNetworkType = "$network_type"
}

/// App Info Keys
extension YMBAnalyticsPropertiesConst {
  static let kAppVersion = "$app_version"
  static let kAppBuildNumber = "$app_build_number"
  static let kLibVersion = "$lib_version"
}

/// User Info Keys
extension YMBAnalyticsPropertiesConst {
  static let kActionTime = "action_time"
  static let kMessageId = "message_id"
  static let kIsFirstDay = "$is_first_day"
  static let kIsLoginId = "$is_login_id"
  static let kIsFirstTime = "$is_first_time"
  static let kUrl = "$url"
  static let kTitle = "$title"
  static let kReferrerUrl = "$referrer"
  static let kReferrerTitle = "$referrer_title"
  
  static let kIsLogin = "is_login"
  static let kVipLevel = "vip_level"
  static let kLanguage = "language"
  static let kZipcode = "zipcode"
  static let kToken = "token"
  static let kUserId = "user_id"
  static let kLatitude = "$latitude"
  static let kLongitude = "$longitude"
}

/// Properties Key
extension YMBAnalyticsPropertiesConst {
  static let kProperties = "properties"
  static let kEventName = "event_name"
}
