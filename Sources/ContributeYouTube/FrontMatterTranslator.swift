//
//  FrontMatterTranslator.swift
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

extension YouTubeContent {
  /// Maps a decoded YouTube video onto the YAML front matter written above each markdown body.
  public struct FrontMatterTranslator: Contribute.FrontMatterTranslator {
    /// The decoded video this translator reads from.
    public typealias SourceType = Source
    /// The `Encodable` front matter this translator produces.
    public typealias FrontMatterType = FrontMatter

    /// The front matter emitted for a single YouTube video.
    public struct FrontMatter: Codable {
      internal let title: String
      internal let date: String
      internal let featuredImage: URL?
      internal let youtubeID: String
      internal let videoDuration: Int

      /// Creates front matter from a decoded video.
      /// - Parameter episode: The video to describe.
      public init(episode: Source) {
        title = episode.title
        date = YAML.dateFormatter.string(from: episode.date)
        featuredImage = episode.imageURL
        youtubeID = episode.youtubeID
        videoDuration = Int(episode.duration)
      }
    }

    /// Creates a translator.
    public init() {}

    /// Produces the front matter for a video.
    /// - Parameter source: The video to describe.
    /// - Returns: The front matter written above the markdown body.
    public func frontMatter(from source: Source) -> FrontMatter {
      FrontMatter(episode: source)
    }
  }
}
