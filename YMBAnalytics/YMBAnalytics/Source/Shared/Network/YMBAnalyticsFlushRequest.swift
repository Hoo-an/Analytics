//
//  YMBAnalyticsFlushRequest.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/20.
//

import Foundation

class YMBAnalyticsFlushRequest {
  
  let url: String
  
  init(url: String) {
    self.url = url
    
  }
  
  func send(data: [YMBAnalyticsInternalProperties]) -> Bool {
    let serialize: (Data) -> Bool = { data in
      let dto = YMBAnalyticsResponseDto.instance(from: data)
      return dto?.isSuccess() ?? false
    }
    
    var body: Any
    if data.count == 1 {
      body = data.first ?? YMBAnalyticsInternalProperties()
    } else {
      body = data
    }
    
    let headers = ["Content-Type": "application/json",
                   "Accept-Encoding": "gzip"]
    let resource = YMBAnalyticsNetworkResource(url: url,
                                               method: .post,
                                               body: YMBAnalyticsJSONHandler.serialize(body),
                                               query: nil,
                                               headers: headers,
                                               serialize: serialize)
    var result = false
    let semaphore = DispatchSemaphore(value: 0)
    send(resource: resource) { success in
      result = success
      semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + 20)
    return result
  }
  
  private func send(resource: YMBAnalyticsNetworkResource<Bool>, completion: @escaping (Bool) -> Void) {
    YMBAnalyticsNetwork.send(resource) { (result, response) in
      YMBLogger.debug(message: "Analytics Call API success")
      completion(true)
    } failure: { (reason, _, response ) in
      YMBLogger.debug(message: "Call API failure error:\(reason)")
      completion(false)
    }
  }
  
}
