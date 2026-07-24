//
//  MarkdownExtractor.swift
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

import Contribute
import Foundation

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
extension YouTubeContent {
  /// Produces the markdown body for a YouTube video.
  ///
  /// YouTube descriptions are already plain text, so the injected HTML-to-markdown
  /// conversion is deliberately unused and the description is returned verbatim.
  public struct MarkdownExtractor: Contribute.MarkdownExtractor {
    /// The decoded video this extractor reads from.
    public typealias SourceType = Source

    /// Creates an extractor.
    public init() {}

    /// Returns the video's description as the markdown body.
    /// - Parameters:
    ///   - source: The video to render.
    ///   - htmlToMarkdown: Ignored; YouTube descriptions are not HTML.
    /// - Returns: The video's description.
    /// - Throws: Never; the signature is `throws` to satisfy the protocol.
    public func markdown(
      from source: SourceType,
      using htmlToMarkdown: @escaping (String) throws -> String
    ) throws -> String {
      // YouTube descriptions are plain text, so no HTML conversion is required.
      _ = htmlToMarkdown
      return source.description
    }
  }
}
