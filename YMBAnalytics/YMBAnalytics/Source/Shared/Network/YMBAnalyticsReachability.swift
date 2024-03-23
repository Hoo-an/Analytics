//
//  YMBAnalyticsReachability.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/19.
//

import SystemConfiguration

struct YMBAnalyticsReachabilityConst {
  private init() {}
  static let kTracking = "analytics.shared.reachability.wifi.tracking"
  static let kHost = "apple.com"
}

class YMBAnalyticsReachability {
  
  static let shared = YMBAnalyticsReachability()
  
  var wifi: Bool?
  private let reachability: SCNetworkReachability?
  private let queue: DispatchQueue
  
  private init() {
    reachability = SCNetworkReachabilityCreateWithName(nil, YMBAnalyticsReachabilityConst.kHost)
    queue = DispatchQueue(label: YMBAnalyticsReachabilityConst.kTracking, qos: .utility, autoreleaseFrequency: .workItem)
  }
  
  func startListener() {
    guard let reachability = reachability else {
      YMBLogger.error(message: "Analytics start wifi monitor error, reachability is nil")
      return
    }
    var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
    func reachabilityCallback(reachability: SCNetworkReachability,
                              flags: SCNetworkReachabilityFlags,
                              unsafePointer: UnsafeMutableRawPointer?) {
      let wifi = flags.contains(SCNetworkReachabilityFlags.reachable) && !flags.contains(SCNetworkReachabilityFlags.isWWAN)
      YMBAnalyticsReachability.shared.wifi = wifi
      YMBLogger.info(message: "Analytics reachability changed, wifi=\(wifi)")
    }
    if SCNetworkReachabilitySetCallback(reachability, reachabilityCallback, &context) {
      if !SCNetworkReachabilitySetDispatchQueue(reachability, queue) {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
      }
    }
  }
  
  deinit {
    if let reachability = reachability {
      if !SCNetworkReachabilitySetCallback(reachability, nil, nil) {
        YMBLogger.error(message: "\(self) error unsetting reachability callback")
      }
      if !SCNetworkReachabilitySetDispatchQueue(reachability, nil) {
        YMBLogger.error(message: "\(self) error unsetting reachability dispatch queue")
      }
    }
  }
  
}
