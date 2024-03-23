//
//  YMBAnalyticsJSONHandler.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/19.
//

import Foundation

class YMBAnalyticsJSONHandler {
  
  private init() {}
  
  class func deserialize(data: Data) -> Any? {
    var object: Any?
    do {
      object = try JSONSerialization.jsonObject(with: data, options: [])
    } catch let error {
      YMBLogger.warn(message: "Exception decoding object data error:\(error)")
    }
    return object
  }
  
  class func serialize(_ object: Any) -> Data? {
    let jsonObject: Any
    if let json = makeSerializable(object) as? [Any] {
      jsonObject = json.filter { JSONSerialization.isValidJSONObject($0) }
    } else {
      jsonObject = makeSerializable(object)
    }
    
    guard JSONSerialization.isValidJSONObject(jsonObject) else {
      YMBLogger.warn(message: "Object isn't valid and can't be serialzed to JSON")
      return nil
    }
    
    var data: Data?
    do {
      data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
    } catch {
      YMBLogger.warn(message: "exception encoding api data")
    }
    return data
  }
  
  private class func makeSerializable(_ object: Any) -> Any {
    switch object {
      case let object as NSNumber:
        if isBoolNumber(object) {
          return object.boolValue
        } else if isInvalidNumber(object) {
          return String(describing: object)
        } else {
          return object
        }
      
      case let object as Double where object.isFinite && !object.isNaN:
        return object
      
      case let object as Float where object.isFinite && !object.isNaN:
        return object
      
      case is String, is Int, is UInt, is UInt64, is Bool:
        return object
        
      case let object as [Any?]:
        let nonNilEls: [Any] = object.compactMap({ $0 })
        return nonNilEls.map { makeSerializable($0) }
        
      case let object as [Any]:
        return object.map { makeSerializable($0) }
        
      case let object as YMBAnalyticsInternalProperties:
        var dictionary = YMBAnalyticsInternalProperties()
        _ = object.map { e in
          dictionary[e.key] = makeSerializable(e.value)
        }
        return dictionary
        
      case let object as Date:
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: object)
        
      case let object as URL:
        return object.absoluteString
        
      default:
        let string = String(describing: object)
        if string == "nil" {
          return NSNull()
        } else {
          YMBLogger.info(message: "enforcing string on object")
          return string
        }
    }
  }
  
  private class func isBoolNumber(_ num: NSNumber) -> Bool {
      let boolID = CFBooleanGetTypeID()
      let numID = CFGetTypeID(num)
      return numID == boolID
  }

  private class func isInvalidNumber(_ num: NSNumber) -> Bool {
      return  num.doubleValue.isInfinite ||  num.doubleValue.isNaN
  }
  
}
