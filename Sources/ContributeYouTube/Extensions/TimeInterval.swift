//
//  TimeInterval.swift
//  ContributeYouTube
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

extension TimeInterval {
  /// Parses a YouTube ISO-8601 duration string such as `PT1H2M3S` into seconds.
  ///
  /// Absent or unparsable components are treated as zero.
  /// - Parameter duration: The ISO-8601 duration string from the YouTube API.
  internal init(iso6801 duration: String) {
    var duration = duration
    if duration.hasPrefix("PT") { duration.removeFirst(2) }
    let hour: Double
    let minute: Double
    let second: Double
    if let index = duration.firstIndex(of: "H") {
      hour = Double(duration[..<index]) ?? 0
      duration.removeSubrange(...index)
    } else {
      hour = 0
    }
    if let index = duration.firstIndex(of: "M") {
      minute = Double(duration[..<index]) ?? 0
      duration.removeSubrange(...index)
    } else {
      minute = 0
    }
    if let index = duration.firstIndex(of: "S") {
      second = Double(duration[..<index]) ?? 0
    } else {
      second = 0
    }
    self.init(hour * 3_600 + minute * 60 + second)
  }
}
