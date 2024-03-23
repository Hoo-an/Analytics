//
//  YMBAnalyticsSha1.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/22.
//

import Foundation
import CryptoKit

class YMBAnalyticsSha1 {
  private init() {}
  
  class func sha1(_ string: String) -> String {
    if let data = string.data(using: .utf8) {
      let hash = Insecure.SHA1.hash(data: data)
      return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    return ""
  }
}
