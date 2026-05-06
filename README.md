# Qualimetry AI App for Claude Code

Catches policy violations *before* code review, not during. The Qualimetry AI App keeps every line of code Claude writes — and every reviewed file you touch — aligned with your organisation's coding standards, principles, and policies, automatically.

## What it does

- **Surfaces review findings the moment you open a reviewed file.** Read any source file in your repo and Claude immediately shows you which standards, principles, and policy violations have been raised against it, plus a standards-compliant example of how to resolve them. No command, no manual lookup.
- **Keeps Claude's own code compliant from the first line.** When Claude writes or modifies code, it silently fetches your organisation's coding standards, general coding principles, secure coding principles, and policies for the file's language, and applies them as it types. High-severity violations are corrected before the code is even shown to you.
- **Triages rules-based analysis findings.** Existing bugs, security vulnerabilities, and code smells from your static analysis (Sonar-style: BLOCKER / CRITICAL / MAJOR / MINOR / INFO) are accessible from chat. Claude walks them in priority order: security first, reliability second, quality last. *(Qualimetry Enterprise.)*
- **Resolves dependency CVEs by upgrading to the next safe version.** Claude pulls the CVE list for your current branch, locates the manifest files, and proposes upgrades to the `NextSafeVersion` for each vulnerable package — auto-applying low-risk upgrades and asking before medium/high-risk ones, then re-validating with a build. *(Qualimetry Enterprise.)*
- **Branded slash commands so the workflow is discoverable.** `/compliance-check`, `/compliance-fix`, `/compliance-pull`, `/compliance-analysis`, `/compliance-deps` cover the manual entry points; the on-Read hook covers the automatic ones.

## Benefits

- Catch policy + standards violations *during authoring* and *before review*, not after.
- AI-written code is compliant by construction — no separate "lint pass" needed.
- One install, one setup, no further configuration per repo.
- Review feedback appears at the moment of context (when you open the file), not buried in a code-review tool you have to switch to.
- Standards live on your Qualimetry server; updating a policy there flows through to every developer's next edit, with no app release.

## Quick Start

1. Open Claude Code.

2. Click in the chat input box at the bottom of the window.

3. Type the following text exactly and press Enter to register the marketplace:

       /plugin marketplace add github:Qualimetry/claude-code-qualimetry-ai-app

4. Type the following text exactly and press Enter to install the plugin:

       /plugin install qualimetry-ai-app@qualimetry-ai

5. Type the following text exactly and press Enter to start setup:

       /qualimetry-setup

6. Claude will ask **"What is your Qualimetry server URL?"** Type your URL — for example `https://myorg.qualimetry.io/mcp/` — and press Enter. (If you press Enter without typing anything, the default `https://myorg.qualimetry.io/mcp/` is used.)

7. Claude will then ask **"Paste your Qualimetry access token."** Paste your token and press Enter. The text is visible in the chat — clear the chat afterwards if you want to keep it private.

8. Wait for the message:

       ✓ Qualimetry configured. You can now /compliance-check, /compliance-fix, or just open a reviewed file and Qualimetry will surface any open issues automatically.

That's it. From the next time Claude reads a source file in any of your repos, you'll see Qualimetry findings appear in the chat automatically.

## Re-running setup or switching server

Re-run `/qualimetry-setup` any time to update the URL or token. The new values overwrite the old ones in `~/.claude.json` (Claude Code's MCP-server store).

## Where credentials live

The Qualimetry server URL and access token are stored in `~/.claude.json` under `mcpServers.qualimetry` — the same file Claude Code uses for every MCP server you have registered (GitHub MCP, Linear MCP, etc.). They are not duplicated to any other Qualimetry-specific file.

## Troubleshooting

**"isn't configured yet" message** — you skipped or never ran `/qualimetry-setup`. Run it now.

**Auth failures after setup** — your token may be expired or the server URL is wrong. Re-run `/qualimetry-setup` with the corrected values.

**`claude mcp list` doesn't show qualimetry** — restart Claude Code; the MCP entry is read at launch.

**Issues do not appear when you open a file** — the file may not have been reviewed yet on the Qualimetry server, or the file's repository name differs from the git-root basename. Run `/compliance-check <file>` manually to confirm whether the server has findings for that path.

## License

Apache 2.0. See [LICENSE](LICENSE).

---

*Built on the [Qualimetry AI Skills](https://github.com/Qualimetry/qualimetry-ai-skills) workflow library.*
