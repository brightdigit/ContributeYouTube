# Release Notes

## Unreleased

Wave 1 split-off (brightdigit/ContributeYouTube #1, head `brightdigit-com-260717`) — the
`ContributeYouTube` module was extracted from the `brightdigit.com` monorepo into its own
package via `git subrepo push`, then brought up to the shared BrightDigit package standard.

### Library

- Initial package content: `YouTubeContent` (the `Contribute` `ContentType` binding, with the
  async `videos(byRequest:)` playlist fetch built on SwiftTube's `YouTubeClient`),
  `YouTubeContent.Source`, `FrontMatterTranslator`, `MarkdownExtractor`, the
  `write(episodes:…)` overloads, `YouTubePlaylistRequest`, `YoutubeError`, and the ISO-8601
  duration parser in `Extensions/TimeInterval.swift`.
- No deprecation annotations: an interim blanket
  `@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")` on all
  ten public symbols was removed. The root `brightdigit.com` package imports and compiles
  against this module today, so the deprecation was inaccurate, and it prevented swift-testing
  from attaching `@Suite`/`@Test` to anything that touches these APIs.
- `Package.swift` moves to tools-version 6.4 with Swift 6 language mode, platform floors of
  macOS 15 / iOS 16 / tvOS 16 / watchOS 9, and remote branch pins for the `Contribute` and
  `SwiftTube` dependencies (previously in-repo `path:` references).
- Added a DocC catalog at `Sources/ContributeYouTube/ContributeYouTube.docc` with a written
  landing page and a placeholder logo resource.

### Tests

- Added the `ContributeYouTubeTests` target with five swift-testing suites (27 tests, several
  parameterized): the ISO-8601 duration parser in `Extensions/TimeInterval.swift`,
  `FrontMatterTranslator` field mapping and date formatting, `MarkdownExtractor` pass-through
  behaviour, `videoDurations(_:)` title keying and `YoutubeError.duplicateTitle`, and the
  `write(episodes:…)` overloads writing real markdown into a temporary directory.

### CI

- Added the standard BrightDigit workflow set: `ContributeYouTube.yml` (Ubuntu, macOS, Apple
  platform simulators, Windows, Android, lint) plus `check-unsafe-flags.yml`,
  `claude-code-review.yml`, `claude.yml`, `cleanup-caches.yml`, and `swift-source-compat.yml`,
  and the reusable `.github/actions/setup-tools` composite action.
- `fail-fast: true` on all four matrix legs.
- Ubuntu coverage now uses `sersoft-gmbh/swift-coverage-action@v5` instead of the SHA-pinned
  `brightdigit/swift-coverage-action`, dropping `fail-on-empty-output`.
- Codecov upload steps drop `verbose: true`.
- `build-macos-platforms` adds the visionOS simulator row and removes the `ENABLE_WATCHOS`
  step gate, so watchOS builds unconditionally.
- Devcontainer image moved to `swiftlang/swift:nightly-6.4.x-noble`.
- Added `.github/dependabot.yml` and `codecov.yml`.
- Added lint tooling: `.mise.toml`, `.periphery.yml`, `.swift-format`, `.swiftlint.yml`,
  `Scripts/lint.sh`, and `Scripts/header.sh`, aligned with the shared configuration.
- `.spi.yml` documentation build pinned to Swift 6.4.
- Agent tooling: `AGENTS.md` is now the canonical instruction file (`CLAUDE.md` is a symlink to
  it), alongside `.claude/agent-notes.md` and the shared `.claude/skills/` set.
