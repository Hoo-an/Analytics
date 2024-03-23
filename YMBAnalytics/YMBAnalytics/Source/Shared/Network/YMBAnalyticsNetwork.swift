//
//  YMBAnalyticsNetwork.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/20.
//

import Foundation

struct YMBAnalyticsNetworkConst {
  private init() {}
  static let kHttpOK = 200
}

enum YMBAnalyticsNetworkMethod: String {
  case get
  case post
}

enum YMBAnalyticsNetworkError {
    case serializeError
    case noData
    case notOKStatusCode(statusCode: Int)
    case other(Error)
}

struct YMBAnalyticsNetworkResource<T> {
  let url: String
  let method: YMBAnalyticsNetworkMethod
  let body: Data?
  let query: [String: String?]?
  let headers: [String: String?]?
  let serialize: (Data) -> T?
}

class YMBAnalyticsNetwork {
  
  private init() {}
  
  class func send<T>(_ resource: YMBAnalyticsNetworkResource<T>,
                     success: @escaping (T, URLResponse?) -> Void,
                     failure: @escaping (YMBAnalyticsNetworkError, Data?, URLResponse?) -> Void) {
    
    guard let request = buildingRequest(resource: resource) else { return }
    URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
      guard let httpResponse = response as? HTTPURLResponse else {
          if let error = error {
              failure(.other(error), data, response)
          } else {
              failure(.noData, data, response)
          }
          return
      }
      
      guard httpResponse.statusCode == YMBAnalyticsNetworkConst.kHttpOK else {
        failure(.notOKStatusCode(statusCode: httpResponse.statusCode), data, response)
        return
      }
      
      guard let responseData = data else {
          failure(.noData, data, response)
          return
      }
      
      
      guard let result = resource.serialize(responseData) else {
          failure(.serializeError, data, response)
          return
      }
      
      success(result, response)
    }.resume()
  }
  
  
  private class func buildingRequest<T>(resource: YMBAnalyticsNetworkResource<T>) -> URLRequest? {
    guard let url = buildingURL(url: resource.url, query: resource.query) else { return nil }
    YMBLogger.debug(message: "URL building successful")
    var request = URLRequest(url: url)
    request.httpMethod = resource.method.rawValue
    request.httpBody = resource.body
    resource.headers?.forEach({ (key: String, value: String?) in
      request.setValue(value, forHTTPHeaderField: key)
    })
    return request
  }
  
  private class func buildingURL(url: String, query: [String: String?]?) -> URL? {
    guard let url = URL(string: url) else {
      YMBLogger.error(message: "Building URL fail, String can not parse URL")
      return nil
    }
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
      YMBLogger.error(message: "URL can not be create URLComponents")
      return nil
    }
    var items: [URLQueryItem]?
    if let query = query, query.count > 0 {
      query.forEach { (key: String, value: String?) in
        items?.append(URLQueryItem(name: key, value: value))
      }
    }
    components.queryItems = items
    return components.url
  }
}
