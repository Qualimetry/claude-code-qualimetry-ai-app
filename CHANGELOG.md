# Changelog - Qualimetry AI App for Claude Code

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
