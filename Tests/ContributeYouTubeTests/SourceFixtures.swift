//
//  SourceFixtures.swift
//  BrightDigit
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
import Testing

@testable import ContributeYouTube

/// Shared builders for the `YouTubeContent.Source` values the suites exercise.
internal enum SourceFixtures {
  /// The wall-clock date every fixture defaults to, in the current time zone.
  internal static let defaultDateComponents = DateComponents(
    year: 2_026,
    month: 7,
    day: 23,
    hour: 14,
    minute: 30
  )

  /// Builds a date from wall-clock components in the current time zone.
  ///
  /// The front matter formatter also uses the current time zone, so a literal
  /// expectation such as `2026-07-23 14:30` holds wherever the tests run.
  /// - Parameter components: The wall-clock components to resolve.
  /// - Returns: The resolved date.
  /// - Throws: An expectation failure if the components do not resolve.
  internal static func date(
    from components: DateComponents = Self.defaultDateComponents
  ) throws -> Date {
    let calendar = Calendar(identifier: .gregorian)
    return try #require(calendar.date(from: components))
  }

  /// Formats a date exactly the way `Contribute`'s front matter formatter does.
  /// - Parameter date: The date to format.
  /// - Returns: The `yyyy-MM-dd HH:mm` representation in the current time zone.
  internal static func frontMatterDateString(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    formatter.timeZone = .current
    return formatter.string(from: date)
  }

  /// Builds a decoded video with overridable fields.
  /// - Parameters:
  ///   - title: The video title.
  ///   - description: The video description, used as the markdown body.
  ///   - youtubeID: The YouTube video identifier.
  ///   - duration: The running time in seconds.
  ///   - date: The publication date.
  ///   - imageURL: The thumbnail URL, if any.
  /// - Returns: The decoded video.
  /// - Throws: An expectation failure if the default date does not resolve.
  internal static func video(
    title: String = "Sample Video",
    description: String = "Sample description.",
    youtubeID: String = "abc123",
    duration: TimeInterval = 3_723,
    date: Date? = nil,
    imageURL: URL? = URL(string: "https://i.ytimg.com/vi/abc123/sddefault.jpg")
  ) throws -> YouTubeContent.Source {
    let resolvedDate = try date ?? Self.date()
    return YouTubeContent.Source(
      title: title,
      description: description,
      youtubeID: youtubeID,
      duration: duration,
      date: resolvedDate,
      imageURL: imageURL
    )
  }
}
