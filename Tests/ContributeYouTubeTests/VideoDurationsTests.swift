//
//  VideoDurationsTests.swift
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

/// Covers `YouTubeContent.videoDurations(_:)`, the title-keyed lookup builder.
@Suite internal struct VideoDurationsTests {
  /// Videos are indexed by title, preserving every field of the source.
  @Test internal func keysEveryVideoByItsTitle() throws {
    let first = try SourceFixtures.video(title: "First", youtubeID: "aaa", duration: 60)
    let second = try SourceFixtures.video(title: "Second", youtubeID: "bbb", duration: 120)

    let durations = try YouTubeContent.videoDurations([first, second])

    #expect(durations.count == 2)
    #expect(durations["First"] == first)
    #expect(durations["Second"] == second)
    #expect(durations["Third"] == nil)
  }

  /// An empty input produces an empty lookup rather than throwing.
  @Test internal func returnsAnEmptyLookupForNoVideos() throws {
    let durations = try YouTubeContent.videoDurations([])

    #expect(durations.isEmpty)
  }

  /// Two identical entries collapse into one, because `Source` is `Equatable`.
  @Test internal func collapsesIdenticalDuplicates() throws {
    let video = try SourceFixtures.video(title: "Repeated")

    let durations = try YouTubeContent.videoDurations([video, video, video])

    #expect(durations.count == 1)
    #expect(durations["Repeated"] == video)
  }

  /// Two different videos sharing a title cannot be keyed, so the call throws.
  @Test internal func throwsWhenDistinctVideosShareATitle() throws {
    let original = try SourceFixtures.video(title: "Shared", youtubeID: "aaa")
    let conflicting = try SourceFixtures.video(title: "Shared", youtubeID: "bbb")

    let error = #expect(throws: YoutubeError.self) {
      try YouTubeContent.videoDurations([original, conflicting])
    }

    guard case .duplicateTitle(let title, let videos) = try #require(error) else {
      Issue.record("Expected a duplicateTitle error, got \(String(describing: error)).")
      return
    }
    #expect(title == "Shared")
    #expect(videos.count == 2)
    #expect(videos.contains(String(describing: original)))
    #expect(videos.contains(String(describing: conflicting)))
  }

  /// A conflict is reported even when the earlier videos indexed cleanly.
  @Test internal func throwsOnAConflictThatFollowsValidEntries() throws {
    let unique = try SourceFixtures.video(title: "Unique", youtubeID: "aaa")
    let original = try SourceFixtures.video(title: "Shared", youtubeID: "bbb", duration: 60)
    let conflicting = try SourceFixtures.video(title: "Shared", youtubeID: "bbb", duration: 90)

    #expect(throws: YoutubeError.self) {
      try YouTubeContent.videoDurations([unique, original, conflicting])
    }
  }
}
