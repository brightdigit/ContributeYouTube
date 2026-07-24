//
//  FrontMatterTranslatorTests.swift
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

/// Covers `YouTubeContent.FrontMatterTranslator` and the front matter it produces.
@Suite internal struct FrontMatterTranslatorTests {
  /// Every field of a video maps onto the matching front matter field.
  @Test internal func mapsEveryFieldOfTheSource() throws {
    let thumbnail = URL(string: "https://i.ytimg.com/vi/xyz789/sddefault.jpg")
    let source = try SourceFixtures.video(
      title: "Empower Apps: Episode 1",
      description: "Body text that never reaches the front matter.",
      youtubeID: "xyz789",
      duration: 3_723,
      imageURL: thumbnail
    )

    let frontMatter = YouTubeContent.FrontMatterTranslator().frontMatter(from: source)

    #expect(frontMatter.title == "Empower Apps: Episode 1")
    #expect(frontMatter.youtubeID == "xyz789")
    #expect(frontMatter.videoDuration == 3_723)
    #expect(frontMatter.featuredImage == thumbnail)
    #expect(frontMatter.date == SourceFixtures.frontMatterDateString(for: source.date))
  }

  /// The date is rendered as `yyyy-MM-dd HH:mm` in the current time zone.
  @Test internal func formatsTheDateAsMinutePrecisionLocalTime() throws {
    let date = try SourceFixtures.date()
    let source = try SourceFixtures.video(date: date)

    let frontMatter = YouTubeContent.FrontMatterTranslator().frontMatter(from: source)

    #expect(frontMatter.date == "2026-07-23 14:30")
  }

  /// A missing thumbnail stays missing rather than becoming a placeholder.
  @Test internal func leavesTheFeaturedImageNilWhenThereIsNoThumbnail() throws {
    let source = try SourceFixtures.video(imageURL: nil)

    let frontMatter = YouTubeContent.FrontMatterTranslator().frontMatter(from: source)

    #expect(frontMatter.featuredImage == nil)
  }

  /// The duration is truncated to whole seconds, never rounded.
  @Test(
    arguments: [
      (TimeInterval(0), 0),
      (TimeInterval(59.4), 59),
      (TimeInterval(59.9), 59),
      (TimeInterval(3_723.75), 3_723),
    ]
  )
  internal func truncatesTheDurationToWholeSeconds(
    duration: TimeInterval,
    expected: Int
  ) throws {
    let source = try SourceFixtures.video(duration: duration)

    let frontMatter = YouTubeContent.FrontMatterTranslator().frontMatter(from: source)

    #expect(frontMatter.videoDuration == expected)
  }

  /// The translator is a pure mapping, so repeated calls agree.
  @Test internal func producesTheSameFrontMatterForTheSameSource() throws {
    let source = try SourceFixtures.video()
    let translator = YouTubeContent.FrontMatterTranslator()

    let first = translator.frontMatter(from: source)
    let second = YouTubeContent.FrontMatterTranslator.FrontMatter(episode: source)

    #expect(first.title == second.title)
    #expect(first.date == second.date)
    #expect(first.youtubeID == second.youtubeID)
    #expect(first.videoDuration == second.videoDuration)
    #expect(first.featuredImage == second.featuredImage)
  }
}
