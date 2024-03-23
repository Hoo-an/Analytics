//
//  YMBAnalyticsResponse.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/23.
//

import Foundation

struct YMBAnalyticsResponseConst {
  private init() {}
  static let kSuccessMessageId = "10000"
}

struct YMBAnalyticsResponseDto: Codable {
  var messageId: String?
  var success: String?
  var body: String?
  
  static func instance(from: Data) -> Self? {
    do {
      let dto = try JSONDecoder().decode(YMBAnalyticsResponseDto.self, from: from)
      return dto
    } catch let error {
      YMBLogger.error(message: "Analytics reponse data to YMBAnalyticsResponseDto fail error:\(error)")
      return nil
    }
  }
  
  func isSuccess() -> Bool {
    return success == YMBAnalyticsResponseConst.kSuccessMessageId
  }
}
