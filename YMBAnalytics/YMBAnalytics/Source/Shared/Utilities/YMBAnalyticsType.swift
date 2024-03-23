//
//  YMBAnalyticsType.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/16.
//

import Foundation


typealias YMBAnalyticsProperties = [String: YMBAnalyticsType]
typealias YMBAnalyticsInternalProperties = [String: Any]

protocol YMBAnalyticsType: Any {
  func isValid() -> Bool
  func equals(rhs: YMBAnalyticsType) -> Bool
}


extension Optional: YMBAnalyticsType {
  
  func isValid() -> Bool {
    guard let value = self else { return true }
    switch value {
      case let value as YMBAnalyticsType:
        return value.isValid()
      default:
        return false
    }
  }
  
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if let value = self as? String, rhs is String {
        return value == rhs as! String
    } else if let value = self as? NSString, rhs is NSString {
        return value == rhs as! NSString
    } else if let value = self as? NSNumber, rhs is NSNumber {
        return value.isEqual(to: rhs as! NSNumber)
    } else if let value = self as? Int, rhs is Int {
        return value == rhs as! Int
    } else if let value = self as? UInt, rhs is UInt {
        return value == rhs as! UInt
    } else if let value = self as? Double, rhs is Double {
        return value == rhs as! Double
    } else if let value = self as? Float, rhs is Float {
        return value == rhs as! Float
    } else if let value = self as? Bool, rhs is Bool {
        return value == rhs as! Bool
    } else if let value = self as? Date, rhs is Date {
        return value == rhs as! Date
    } else if let value = self as? URL, rhs is URL {
        return value == rhs as! URL
    } else if self is NSNull && rhs is NSNull {
        return true
    }
    return false
  }
}


extension String: YMBAnalyticsType {
  func isValid() -> Bool {
    return true
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is String {
      return self == rhs as! String
    }
    return false
  }
}

extension NSString: YMBAnalyticsType {
  func isValid() -> Bool {
    return true
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is NSString {
      return self == rhs as! NSString
    }
    return false
  }
}


extension NSNumber: YMBAnalyticsType {
  func isValid() -> Bool {
    return !self.doubleValue.isInfinite && !self.doubleValue.isNaN
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is NSNumber {
      return self.isEqual(rhs)
    }
    return false
  }
}


extension Int: YMBAnalyticsType {
  func isValid() -> Bool {
    return true
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is Int {
      return self == rhs as! Int
    }
    return false
  }
}

extension UInt: YMBAnalyticsType {
  func isValid() -> Bool {
    return true
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is UInt {
      return self == rhs as! UInt
    }
    return false
  }
}

extension Double: YMBAnalyticsType {
  func isValid() -> Bool {
    return !self.isInfinite && !self.isNaN
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is Double {
      return self == rhs as! Double
    }
    return false
  }
}

extension Float: YMBAnalyticsType {
  func isValid() -> Bool {
    return !self.isInfinite && !self.isNaN
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is Float {
      return self == rhs as! Float
    }
    return false
  }
}

extension Bool: YMBAnalyticsType {
  func isValid() -> Bool {
    return true
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is Bool {
      return self == rhs as! Bool
    }
    return false
  }
}

extension Date: YMBAnalyticsType {
  func isValid() -> Bool {
    return true
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is Date {
      return self == rhs as! Date
    }
    return false
  }
}

extension URL: YMBAnalyticsType {
  func isValid() -> Bool {
    return true
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is URL {
      return self == rhs as! URL
    }
    return false
  }
}

extension NSNull: YMBAnalyticsType {
  func isValid() -> Bool {
    return true
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    return rhs is NSNull
  }
}

extension Array: YMBAnalyticsType {
  public func isValid() -> Bool {
    for element in self {
      guard let _ = element as? YMBAnalyticsType else {
        return false
      }
    }
    return true
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is [YMBAnalyticsType] {
      let rhs = rhs as! [YMBAnalyticsType]
      
      if self.count != rhs.count {
        return false
      }
      
      if !isValid() {
        return false
      }
      
      let lhs = self as! [YMBAnalyticsType]
      for (i, value) in lhs.enumerated() {
        if !value.equals(rhs: rhs[i]) {
          return false
        }
      }
      return true
    }
    return false
  }
}

extension NSArray: YMBAnalyticsType {
  
  func isValid() -> Bool {
    for element in self {
      guard let _ = element as? YMBAnalyticsType else {
        return false
      }
    }
    return true
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is [YMBAnalyticsType] {
      let rhs = rhs as! [YMBAnalyticsType]
      
      if self.count != rhs.count {
        return false
      }
      
      if !isValid() {
        return false
      }
      
      let lhs = self as! [YMBAnalyticsType]
      for (i, value) in lhs.enumerated() {
        if !value.equals(rhs: rhs[i]) {
          return false
        }
      }
      return true
    }
    return false
  }
}

extension Dictionary: YMBAnalyticsType {
  func isValid() -> Bool {
    for (key, value) in self {
      guard let _ = key as? String, let _ = value as? YMBAnalyticsType else {
        return false
      }
    }
    return true
  }
  
  func equals(rhs: YMBAnalyticsType) -> Bool {
    if rhs is YMBAnalyticsProperties {
      let rhs = rhs as! YMBAnalyticsProperties
      
      if self.keys.count != rhs.keys.count {
        return false
      }
      
      if !isValid() {
        return false
      }
      
      for (key, value) in self as! YMBAnalyticsProperties {
        guard let rValuel = rhs[key] else {
          return false
        }
        
        if !value.equals(rhs: rValuel) {
          return false
        }
      }
      return true
    }
    return false
  }
}

func assertProperties(_ properties: YMBAnalyticsProperties?) {
  if let properties = properties {
    for (_, value) in properties {
      YMBAnalyticsAssert(value.isValid(), "Property valid failed. \(type(of: value)) and Value \(value)")
    }
  }
}

extension Dictionary {
  func get<T>(key: Key, defaultValue: T) -> T {
    if let value = self[key] as? T {
      return value
    }
    return defaultValue
  }
}
