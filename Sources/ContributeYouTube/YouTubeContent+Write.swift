//
//  YouTubeContent+Write.swift
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
  /// Writes one markdown file per video using the default extractor and translator.
  /// - Parameters:
  ///   - episodes: The videos to write.
  ///   - contentPathURL: The directory to write the markdown files into.
  ///   - fileNameWithoutExtension: Derives each file's name; defaults to the video title.
  ///   - htmlToMarkdown: Converts HTML to markdown for sources that need it.
  ///   - options: Overwrite and pruning behaviour.
  /// - Throws: Any error raised while rendering or writing a markdown file.
  public static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String =
      Self.fileNameWithoutExtensionFromSource(_:),
    using htmlToMarkdown: @escaping (String) throws -> String,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    try self.write(
      episodes: episodes,
      atContentPathURL: contentPathURL,
      fileNameWithoutExtension: fileNameWithoutExtension,
      using: htmlToMarkdown,
      markdownExtractorType: Self.MarkdownExtractorType.self,
      frontMatterTranslatorType: Self.FrontMatterTranslatorType.self,
      options: options
    )
  }

  /// Writes one markdown file per video using a custom markdown extractor.
  /// - Parameters:
  ///   - episodes: The videos to write.
  ///   - contentPathURL: The directory to write the markdown files into.
  ///   - fileNameWithoutExtension: Derives each file's name; defaults to the video title.
  ///   - htmlToMarkdown: Converts HTML to markdown for sources that need it.
  ///   - markdownExtractorType: The extractor used to render each body.
  ///   - options: Overwrite and pruning behaviour.
  /// - Throws: Any error raised while rendering or writing a markdown file.
  public static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String =
      Self.fileNameWithoutExtensionFromSource(_:),
    using htmlToMarkdown: @escaping (String) throws -> String,
    markdownExtractorType: MarkdownExtractorType.Type,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    try self.write(
      episodes: episodes,
      atContentPathURL: contentPathURL,
      fileNameWithoutExtension: fileNameWithoutExtension,
      using: htmlToMarkdown,
      markdownExtractorType: markdownExtractorType,
      frontMatterTranslatorType: Self.FrontMatterTranslatorType.self,
      options: options
    )
  }

  /// Writes one markdown file per video using a custom front-matter translator.
  /// - Parameters:
  ///   - episodes: The videos to write.
  ///   - contentPathURL: The directory to write the markdown files into.
  ///   - fileNameWithoutExtension: Derives each file's name; defaults to the video title.
  ///   - htmlToMarkdown: Converts HTML to markdown for sources that need it.
  ///   - frontMatterTranslatorType: The translator used to render each front matter.
  ///   - options: Overwrite and pruning behaviour.
  /// - Throws: Any error raised while rendering or writing a markdown file.
  public static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String =
      Self.fileNameWithoutExtensionFromSource(_:),
    using htmlToMarkdown: @escaping (String) throws -> String,
    frontMatterTranslatorType: FrontMatterTranslatorType.Type,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    try self.write(
      episodes: episodes,
      atContentPathURL: contentPathURL,
      fileNameWithoutExtension: fileNameWithoutExtension,
      using: htmlToMarkdown,
      markdownExtractorType: Self.MarkdownExtractorType.self,
      frontMatterTranslatorType: frontMatterTranslatorType,
      options: options
    )
  }

  /// Writes one markdown file per video, specifying both the extractor and translator.
  /// - Parameters:
  ///   - episodes: The videos to write.
  ///   - contentPathURL: The directory to write the markdown files into.
  ///   - fileNameWithoutExtension: Derives each file's name; defaults to the video title.
  ///   - htmlToMarkdown: Converts HTML to markdown for sources that need it.
  ///   - markdownExtractorType: The extractor used to render each body.
  ///   - frontMatterTranslatorType: The translator used to render each front matter.
  ///   - options: Overwrite and pruning behaviour.
  /// - Throws: Any error raised while rendering or writing a markdown file.
  public static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String =
      Self.fileNameWithoutExtensionFromSource(_:),
    using htmlToMarkdown: @escaping (String) throws -> String,
    markdownExtractorType: MarkdownExtractorType.Type,
    frontMatterTranslatorType: FrontMatterTranslatorType.Type,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    // The extractor and translator are fixed by this `ContentType`'s associated
    // types; these arguments only disambiguate the overload set.
    _ = (markdownExtractorType, frontMatterTranslatorType)
    try write(
      from: episodes,
      atContentPathURL: contentPathURL,
      fileNameWithoutExtension: fileNameWithoutExtension,
      using: htmlToMarkdown,
      options: options
    )
  }

  /// Derives a file name from a video, defaulting to its title.
  /// - Parameter source: The video to name.
  /// - Returns: The file name, without extension.
  public static func fileNameWithoutExtensionFromSource(
    _ source: SourceType
  ) -> String {
    source.title
  }
}
