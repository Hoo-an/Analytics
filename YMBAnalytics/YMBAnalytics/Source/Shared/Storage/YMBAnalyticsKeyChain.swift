//
//  YMBAnalyticsKeyChain.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/22.
//

import Foundation
import Security

struct YMBAnalyticsKeyChainConst {
  private init() {}
  
  static let kService = "analytics.keychain.service"
  static let kAccessGroup = "analytics.keychain.access.group"
}

class YMBAnalyticsKeyChain {
  
  static let shared = YMBAnalyticsKeyChain()
  
  private init() {}
  
  func write(key: String, string: String?) {
    if let string = string {
      write(key: key, data: string.data(using: .utf8))
    } else {
      write(key: key, data: nil)
    }
  }
  
  func write(key: String, data: Data?) {
    guard let data = data else {
      remove(key: key)
      return
    }
    
    let addItemQuery = self.writeOnlyQuery(key: key, data: data)
    let addStatus = SecItemAdd(addItemQuery as CFDictionary, nil)
    if addStatus == errSecDuplicateItem {
      let updateQuery = self.baseQuery(key: key)
      let updateAttributes: [String: Any] = [kSecValueData as String: data]
      let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
      if updateStatus != errSecSuccess {
        YMBLogger.error(message: "Write Keychain error, code:\(updateStatus)")
      }
    }
  }
  
  func string(key: String) -> String? {
    if let data = read(key: key) {
      return String(data: data, encoding: .utf8)
    } else {
      return nil
    }
  }
  
  func read(key: String) -> Data? {
    let query = self.readOnlyQuery(key: key)
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    if status == errSecSuccess, let result = result, let data = result as? Data {
      return data
    } else {
      YMBLogger.info(message: "Read Keychain fail Maybe can not read with key")
      return nil
    }
  }
  
  
  func remove(key: String) {
    let query = self.baseQuery(key: key)
    let status = SecItemDelete(query as CFDictionary)
    if status != errSecSuccess {
      YMBLogger.error(message: "Remove Keychain error, code:\(status)")
    } else {
      YMBLogger.error(message: "Remove Keychain success")
    }
  }
  
}

extension YMBAnalyticsKeyChain {
  
  private func baseQuery(key: String? = nil, data: Data? = nil) -> [String: Any] {
    var query = [String: Any]()
    query[kSecClass as String] = kSecClassGenericPassword
    query[kSecAttrService as String] = YMBAnalyticsKeyChainConst.kService
    query[kSecAttrAccessGroup as String] = YMBAnalyticsKeyChainConst.kAccessGroup
    query[kSecAttrSynchronizable as String] = kCFBooleanTrue
    if let key = key {
        query[kSecAttrAccount as String] = key
    }
    if let data = data {
        query[kSecValueData as String] = data
    }
    return query
  }
  
  private func readAllQuery() -> [String: Any] {
    var query = self.baseQuery()
    query[kSecReturnAttributes as String] = kCFBooleanTrue
    query[kSecMatchLimit as String] = kSecMatchLimitAll
    return query
  }
  
  private func readOnlyQuery(key: String) -> [String: Any] {
    var query = self.baseQuery(key: key)
    query[kSecReturnData as String] = kCFBooleanTrue
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    return query
  }
  
  private func writeOnlyQuery(key: String, data: Data) -> [String: Any] {
    var query = self.baseQuery(key: key, data: data)
    query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
    return query
  }
  
}
