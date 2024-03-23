//
//  YMBAnalyticsFlush.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/19.
//

import Foundation

protocol YMBAnalyticsFlushDelegate: AnyObject {
  func flush(full: Bool, completion: (() -> Void)?)
  func flushSuccess(ids: [Int32])
  func flushFail(ids: [Int32])
}

class YMBAnalyticsFlush: YMBAnalyticsApplicationLifecycle {
  
  private let name: String
  private let flushInterval: TimeInterval
  private let flushLimit: Int
  private let flushBatchSize: Int
  private var timer: Timer?
  private var request: YMBAnalyticsFlushRequest
  weak var delegate: YMBAnalyticsFlushDelegate?
  
  init(name: String, url: String, flushInterval: TimeInterval, flushBatchSize: Int, flushLimit: Int) {
    self.name = name
    self.flushInterval = flushInterval
    self.flushBatchSize = flushBatchSize
    self.flushLimit = flushLimit

    request = YMBAnalyticsFlushRequest(url: url)
    startFlushTimer()
  }
  
  func applicationDidBecomeActive() {
    startFlushTimer()
  }
  
  func applicationWillResignActive() {
    stopFlushTimer()
  }
  
  func flushBatch(batch: [YMBAnalyticsInternalProperties]) {
    var queue = batch
    while !queue.isEmpty {
      let batchSize = min(queue.count, flushBatchSize)
      let range = 0..<batchSize
      let list = Array(queue[range])
      let ids: [Int32] = list.map { entity in
        (entity[YMBAnalyticsDatabaseConst.kPrimaryKey] as? Int32) ?? 0
      }
      YMBLogger.debug(message: "Will sending batch data, count:\(list.count)")
      if request.send(data: list) {
        delegate?.flushSuccess(ids: ids)
        queue = filterBatch(batchSize: batchSize, batch: queue)
      } else {
        delegate?.flushFail(ids: ids)
        break
      }
    }
  }
  
  @objc func flushSelector() {
    delegate?.flush(full: false, completion: nil)
  }
  
  private func filterBatch(batchSize: Int, batch: [YMBAnalyticsInternalProperties]) -> [YMBAnalyticsInternalProperties] {
    var queue = batch
    let range = 0..<batchSize
    if let lastIndex = range.last, queue.count - 1 > lastIndex {
      queue.removeSubrange(range)
    } else {
      queue.removeAll()
    }
    return queue
  }
  
  private func startFlushTimer() {
    stopFlushTimer()
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      if self.flushInterval > 0 {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: self.flushInterval,
                                          target: self,
                                          selector: #selector(self.flushSelector),
                                          userInfo: nil,
                                          repeats: true)
      }
    }
  }
  
  private func stopFlushTimer() {
    if let timer = timer {
      DispatchQueue.main.async { [weak self, timer] in
        timer.invalidate()
        guard let self = self else { return }
        self.timer = nil
      }
    }
  }
  
}
