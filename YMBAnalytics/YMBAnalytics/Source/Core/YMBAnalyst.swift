//
//  YMBAnalyst.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/16.
//

import UIKit

struct YMBAnalystConst {
  static let kTracking = "analytics.core.tracking"
  static let kNetworking = "analytics.core.networking"
}

class YMBAnalyst {
  
  private let flush: YMBAnalyticsFlush
  private let configuration: YMBAnalyticsConfiguration
  private let storage: YMBAnalyticsEventStorage
  private var trackingQueue: DispatchQueue
  private var networkingQueue: DispatchQueue
  private var taskId = UIBackgroundTaskIdentifier.invalid
  
  init(configuration: YMBAnalyticsConfiguration) {
    self.configuration = configuration
    let trackingLabel = "\(YMBAnalystConst.kTracking).\(configuration.name)"
    let networkingLabel = "\(YMBAnalystConst.kNetworking).\(configuration.name)"
    trackingQueue = DispatchQueue(label: trackingLabel, qos: .utility, autoreleaseFrequency: .workItem)
    networkingQueue = DispatchQueue(label: networkingLabel, qos: .utility, autoreleaseFrequency: .workItem)
    storage = YMBAnalyticsEventStorage(name: configuration.name)
    flush = YMBAnalyticsFlush(name: configuration.name,
                              url: configuration.url,
                              flushInterval: configuration.flushInterval,
                              flushBatchSize: configuration.flushBatchSize,
                              flushLimit: configuration.flushLimit)
    flush.delegate = self
    
    setupLogger()
    setupReachability()
    setupProperties()
    setupListeners()
    resetFlushing()
  }
  
  private func setupLogger() {
    if configuration.logEnable {
      YMBLogger.enable(.debug)
      YMBLogger.enable(.info)
      YMBLogger.enable(.warn)
      YMBLogger.enable(.error)
      YMBLogger.info(message: "Analytics logging enable")
    } else {
      YMBLogger.info(message: "Analytics logging disable")
      YMBLogger.disable(.debug)
      YMBLogger.disable(.info)
      YMBLogger.disable(.warn)
      YMBLogger.disable(.error)
    }
  }
  
  private func setupReachability() {
    YMBAnalyticsReachability.shared.startListener()
  }
  
  private func setupProperties() {
    YMBAnalyticsAutomaticProperties.shared.delegate = configuration.automaticPropertiesDelegate
  }
  
  private func setupListeners() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self,
                                   selector: #selector(applicationWillResignActive(_:)),
                                   name: UIApplication.willResignActiveNotification,
                                   object: nil)
    notificationCenter.addObserver(self,
                                   selector: #selector(applicationDidBecomeActive(_:)),
                                   name: UIApplication.didBecomeActiveNotification,
                                   object: nil)
    notificationCenter.addObserver(self,
                                   selector: #selector(applicationDidEnterBackground(_:)),
                                   name: UIApplication.didEnterBackgroundNotification,
                                   object: nil)
    notificationCenter.addObserver(self,
                                   selector: #selector(applicationWillEnterForeground(_:)),
                                   name: UIApplication.willEnterForegroundNotification,
                                   object: nil)
  }
  
  @objc private func applicationDidBecomeActive(_ notification: Notification) {
    flush.applicationDidBecomeActive()
  }
  
  @objc private func applicationWillResignActive(_ notification: Notification) {
    flush.applicationWillResignActive()
  }
  
  @objc private func applicationDidEnterBackground(_ notification: Notification) {
    guard let sharedApplication = sharedApplication() else { return }
    
    let completionHandler: () -> Void = { [weak self] in
      guard let self = self else { return }
      if self.taskId != UIBackgroundTaskIdentifier.invalid {
        sharedApplication.endBackgroundTask(self.taskId)
        self.taskId = UIBackgroundTaskIdentifier.invalid
      }
    }
    
    taskId = sharedApplication.beginBackgroundTask(expirationHandler: completionHandler)
    flush(full: true, completion: completionHandler)
  }
  
  @objc private func applicationWillEnterForeground(_ notification: Notification) {
    guard let sharedApplication = sharedApplication() else { return }
    
    if taskId != UIBackgroundTaskIdentifier.invalid {
      sharedApplication.endBackgroundTask(taskId)
      taskId = UIBackgroundTaskIdentifier.invalid
    }
    
  }
  
  private func sharedApplication() -> UIApplication? {
    let application = UIApplication.perform(NSSelectorFromString("sharedApplication"))?.takeUnretainedValue() as? UIApplication
    guard let application = application else {
        return nil
    }
    return application
  }
  
  private func resetFlushing() {
    storage.update(flag: false)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
}

extension YMBAnalyst: YMBAnalyticsFlushDelegate {
  func flush(full: Bool, completion: (() -> Void)?) {
    trackingQueue.async { [weak self] in
      guard let self = self else {
        if let completion = completion {
          DispatchQueue.main.async(execute: completion)
        }
        return
      }
      let size = full ? Int.max : self.configuration.flushBatchSize
      let batch = self.storage.load(size: size)
      let ids: [Int32] = batch.map { entity in
        (entity[YMBAnalyticsDatabaseConst.kPrimaryKey] as? Int32) ?? 0
      }
      self.storage.update(flag: true, ids: ids)
      self.networkingQueue.async { [weak self, batch, completion] in
        guard let self = self else {
          if let completion = completion {
            DispatchQueue.main.async(execute: completion)
          }
          return
        }
        
        self.flushBatch(batch: batch)
        
        if let completion = completion {
          DispatchQueue.main.async(execute: completion)
        }
      }
    }
  }
  
  func flushSuccess(ids: [Int32]) {
    trackingQueue.async { [weak self] in
      guard let self = self else { return }
      self.storage.remove(ids: ids)
      YMBLogger.error(message: "Ids:\(ids)")
    }
  }
  
  func flushFail(ids: [Int32]) {
    trackingQueue.async { [weak self] in
      guard let self = self else { return }
      self.storage.update(flag: false, ids: ids)
    }
  }
  
  func flushBatch(batch: [YMBAnalyticsInternalProperties]) {
    flush.flushBatch(batch: batch)
  }
}

extension YMBAnalyst {
  func track(event: String, properties: YMBAnalyticsProperties? = nil) {
    let time = Date().timeIntervalSince1970
    trackingQueue.async { [weak self, event, properties, time] in
      guard let self = self else { return }
      assertProperties(properties)
      var trackData = YMBAnalyticsInternalProperties()
      YMBAnalyticsAutomaticProperties.shared.properties().forEach { (key: String, value: YMBAnalyticsType) in
        trackData[key] = value
      }
      
      var eventData = YMBAnalyticsInternalProperties()
      eventData[YMBAnalyticsPropertiesConst.kEventName] = event
      
      if let properties = properties {
        properties.forEach { (key: String, value: YMBAnalyticsType) in
          eventData[key] = value
        }
      }
      trackData[YMBAnalyticsPropertiesConst.kProperties] = eventData
      trackData[YMBAnalyticsPropertiesConst.kActionTime] = time
      self.storage.save(entity: trackData)
    }
  }
}
