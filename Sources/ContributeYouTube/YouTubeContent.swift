//
//  YouTubeContent.swift
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
import SwiftTube

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Binds YouTube videos to their markdown extractor and front-matter translator.
///
/// This is the `Contribute` `ContentType` for YouTube: fetch with
/// ``videos(byRequest:)``, then write with one of the `write(episodes:…)` overloads.
public enum YouTubeContent: ContentType {
  /// The decoded video model the pipeline operates on.
  public typealias SourceType = Source
  /// The extractor that renders a video's markdown body.
  public typealias MarkdownExtractorType = MarkdownExtractor
  /// The translator that renders a video's YAML front matter.
  public typealias FrontMatterTranslatorType = FrontMatterTranslator
}

extension YouTubeContent {
  /// Fetches every video in the request's playlist via the async
  /// swift-openapi-generator `YouTubeClient`, mapping each into a ``Source``.
  /// - Parameter request: The API key and playlist identifier to fetch.
  /// - Returns: One decoded source per video in the playlist.
  /// - Throws: ``YoutubeError/missingFieldForVideo(_:_:)`` if any video omits a
  ///   required field, or any error surfaced by the underlying client.
  public static func videos(
    byRequest request: YouTubePlaylistRequest
  ) async throws -> [SourceType] {
    let client = YouTubeClient(apiKey: request.apiKey)
    let videos = try await client.videos(forPlaylistID: request.playlistID)

    return try videos.map { video in
      guard let id = video.id else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .id)
      }
      guard let title = video.title?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .snippetTitle)
      }
      guard let description = video.description else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .description)
      }
      guard let durationString = video.duration else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .duration)
      }
      guard let publishedAt = video.publishedAt else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .publishedAt)
      }
      guard let imageUrl = video.standardThumbnailURL else {
        throw YoutubeError.missingFieldForVideo(String(describing: video), .thumbnailUrl)
      }
      return .init(
        title: title,
        description: description,
        youtubeID: id,
        duration: .init(iso6801: durationString),
        date: publishedAt,
        imageURL: URL(string: imageUrl)
      )
    }
  }

  /// Folds decoded videos into a title-keyed lookup.
  /// - Parameter videos: The videos to index.
  /// - Returns: A dictionary of videos keyed by title.
  /// - Throws: ``YoutubeError/duplicateTitle(_:forVideos:)`` when two distinct
  ///   videos share a title.
  public static func videoDurations(_ videos: [SourceType]) throws -> VideoDurations {
    try videos
      .reduce(VideoDurations()) { dictionary, video in
        let title = video.title
        if let existingVideo = dictionary[title] {
          guard existingVideo == video else {
            throw YoutubeError.duplicateTitle(
              title,
              forVideos: [existingVideo, video].map { String(describing: $0) }
            )
          }
          return dictionary
        } else {
          var newDictionary = dictionary
          newDictionary[title] = video
          return newDictionary
        }
      }
  }
}
