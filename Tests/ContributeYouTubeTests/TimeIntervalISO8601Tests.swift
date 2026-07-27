//
//  TimeIntervalISO8601Tests.swift
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

/// Covers `TimeInterval.init(iso6801:)`, the parser for YouTube's duration strings.
@Suite internal struct TimeIntervalISO8601Tests {
  /// Every combination of the hour, minute and second components YouTube emits.
  @Test(
    arguments: [
      ("PT1H2M3S", TimeInterval(3_723)),
      ("PT2H", TimeInterval(7_200)),
      ("PT23M45S", TimeInterval(1_425)),
      ("PT45S", TimeInterval(45)),
      ("PT12M", TimeInterval(720)),
      ("PT1H30S", TimeInterval(3_630)),
      ("PT1H5M", TimeInterval(3_900)),
    ]
  )
  internal func parsesComponentCombinations(duration: String, expected: TimeInterval) {
    #expect(TimeInterval(iso6801: duration) == expected)
  }

  /// Components larger than their usual range are summed, not normalized.
  @Test internal func doesNotNormalizeOversizedComponents() {
    #expect(TimeInterval(iso6801: "PT90M") == 5_400)
    #expect(TimeInterval(iso6801: "PT120S") == 120)
    #expect(TimeInterval(iso6801: "PT1H90M90S") == 9_090)
  }

  /// Fractional seconds survive the parse, since each component is parsed as a `Double`.
  @Test internal func parsesFractionalSeconds() {
    #expect(TimeInterval(iso6801: "PT1.5S") == 1.5)
    #expect(TimeInterval(iso6801: "PT1M0.25S") == 60.25)
  }

  /// The `PT` prefix is stripped when present but is not required.
  @Test internal func treatsPrefixAsOptional() {
    #expect(TimeInterval(iso6801: "1H2M3S") == TimeInterval(iso6801: "PT1H2M3S"))
    #expect(TimeInterval(iso6801: "45S") == 45)
  }

  /// Unparsable or absent components are treated as zero rather than throwing.
  @Test(
    arguments: [
      "",
      "PT",
      "P0D",
      "PTS",
      "PTxHyMzS",
      "not a duration",
    ]
  )
  internal func treatsUnparsableInputAsZero(duration: String) {
    #expect(TimeInterval(iso6801: duration) == 0)
  }

  /// A malformed component zeroes only itself; the well-formed ones still count.
  @Test internal func keepsWellFormedComponentsAlongsideMalformedOnes() {
    #expect(TimeInterval(iso6801: "PTxH5M10S") == 310)
    #expect(TimeInterval(iso6801: "PT2HxM10S") == 7_210)
  }
}
