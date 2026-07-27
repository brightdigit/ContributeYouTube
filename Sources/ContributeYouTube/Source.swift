//
//  Source.swift
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

/// A lookup of decoded YouTube videos keyed by video title.
///
/// Produced by ``YouTubeContent/videoDurations(_:)``.
public typealias VideoDurations = [String: YouTubeContent.Source]

extension YouTubeContent {
  /// A single YouTube video, decoded into the fields the import pipeline needs.
  public struct Source: Equatable, Sendable {
    /// The video's title, used as both the front-matter title and the default file name.
    public let title: String
    /// The video's description, used verbatim as the markdown body.
    public let description: String
    /// The YouTube video identifier.
    public let youtubeID: String
    /// The video's running time, parsed from YouTube's ISO-8601 duration string.
    public let duration: TimeInterval
    /// The date the video was published.
    public let date: Date
    /// The video's standard-resolution thumbnail, if one was provided.
    public let imageURL: URL?

    /// Creates a source value from already-fetched video fields.
    /// - Parameters:
    ///   - title: The video's title.
    ///   - description: The video's description.
    ///   - youtubeID: The YouTube video identifier.
    ///   - duration: The video's running time in seconds.
    ///   - date: The date the video was published.
    ///   - imageURL: The video's thumbnail URL, if any.
    public init(
      title: String,
      description: String,
      youtubeID: String,
      duration: TimeInterval,
      date: Date,
      imageURL: URL?
    ) {
      self.title = title
      self.description = description
      self.youtubeID = youtubeID
      self.duration = duration
      self.date = date
      self.imageURL = imageURL
    }
  }
}
