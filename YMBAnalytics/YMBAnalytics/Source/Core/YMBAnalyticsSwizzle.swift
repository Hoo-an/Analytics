//
//  YMBAnalyticsSwizzle.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/22.
//

import UIKit

/// 避免与其他SDK或业务中的方法重名，此处使用特殊命名方式
extension UIViewController {
  @objc func _$analyticsSwizzledViewWillAppear(_ animated: Bool) {
    YMBLogger.debug(message: "Analytics swizzle view will appear success")
    self._$analyticsSwizzledViewWillAppear(animated)
    _$analyticsUpdateScreenTrack()
    _$analyticsReportScreenEvent()
  }
  
  @objc func _$analyticsSwizzledViewWillDisappear(_ animated: Bool) {
    YMBLogger.debug(message: "Analytics swizzle view will disappear success")
    self._$analyticsSwizzledViewWillDisappear(animated)
  }
  
  private func _$analyticsUpdateScreenTrack() {
    guard self is YMBAnalyticsScreenDelegate, let delegate = self as? YMBAnalyticsScreenDelegate else { return }
    let screenTitle = delegate.screen()
    let screenUrl = String(describing: type(of: self))
    YMBAnalyticsPathManager.shared.title = screenTitle
    YMBAnalyticsPathManager.shared.url = screenUrl
  }
  
  private func _$analyticsReportScreenEvent() {
    guard self is YMBAnalyticsScreenDelegate, let delegate = self as? YMBAnalyticsScreenDelegate else { return }
    guard let eventName = delegate.screenEventName() else { return }
    let properties = delegate.properties()
    YMBAnalytics.defaultAnalyst()?.track(event: eventName, properties: properties)
  }
}

class YMBAnalyticsSwizzle {
  
  private static var swizzleOnceCalled = false
  
  static func swizzle() {
    _ = {
      guard !swizzleOnceCalled else {
        return
      }
      swizzleOnceCalled = true
      exchange()
    }
  }
  
  private static func exchange() {
    exchangeViewController(original: #selector(UIViewController.viewWillAppear(_:)),
                           swizzle: #selector(UIViewController._$analyticsSwizzledViewWillAppear(_:)))
    
    exchangeViewController(original: #selector(UIViewController.viewWillDisappear(_:)),
                           swizzle: #selector(UIViewController._$analyticsSwizzledViewWillDisappear(_:)))
  }
  
  private static func exchangeViewController(original: Selector, swizzle: Selector) {
    let originalMethod = class_getInstanceMethod(UIViewController.self, original)
    let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzle)
    
    let didAppendMethod = class_addMethod(UIViewController.self, original, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
    
    if didAppendMethod {
      class_replaceMethod(UIViewController.self, swizzle, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
    } else {
      method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
  }
}
