//
//  YMBAnalyticsDeviceInfo.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/19.
//

import UIKit
import AppTrackingTransparency
import AdSupport
import SystemConfiguration
import CoreTelephony

struct YMBAnalyticsDeviceInfoConst {
  private init() {}
  static let kSystemMacos = "macOS"
  static let kUnknown = "Unknown"
  static let kBrand = "Apple"
  static let kNotReachable = "NOTREACHABLE"
  static let kNetworkWiFi = "WIFI"
  static let kNetwork2G = "2G"
  static let kNetwork3G = "3G"
  static let kNetwork4G = "4G"
  static let kNetwork5G = "5G"
  static let kEmptyUUID = "00000000-0000-0000-0000-000000000000"
}

class YMBAnalyticsDeviceInfo {
  
  private init() {}
  
  private static let telephonyInfo = CTTelephonyNetworkInfo()
  
  /// Platform eg: iOS / macOS
  class func platform() -> String {
    return os()
  }
    
  /// OS eg: iOS / macOS
  class func os() -> String {
    if isRunningOnMac() {
      return YMBAnalyticsDeviceInfoConst.kSystemMacos
    } else {
      return UIDevice.current.systemName
    }
  }
  
  /// IDFV
  class func identifierForVendor() -> String? {
    return UIDevice.current.identifierForVendor?.uuidString
  }
  
  /// IDFA
  class func advertisingIdentifier() -> String? {
    if enableAdvertising() == false {
      return nil
    }
    
    let uuid = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    if uuid == YMBAnalyticsDeviceInfoConst.kEmptyUUID {
      return nil
    }
    return uuid
  }
  
  /// System Version
  class func osVersion() -> String {
    if isRunningOnMac() {
      return ProcessInfo.processInfo.operatingSystemVersionString
    } else {
      return UIDevice.current.systemVersion
    }
  }
  
  /// Device Model
  class func deviceModel() -> String {
    var device : String = YMBAnalyticsDeviceInfoConst.kUnknown
    if isRunningOnMac() {
      var size = 0
      sysctlbyname("hw.model", nil, &size, nil, 0)
      var model = [CChar](repeating: 0,  count: size)
      sysctlbyname("hw.model", &model, &size, nil, 0)
      device = String(cString: model)
    } else {
      var systemInfo = utsname()
      uname(&systemInfo)
      let size = MemoryLayout<CChar>.size
      device = withUnsafePointer(to: &systemInfo.machine) {
        $0.withMemoryRebound(to: CChar.self, capacity: size) {
          String(cString: UnsafePointer<CChar>($0))
        }
      }
    }
    return device
  }
  
  /// Apple
  class func brand() -> String {
    return YMBAnalyticsDeviceInfoConst.kBrand
  }
  
  class func screenHeight() -> Int {
    let screenSize = UIScreen.main.bounds.size
    return Int(screenSize.height)
  }
  
  class func screenWidth() -> Int {
    let screenSize = UIScreen.main.bounds.size
    return Int(screenSize.width)
  }
  
  /// Carrier Name
  class func carrier() -> String? {
    return telephonyInfo.serviceSubscriberCellularProviders?.first?.value.carrierName
  }
  
  /// Network Type eg: 2G / 3G / 4G / 5G
  class func networkType() -> String? {
    guard let wifi = YMBAnalyticsReachability.shared.wifi, wifi == false else {
      return YMBAnalyticsDeviceInfoConst.kNetworkWiFi
    }
    
    guard let radios = telephonyInfo.serviceCurrentRadioAccessTechnology else {
      return YMBAnalyticsDeviceInfoConst.kNotReachable
    }
    
    var radioType: String?
    if let radioId = telephonyInfo.dataServiceIdentifier, let radio = radios[radioId] {
      radioType = radio
    } else {
      radioType = radios.first?.value
    }
    
    if (radioType == CTRadioAccessTechnologyEdge ||
        radioType == CTRadioAccessTechnologyGPRS ||
        radioType == CTRadioAccessTechnologyCDMA1x) {
      return YMBAnalyticsDeviceInfoConst.kNetwork2G
    } else if (radioType == CTRadioAccessTechnologyHSDPA ||
               radioType == CTRadioAccessTechnologyWCDMA ||
               radioType == CTRadioAccessTechnologyHSUPA ||
               radioType == CTRadioAccessTechnologyCDMAEVDORev0 ||
               radioType == CTRadioAccessTechnologyCDMAEVDORevA ||
               radioType == CTRadioAccessTechnologyCDMAEVDORevB ||
               radioType == CTRadioAccessTechnologyeHRPD) {
      return YMBAnalyticsDeviceInfoConst.kNetwork3G
    } else if (radioType == CTRadioAccessTechnologyLTE) {
      return YMBAnalyticsDeviceInfoConst.kNetwork4G
    } else if #available(iOS 14.1, *) {
      if (radioType == CTRadioAccessTechnologyNRNSA || radioType == CTRadioAccessTechnologyNR) {
        return YMBAnalyticsDeviceInfoConst.kNetwork5G
      }
    }
    return YMBAnalyticsDeviceInfoConst.kUnknown
  }
  
  /// Time Zone Offset like sensors create rule
  class func timezoneOffset() -> Int {
    return NSTimeZone.default.secondsFromGMT() / 60
  }
  
  /// IDFV -> UUID -> Cache to Disk
  class func deviceId() -> String {
    let cacheDeviceId = YMBAnalyticsUserDefaults.shared.read(key: YMBAnalyticsStorageConst.kDeviceId) as? String
    if let cacheDeviceId = cacheDeviceId {
      return cacheDeviceId
    }
    
    let deviceId = self.identifierForVendor() ?? UUID().uuidString
    YMBAnalyticsUserDefaults.shared.write(key: YMBAnalyticsStorageConst.kDeviceId, value: deviceId)
    return deviceId
  }
  
  ///  IDFA -> IDFV - > UUID -> Cache to Disk
  class func sensorsDeviceId() -> String {
    var deviceId: String
    let keyChainId =  YMBAnalyticsKeyChain.shared.string(key: YMBAnalyticsStorageConst.kSensorsDeviceId)
    if let keyChainId = keyChainId {
      deviceId = keyChainId
    }else if let adId = self.advertisingIdentifier() {
      deviceId = adId
    } else {
      deviceId = self.deviceId()
    }
    
    // Sync new DeviceId to Keychain
    if keyChainId == nil {
      YMBAnalyticsKeyChain.shared.write(key: YMBAnalyticsStorageConst.kSensorsDeviceId, string: deviceId)
    }
    
    return deviceId
  }
  
  /// IDFA is Enable
  class func enableAdvertising() -> Bool {
    if #available(iOS 14.0, *) {
      return ATTrackingManager.trackingAuthorizationStatus == .authorized
    } else {
      return ASIdentifierManager.shared().isAdvertisingTrackingEnabled
    }
  }
  
  /// iOS App Running On Mac OS
  class func isRunningOnMac() -> Bool {
      var runningOnMac = false
      if #available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *) {
        runningOnMac = ProcessInfo.processInfo.isiOSAppOnMac
      }
      return runningOnMac
  }
  
}
