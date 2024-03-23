//
//  YMBAnalyticsDatabase.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/19.
//

import Foundation
import SQLite3

struct YMBAnalyticsDatabaseConst {
  private init() {}
  static let kDatabaseName = "analytics.database.sqlite"
  static let kTableName = "analytics"
  static let kPrimaryKey = "analytics.primary.key.autoincrement"
}

class YMBAnalyticsDatabase {
  
  private var connection: OpaquePointer?
  private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
  let name: String
  
  init(name: String) {
    self.name = name
    open()
  }
  
  deinit {
    close()
  }
  
  func open() {
    guard let path = databasePath() else { return }
    if sqlite3_open_v2(path, &connection, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) != SQLITE_OK {
      YMBLogger.error(message: "Open analytics database error at path:\(path)")
      close()
    } else {
      YMBLogger.info(message: "Successfully connection & open to database at path:\(path)")
      if let db = connection {
        let pragma = "PRAGMA journal_mode=WAL;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, pragma, -1, &statement, nil) == SQLITE_OK {
          if sqlite3_step(statement) == SQLITE_ROW {
            let res = String(cString: sqlite3_column_text(statement, 0))
            YMBLogger.info(message: "SQLite journal mode set to \(res)")
          } else {
            YMBLogger.error(message: "Failed to enable journal_mode=WAL")
          }
        } else {
          YMBLogger.error(message: "PRAGMA journal_mode=WAL statement could not be prepared")
        }
        sqlite3_finalize(statement)
      } else {
        reconnect()
      }
      createTable()
    }
  }
  
  func close() {
    sqlite3_close(connection)
    connection = nil
    YMBLogger.info(message: "Connection to database closed.")
  }
  
  func insert(data: Data, flag: Bool = false) {
    if let db = connection {
      let tableName = tableName()
      let sql = "INSERT INTO \(tableName) (data, flag, time) VALUES(?, ?, ?);"
      var statement: OpaquePointer?
      data.withUnsafeBytes { buffer in
        if let pointer = buffer.baseAddress {
          if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_blob(statement, 1, pointer, Int32(buffer.count), SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 2, flag ? 1 : 0)
            sqlite3_bind_double(statement, 3, Date().timeIntervalSince1970)
            if sqlite3_step(statement) == SQLITE_DONE {
              YMBLogger.info(message: "Successfully inserted row into table \(tableName)")
            } else {
              YMBLogger.error(message: "Failed to insert row into table \(tableName)")
              recreate()
            }
          } else {
            YMBLogger.error(message: "INSERT statement for table \(tableName) could not be prepared")
            recreate()
          }
          sqlite3_finalize(statement)
        }
      }
    } else {
      reconnect()
    }
  }
  
  func select(numRows: Int, flag: Bool = false) -> [YMBAnalyticsInternalProperties] {
    var rows: [YMBAnalyticsInternalProperties] = []
    if let db = connection {
      let tableName = tableName()
      let sql = """
        SELECT id, data FROM \(tableName) WHERE flag = \(flag ? 1 : 0) \
        ORDER BY time\(numRows == Int.max ? "" : " LIMIT \(numRows)")
        """
      var statement: OpaquePointer?
      var rowsRead: Int = 0
      if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
        while sqlite3_step(statement) == SQLITE_ROW {
          if let blob = sqlite3_column_blob(statement, 1) {
            let blobLength = sqlite3_column_bytes(statement, 1)
            let data = Data(bytes: blob, count: Int(blobLength))
            let id = sqlite3_column_int(statement, 0)
            
            if let jsonObject = YMBAnalyticsJSONHandler.deserialize(data: data) as? YMBAnalyticsInternalProperties {
              var entity = jsonObject
              entity[YMBAnalyticsDatabaseConst.kPrimaryKey] = id
              rows.append(entity)
            }
            rowsRead += 1
          } else {
            YMBLogger.error(message: "No blob found in data column for row in \(tableName)")
          }
        }
        if rowsRead > 0 {
          YMBLogger.info(message: "Successfully read \(rowsRead) from table \(tableName)")
        }
      } else {
        YMBLogger.error(message: "SELECT statement for table \(tableName) could not be prepared")
      }
      sqlite3_finalize(statement)
    } else {
      reconnect()
    }
    return rows
  }
  
  func updateFlag(flag: Bool, ids: [Int32]? = nil) {
    if let db = connection {
      let tableName = tableName()
      var idsSql: String = ""
      if let ids = ids, ids.count > 0 {
        idsSql = "and id IN \(idsSqlString(ids))"
      }
      let sql = "UPDATE \(tableName) SET flag = \(flag) where flag = \(!flag) \(idsSql)"
      var statement: OpaquePointer?
      if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
        if sqlite3_step(statement) == SQLITE_DONE {
          YMBLogger.info(message: "Successfully updated rows from table \(tableName)")
        } else {
          YMBLogger.error(message: "Failed to update rows from table \(tableName)")
          recreate()
        }
      } else {
        YMBLogger.error(message: "UPDATE statement for table \(tableName) could not be prepared")
        recreate()
      }
      sqlite3_finalize(statement)
    } else {
      reconnect()
    }
  }
  
  func deleteAll() {
    if let db = connection {
      let tableName = tableName()
      let sql = "DELETE FROM \(tableName)"
      var statement: OpaquePointer?
      if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
        if sqlite3_step(statement) == SQLITE_DONE {
          YMBLogger.info(message: "Successfully deleted rows from table \(tableName)")
        } else {
          YMBLogger.error(message: "Failed to delete rows from table \(tableName)")
          recreate()
        }
      } else {
        YMBLogger.error(message: "DELETE statement for table \(tableName) could not be prepared")
        recreate()
      }
      sqlite3_finalize(statement)
    } else {
      reconnect()
    }
  }
  
  func delete(ids: [Int32] = []) {
    if let db = connection {
      let tableName = tableName()
      let idsSql = idsSqlString(ids)
      let sql = "DELETE FROM \(tableName) WHERE id IN \(idsSql)"
      var statement: OpaquePointer?
      if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
        if sqlite3_step(statement) == SQLITE_DONE {
          YMBLogger.info(message: "Successfully deleted rows from table \(tableName)")
        } else {
          YMBLogger.error(message: "Table create failed at table name:\(tableName)")
          recreate()
        }
      } else {
        YMBLogger.error(message: "CREATE statement for table \(tableName) could not be prepared")
        recreate()
      }
      sqlite3_finalize(statement)
    } else {
      reconnect()
    }
  }
  
  private func createTable() {
    if let db = connection {
      let tableName = tableName()
      let sql = "CREATE TABLE IF NOT EXISTS \(tableName)(id integer primary key autoincrement,data blob,time real,flag integer);"
      var statement: OpaquePointer?
      if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
        if sqlite3_step(statement) == SQLITE_DONE {
          YMBLogger.info(message: "Table create successfully at table name:\(tableName)")
        } else {
          YMBLogger.error(message: "Table create failed at table name:\(tableName)")
        }
      } else {
        YMBLogger.error(message: "CREATE statement for table \(tableName) could not be prepared")
      }
      sqlite3_finalize(statement)
    } else {
      reconnect()
    }
  }
  
  private func databasePath() -> String? {
    let manager = FileManager.default
    let url = manager.urls(for: .libraryDirectory, in: .userDomainMask).last
    guard let path = url?.appendingPathComponent("\(name).\(YMBAnalyticsDatabaseConst.kDatabaseName)").path else { return nil }
    return path
  }
  
  private func tableName() -> String {
    return "\(name)_\(YMBAnalyticsDatabaseConst.kTableName)"
  }
  
  private func idsSqlString(_ ids: [Int32] = []) -> String {
      var sqlString = "("
      for id in ids {
          sqlString += "\(id),"
      }
      sqlString = String(sqlString.dropLast())
      sqlString += ")"
      return sqlString
  }
  
  private func reconnect() {
    YMBLogger.warn(message: "Database open fail, reconnect & open")
    open()
  }
  
  private func recreate() {
    close()
    if let path = databasePath() {
      do {
        let manager = FileManager.default
        if manager.fileExists(atPath: path) {
          try manager.removeItem(atPath: path)
          YMBLogger.info(message: "Deleted database file at path: \(path)")
        }
      } catch let error {
        YMBLogger.error(message: "Unable to remove database file at path: \(path), error: \(error)")
      }
    }
    reconnect()
  }

}
