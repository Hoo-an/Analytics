//
//  YMBAnalyticsEventStorage.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/19.
//

import Foundation

class YMBAnalyticsEventStorage {
  
  private let database: YMBAnalyticsDatabase
  private let name: String
  
  init(name: String) {
    self.name = name
    database = YMBAnalyticsDatabase.init(name: name)
  }
  
  deinit {
    database.close()
  }
  
  func closeDatabase() {
    database.close()
  }
  
  func save(entity: YMBAnalyticsInternalProperties, flag: Bool = false) {
    if let data = YMBAnalyticsJSONHandler.serialize(entity) {
      database.insert(data: data, flag: flag)
    }
  }
  
  func save(entities: [YMBAnalyticsInternalProperties], flag: Bool = false) {
    for entity in entities {
      save(entity: entity, flag: flag)
    }
  }
  
  func load(size: Int = Int.max, flag: Bool = false) -> [YMBAnalyticsInternalProperties] {
    let entities = database.select(numRows: size, flag: flag)
    return entities
  }
  
  func remove(ids: [Int32]) {
    database.delete(ids: ids)
  }
  
  func removeAll() {
    database.deleteAll()
  }
  
  func update(flag: Bool = true, ids: [Int32]? = nil) {
    database.updateFlag(flag: flag, ids: ids)
  }
  
}
