# Changelog - Qualimetry AI App for Claude Code

## [1.1.2] - 2026-06-11

### Changed

- Bundled skills updated for the renamed `get_coding_standards_blitzy` MCP tool (formerly `get_language_coding_standards_blitzy`). The Blitzy coding-standards pack now carries a top-level `license` notice, and language coding standards are returned only when `languageCodes` are supplied — omit them to receive policies and principles only.

## [1.1.1] - 2026-06-06

### Added

- Pull-request-scoped issue retrieval. The on-Read hook resolves the current branch's pull request using **standard git only** — `git ls-remote` against the host's PR refs (GitHub, GitLab, Bitbucket Server), no `gh`/`az` CLI required — and passes `pullRequest` to `get_all_review_issues`, so findings are scoped to the PR's new code. Resolution runs only on a cache miss. The bundled `analysis-issues` and `review-check` skills document the optional `pullRequest` parameter and the git-only resolution.

## [1.0.1] - 2026-05-06

### Changed

- Homepage URL switched from qualimetry.com to qualimetry.ai across every manifest, README, and the GitHub repo About sidebar.

## [1.0.0] - 2026-05-05

### Added

- Initial release.
- Marketplace catalog at `.claude-plugin/marketplace.json` for `/plugin marketplace add github:Qualimetry/claude-code-qualimetry-ai-app`.
- Plugin `qualimetry-ai-app` bundling all four [Qualimetry AI Skills](https://github.com/Qualimetry/qualimetry-ai-skills): `coding-standards`, `review-check`, `analysis-issues`, `dependency-check`.
- `/qualimetry-setup` slash command that captures the Qualimetry server URL + access token and writes them to `~/.claude.json` via `claude mcp add`.
- `/compliance-check`, `/compliance-fix`, `/compliance-pull`, `/compliance-analysis`, `/compliance-deps` slash commands as branded entry points to the four bundled skills.
- `compliance-reviewer` subagent that runs the four-pillar review on a diff (delegates to the `review-check` and `coding-standards` skills).
- `PostToolUse` hook on `Read` that fetches `get_all_review_issues` + `get_standards_compliant_example` from the Qualimetry MCP and emits a `<system-reminder>` digest the moment a reviewed file is opened.
- 30-minute per-session cache keyed on `(repo, branch, file)` to avoid re-fetching on repeated reads.
- Self-healing path: any compliance command or hook that runs without a configured MCP emits a verbatim "isn't configured yet" hint pointing at `/qualimetry-setup`.
