//
//  YoutubeError.swift
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

/// An error raised while decoding YouTube videos into importable sources.
@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public enum YoutubeError: ContributeError {
  /// A required field was absent from the API response for the described video.
  case missingFieldForVideo(String, VideoField)
  /// Two distinct videos share the same title, so they cannot be keyed by title.
  case duplicateTitle(String, forVideos: [String])

  /// A field of a YouTube video that the import pipeline requires.
  public enum VideoField: Sendable {
    /// The video's title, from the API's snippet.
    case snippetTitle
    /// The video's identifier.
    case id
    /// The video's ISO-8601 duration string.
    case duration
    /// The video's description.
    case description
    /// The video's publication date.
    case publishedAt
    /// The video's thumbnail URL.
    case thumbnailUrl
  }
}
