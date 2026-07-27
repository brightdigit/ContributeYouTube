//
//  ContributeYouTubeTests.swift
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

/// Covers the `YouTubeContent` write pipeline end to end, on a temporary directory.
@Suite internal struct ContributeYouTubeTests {
  /// Creates an empty directory under the system temporary directory.
  /// - Returns: The URL of the created directory.
  /// - Throws: Any error raised while creating the directory.
  private static func makeTemporaryDirectory() throws -> URL {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("ContributeYouTubeTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(
      at: directory,
      withIntermediateDirectories: true
    )
    return directory
  }

  /// The default file name is the video's title.
  @Test internal func namesFilesAfterTheVideoTitle() throws {
    let source = try SourceFixtures.video(title: "Empower Apps Episode 42")

    let name = YouTubeContent.fileNameWithoutExtensionFromSource(source)

    #expect(name == "Empower Apps Episode 42")
  }

  /// Writing produces one `.md` file per video, front matter first, body last.
  @Test internal func writesFrontMatterAndBodyForEachVideo() throws {
    let directory = try Self.makeTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }
    let source = try SourceFixtures.video(
      title: "Sample Video",
      description: "The description becomes the body.",
      youtubeID: "abc123",
      duration: 3_723
    )

    try YouTubeContent.write(
      episodes: [source],
      atContentPathURL: directory,
      using: { $0 }
    )

    let contents = try String(
      contentsOf: directory.appendingPathComponent("Sample Video.md"),
      encoding: .utf8
    )
    #expect(contents.hasPrefix("---\n"))
    #expect(contents.contains("\n---\n"))
    #expect(contents.contains("title: Sample Video"))
    #expect(contents.contains("youtubeID: abc123"))
    #expect(contents.contains("videoDuration: 3723"))
    #expect(contents.contains("https://i.ytimg.com/vi/abc123/sddefault.jpg"))
    #expect(contents.contains(SourceFixtures.frontMatterDateString(for: source.date)))
    #expect(contents.hasSuffix("The description becomes the body."))
  }

  /// Every video in the batch gets its own file.
  @Test internal func writesOneFilePerVideo() throws {
    let directory = try Self.makeTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }
    let episodes = [
      try SourceFixtures.video(title: "First", youtubeID: "aaa"),
      try SourceFixtures.video(title: "Second", youtubeID: "bbb"),
    ]

    try YouTubeContent.write(
      episodes: episodes,
      atContentPathURL: directory,
      using: { $0 }
    )

    let written = try FileManager.default
      .contentsOfDirectory(atPath: directory.path)
      .sorted()
    #expect(written == ["First.md", "Second.md"])
  }

  /// A caller-supplied name generator replaces the title-based default.
  @Test internal func honorsACustomFileNameGenerator() throws {
    let directory = try Self.makeTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }
    let source = try SourceFixtures.video(title: "Title With Spaces", youtubeID: "zzz999")

    try YouTubeContent.write(
      episodes: [source],
      atContentPathURL: directory,
      fileNameWithoutExtension: { $0.youtubeID },
      using: { $0 }
    )

    let written = try FileManager.default.contentsOfDirectory(atPath: directory.path)
    #expect(written == ["zzz999.md"])
  }

  /// Naming the extractor and translator explicitly writes the same content.
  @Test internal func producesTheSameOutputWhenTypesAreNamedExplicitly() throws {
    let directory = try Self.makeTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }
    let source = try SourceFixtures.video(title: "Explicit")

    try YouTubeContent.write(
      episodes: [source],
      atContentPathURL: directory,
      using: { $0 },
      markdownExtractorType: YouTubeContent.MarkdownExtractor.self,
      frontMatterTranslatorType: YouTubeContent.FrontMatterTranslator.self
    )

    let fileURL = directory.appendingPathComponent("Explicit.md")
    let contents = try String(contentsOf: fileURL, encoding: .utf8)
    let expected = try YouTubeContent.contentBuilder().content(from: source) { $0 }
    #expect(contents == expected)
  }

  /// Without the overwrite option an existing file is left untouched.
  @Test internal func leavesExistingFilesAloneByDefault() throws {
    let directory = try Self.makeTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }
    let original = try SourceFixtures.video(title: "Stable", description: "Original body.")
    let revised = try SourceFixtures.video(title: "Stable", description: "Revised body.")
    let fileURL = directory.appendingPathComponent("Stable.md")

    try YouTubeContent.write(episodes: [original], atContentPathURL: directory, using: { $0 })
    try YouTubeContent.write(episodes: [revised], atContentPathURL: directory, using: { $0 })

    let contents = try String(contentsOf: fileURL, encoding: .utf8)
    #expect(contents.hasSuffix("Original body."))
  }

  /// The overwrite option replaces the previously written content.
  @Test internal func overwritesExistingFilesWhenAsked() throws {
    let directory = try Self.makeTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }
    let original = try SourceFixtures.video(title: "Stable", description: "Original body.")
    let revised = try SourceFixtures.video(title: "Stable", description: "Revised body.")
    let fileURL = directory.appendingPathComponent("Stable.md")

    try YouTubeContent.write(episodes: [original], atContentPathURL: directory, using: { $0 })
    try YouTubeContent.write(
      episodes: [revised],
      atContentPathURL: directory,
      using: { $0 },
      options: .init(shouldOverwriteExisting: true, includeMissingPrevious: true)
    )

    let contents = try String(contentsOf: fileURL, encoding: .utf8)
    #expect(contents.hasSuffix("Revised body."))
  }
}
