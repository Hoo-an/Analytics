//
//  YMBAnalyticsAssert.swift
//  YMBAnalytics
//
//  Created by Herman.An on 2024/3/16.
//

import Foundation

class YMBAnalyticsAssertions {
  static var assertClosure      = swiftAssertClosure
  static let swiftAssertClosure = { Swift.assert($0, $1, file: $2, line: $3) }
}

func YMBAnalyticsAssert(_ condition: @autoclosure() -> Bool,
                        _ message: @autoclosure() -> String = "",
                        file: StaticString = #file,
                        line: UInt = #line) {
  YMBAnalyticsAssertions.assertClosure(condition(), message(), file, line)
}
