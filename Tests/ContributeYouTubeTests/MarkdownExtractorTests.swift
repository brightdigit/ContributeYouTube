//
//  MarkdownExtractorTests.swift
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

/// Covers `YouTubeContent.MarkdownExtractor`, which passes descriptions through unchanged.
@Suite internal struct MarkdownExtractorTests {
  /// The description becomes the markdown body verbatim.
  @Test internal func returnsTheDescriptionVerbatim() throws {
    let description = """
      Line one of the description.

      Line two, with *asterisks* and a https://example.com link.
      """
    let source = try SourceFixtures.video(description: description)

    let markdown = try YouTubeContent.MarkdownExtractor().markdown(from: source) { _ in
      "converted"
    }

    #expect(markdown == description)
  }

  /// The injected HTML-to-markdown conversion is never invoked.
  @Test internal func neverCallsTheHTMLConverter() throws {
    let source = try SourceFixtures.video(description: "<p>Not actually HTML.</p>")
    var converterWasCalled = false

    let markdown = try YouTubeContent.MarkdownExtractor().markdown(from: source) { input in
      converterWasCalled = true
      return input
    }

    #expect(markdown == "<p>Not actually HTML.</p>")
    #expect(converterWasCalled == false)
  }

  /// A converter that always throws does not make extraction throw.
  @Test internal func doesNotPropagateConverterErrors() throws {
    let source = try SourceFixtures.video(description: "Plain text.")

    let markdown = try YouTubeContent.MarkdownExtractor().markdown(from: source) { _ in
      throw CocoaError(.fileNoSuchFile)
    }

    #expect(markdown == "Plain text.")
  }

  /// An empty description yields an empty body rather than a nil or placeholder.
  @Test internal func returnsAnEmptyBodyForAnEmptyDescription() throws {
    let source = try SourceFixtures.video(description: "")

    let markdown = try YouTubeContent.MarkdownExtractor().markdown(from: source) { $0 }

    #expect(markdown.isEmpty)
  }
}
