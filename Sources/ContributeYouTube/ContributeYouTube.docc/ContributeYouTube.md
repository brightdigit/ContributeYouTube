# ``ContributeYouTube``

Turn a YouTube playlist into Markdown files with YAML front matter.

## Overview

`ContributeYouTube` is the YouTube adapter for the
[Contribute](https://github.com/brightdigit/Contribute) pipeline. Contribute defines a
source-agnostic shape — a front-matter translator, a markdown extractor, and a `ContentType` that
binds both to one source model — but it deliberately never fetches anything. This package supplies
the missing YouTube half.

Fetching goes through [SwiftTube](https://github.com/brightdigit/SwiftTube)'s `YouTubeClient`.
``YouTubeContent/videos(byRequest:)`` takes a ``YouTubePlaylistRequest`` (an API key and a playlist
ID), asks the client for every video in the playlist, and maps each one onto a
``YouTubeContent/Source`` — title, description, video ID, duration, publish date, and thumbnail
URL. YouTube's ISO-8601 `PT#H#M#S` duration strings are parsed into `TimeInterval`. Any video
missing a required field raises ``YoutubeError/missingFieldForVideo(_:_:)`` rather than being
silently dropped.

From there the Contribute pipeline takes over. ``YouTubeContent`` conforms to `ContentType`, wiring
``YouTubeContent/Source`` to ``YouTubeContent/FrontMatterTranslator`` (which emits `title`, `date`,
`featuredImage`, `youtubeID`, and `videoDuration`) and ``YouTubeContent/MarkdownExtractor`` (which
uses the video description as the markdown body). The `write(episodes:atContentPathURL:…)`
overloads render one file per video into a content directory, ready for a static-site generator.

```swift
import ContributeYouTube

let request = YouTubePlaylistRequest(apiKey: apiKey, playlistID: playlistID)
let videos = try await YouTubeContent.videos(byRequest: request)

try YouTubeContent.write(
  episodes: videos,
  atContentPathURL: URL(fileURLWithPath: "Content/episodes"),
  using: htmlToMarkdown
)
```

``YouTubeContent/videoDurations(_:)`` is a convenience for callers that need a title-keyed lookup
of the fetched videos; conflicting entries that share a title raise
``YoutubeError/duplicateTitle(_:forVideos:)``.

> Note: This module is a deliberately thin adapter serving the `brightdigit.com` import path.
> It is actively used and supported; functionality beyond "playlist in, markdown out" belongs
> in `Contribute` or `SwiftTube`.

## Topics

### Content Pipeline

- ``YouTubeContent``
- ``VideoDurations``

### Requests

- ``YouTubePlaylistRequest``

### Errors

- ``YoutubeError``
