![ContributeYouTube Logo](Sources/ContributeYouTube/ContributeYouTube.docc/Resources/ContributeYouTubeLogo.svg)

# ContributeYouTube


[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FContributeYouTube%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/ContributeYouTube)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FContributeYouTube%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/ContributeYouTube)
[![Documentation](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/ContributeYouTube/documentation)
[![License](https://img.shields.io/github/license/brightdigit/ContributeYouTube)](LICENSE)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/ContributeYouTube/ContributeYouTube.yml?label=actions&logo=github&branch=main)](https://github.com/brightdigit/ContributeYouTube/actions)
[![Maintainability](https://qlty.sh/gh/brightdigit/projects/ContributeYouTube/maintainability.svg)](https://qlty.sh/gh/brightdigit/projects/ContributeYouTube)
[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/ContributeYouTube)](https://codecov.io/gh/brightdigit/ContributeYouTube)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/ContributeYouTube)](https://www.codefactor.io/repository/github/brightdigit/ContributeYouTube)

Create content for your site from YouTube videos.

---

## What is ContributeYouTube?

[Contribute](https://github.com/brightdigit/Contribute) turns source items into markdown files with
YAML front matter — but by design it never fetches anything. You bring the already-decoded models;
Contribute's job starts at *source model → markdown file*.

**ContributeYouTube supplies the YouTube half of that seam.** It fetches every video in a playlist
through [SwiftTube](https://github.com/brightdigit/SwiftTube)'s `YouTubeClient`, maps each one onto
a source model, and hands it to Contribute's pipeline — so a channel's back catalog becomes a
directory of markdown files your static-site generator can render.

`brightdigit.com` uses it to import the [Empower Apps](https://brightdigit.com/podcast) episode
videos into a Swift static site generator.

> **Scope.** This module is a thin adapter for `brightdigit.com`'s import path. It is actively
> used and supported, but it is deliberately narrow — anything beyond "playlist in, markdown out"
> belongs in `Contribute` or `SwiftTube`.

## Installation

Add ContributeYouTube to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/brightdigit/ContributeYouTube.git", branch: "main")
]
```

Then add it to a target:

```swift
.target(
  name: "MySite",
  dependencies: [.product(name: "ContributeYouTube", package: "ContributeYouTube")]
)
```

## Usage

Two steps: fetch, then write.

```swift
import Contribute
import ContributeYouTube
import Foundation

// 1. Fetch. A request is just an API key plus a playlist ID.
let request = YouTubePlaylistRequest(
  apiKey: ProcessInfo.processInfo.environment["YOUTUBE_API_KEY"]!,
  playlistID: "PLxxxxxxxxxxxxxxxxxxxx"
)

let videos = try await YouTubeContent.videos(byRequest: request)

// 2. Write one markdown file per video.
let htmlToMarkdown = SwiftSoupMarkdownGenerator().markdown(fromHTML:)

try YouTubeContent.write(
  episodes: videos,
  atContentPathURL: URL(fileURLWithPath: "Content/episodes"),
  using: htmlToMarkdown
)
```

Each file gets front matter derived from the video, followed by the video's description as the
markdown body:

```markdown
---
title: My Episode Title
date: 2026-06-29T12:00:00Z
featuredImage: https://i.ytimg.com/vi/VIDEOID/sddefault.jpg
youtubeID: VIDEOID
videoDuration: 3125
---

The video description, used verbatim as the body.
```

### What's in the box

- **`YouTubeContent`** — the `ContentType` binding. `videos(byRequest:)` fetches and decodes;
  the `write(episodes:atContentPathURL:…)` overloads let you substitute your own
  `MarkdownExtractor` and/or `FrontMatterTranslator` while defaulting the other.
- **`YouTubeContent.Source`** — the decoded per-video model: title, description, `youtubeID`,
  duration, publish date, and thumbnail URL. YouTube's ISO-8601 `PT#H#M#S` durations are parsed
  into `TimeInterval`.
- **`YouTubeContent.FrontMatterTranslator`** — emits `title`, `date`, `featuredImage`,
  `youtubeID`, and `videoDuration`. Swap in your own for a different front-matter schema.
- **`YouTubeContent.MarkdownExtractor`** — uses the video description as the body.
- **`YouTubeContent.videoDurations(_:)`** — folds `[Source]` into a title-keyed `VideoDurations`
  dictionary, throwing on conflicting duplicate titles.
- **`YoutubeError`** — a `ContributeError` raised when a video is missing a required field
  (`missingFieldForVideo`) or two distinct videos share a title (`duplicateTitle`). Nothing is
  silently dropped.

## Requirements

- Swift 6.4
- macOS 15+, iOS 16+, tvOS 16+, watchOS 9+
- Ubuntu 24.04 (Noble) and other current Linux distributions
- A [YouTube Data API v3](https://developers.google.com/youtube/v3/getting-started) key

## License

[MIT](LICENSE) © BrightDigit
