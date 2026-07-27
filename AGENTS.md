# AGENTS.md

This is the canonical agent instruction file for this repository. `CLAUDE.md` is a symlink to it.

## Overview

ContributeYouTube is a Swift library (SPM package, product `ContributeYouTube`) that adapts YouTube
video data into the [Contribute](https://github.com/brightdigit/Contribute) source→Markdown
pipeline. It fetches a playlist's videos through
[SwiftTube](https://github.com/brightdigit/SwiftTube)'s `YouTubeClient`, maps each video onto a
`YouTubeContent.Source` value, and writes Markdown files with YAML front matter into a content
directory. It is consumed as a library; there is no executable target.

The module is a deliberately thin adapter for the `brightdigit.com` import path, and the root
`brightdigit.com` package compiles against it today. It is **not** deprecated — an earlier
blanket `@available(*, deprecated)` annotation on every public symbol was removed because the
module is in active use (and because swift-testing refuses to attach `@Suite`/`@Test` to
deprecated declarations). Do not reintroduce it. Keep the module narrow: anything beyond
"playlist in, markdown out" belongs in `Contribute` or `SwiftTube`.

## Commands

Builds with the **Swift 6.4 toolchain** (`.swift-version` → `6.4.x-snapshot`; tools-version 6.4,
Swift 6 language mode). Use the matching snapshot / `Xcode-beta` toolchain locally.

- Build: `swift build`
- Build incl. tests: `swift build --build-tests`
- Run tests: `swift test`
- Run one test: `swift test --filter ContributeYouTubeTests`

### Linting

Lint tooling is pinned via **mise** (`.mise.toml`). The canonical entry point is `Scripts/lint.sh`,
which bootstraps tools with `mise install` then runs swift-format, SwiftLint, and a build check
(periphery and the `Scripts/header.sh` license-header rewrite run locally only).

- Full lint + autofix (local): `Scripts/lint.sh`
- Format only: `FORMAT_ONLY=1 Scripts/lint.sh`
- CI/strict mode (no autofix, fails on warnings): `LINT_MODE=STRICT CI=1 Scripts/lint.sh`

`Scripts/lint.sh` passes `-p "ContributeYouTube"` to `Scripts/header.sh`. If you sync the script
from a sibling package, **preserve that argument** — copying another package's copy verbatim
rewrites the wrong package name into every source header.

Every file under `Sources/ContributeYouTube/` currently carries `// swift-format-ignore-file` and
`// swiftlint:disable all` pragmas inherited from the pre-split monorepo. Keep them unless you are
deliberately bringing a file up to the shared style rules.

## Architecture

`Sources/ContributeYouTube/` is small and organized around Contribute's protocol trio:

- `YouTubeContent.swift` — the `ContentType` binding. `videos(byRequest:)` is the async entry
  point: it constructs a `SwiftTube.YouTubeClient` from the request's API key, fetches the
  playlist's videos, and maps each into a `Source`, throwing `YoutubeError.missingFieldForVideo`
  for any absent required field. `videoDurations(_:)` folds `[Source]` into a title-keyed
  `VideoDurations` dictionary, throwing `YoutubeError.duplicateTitle` on conflicting duplicates.
- `Source.swift` — `YouTubeContent.Source`, the decoded per-video model (title, description,
  youtubeID, duration, date, imageURL) plus the `VideoDurations` typealias.
- `FrontMatterTranslator.swift` — maps a `Source` onto the `Codable` front matter emitted into
  each markdown file (`title`, `date`, `featuredImage`, `youtubeID`, `videoDuration`).
- `MarkdownExtractor.swift` — returns the video description verbatim as the markdown body; the
  injected HTML→markdown closure is intentionally unused.
- `YouTubeContent+Write.swift` — four `write(episodes:…)` overloads that default the extractor
  and/or translator types before delegating to Contribute's generic `write(from:…)`.
- `YouTubePlaylistRequest.swift` — the API key + playlist ID pair passed to `videos(byRequest:)`.
- `YoutubeError.swift` — `ContributeError` conformance with the `VideoField` enum.
- `Extensions/TimeInterval.swift` — parses YouTube's ISO-8601 `PT#H#M#S` duration strings.

Code is `#if canImport(FoundationNetworking)`-guarded for non-Apple platforms — preserve those
guards.

## Dependencies

Two first-party packages, both currently pinned to `main` branches while the release checkpoint is
open:

- `brightdigit/Contribute` — the generic source→Markdown pipeline (protocols, YAML front-matter
  exporter, file writing).
- `brightdigit/SwiftTube` — the YouTube Data API v3 client (`YouTubeClient`).

Platform floors: macOS 15 (matches the root/Publish stack's use of `Synchronization.Mutex`);
iOS 16 / tvOS 16 / watchOS 9 match SwiftTube.

## Conventions

**Strict concurrency is mandatory.** The package is Swift 6 language mode with complete strict
concurrency checking. When a strict-concurrency error surfaces, fix it properly (add
`Sendable`/`@Sendable`, isolate with actors/`@MainActor`, restructure ownership) — never lower the
language mode, relax the setting, or silence the diagnostic to make it build.

## CI

A single primary workflow, `.github/workflows/ContributeYouTube.yml` (the shared BrightDigit
template). Its filename must exactly match the package name — the README's Actions badge URL
embeds it. It builds on Ubuntu (nightly-6.4 container), GitHub-hosted macOS with Xcode 27 plus the
Apple platform simulators (iOS, tvOS, watchOS, visionOS), Windows, and Android; a separate lint job
runs `LINT_MODE=STRICT`. Matrix scope tiers up by ref: a small set always, the full matrix plus
Windows on `main`, semver tags, dispatch, and PRs into `main`. Skip CI with `ci skip` in the commit
message.

Auxiliary workflows: `check-unsafe-flags.yml`, `claude-code-review.yml`, `claude.yml`,
`cleanup-caches.yml`, `swift-source-compat.yml`.

## Memory & Corrections Convention

`.claude/agent-notes.md` is the canonical, versioned corrections log for this repository — an
append-only record of the maintainer's corrections and standing **always/never** directives.

- **Read `.claude/agent-notes.md` at the start of every work session, before doing any work.** It
  is the source of truth for *how* to work in this repo.
- **Whenever the maintainer makes a correction or gives an always/never instruction, append one
  line to `.claude/agent-notes.md` proactively (without being asked).** One line per directive,
  newest at the bottom. If a directive supersedes an earlier one, update or remove the stale line
  rather than leaving both.
