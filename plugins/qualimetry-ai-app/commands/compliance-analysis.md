---
description: Triage and clear rules-based analysis issues and security hotspots for the current branch.
argument-hint: (no arguments — operates on the current branch)
---

# Compliance: Analysis

Invoke the bundled `analysis-issues` skill. It calls `get_rules_based_analysis_issues_summary` to show the issue distribution by type (bugs, vulnerabilities, code smells) and severity (BLOCKER, CRITICAL, MAJOR, MINOR, INFO), then walks the user through clearing them in order: security vulnerabilities first, then reliability bugs, then code-quality concerns.

It then works the branch's security hotspots, which the issue tools never return: security-sensitive code that needs a person to decide whether it is safe. Claude reads each hotspot's risk description and fix recommendations, assesses the code and reports back. Marking a hotspot reviewed is a human action in Qualimetry, so the outcome comes back as an assessment, not a status change.

Requires Qualimetry **Enterprise** — if the MCP returns an "Enterprise feature" error, surface that to the user verbatim and stop.

If the MCP isn't configured, emit the verbatim self-healing message:

> Qualimetry isn't configured yet. To finish setup, type the following in the chat input box and press Enter:
>
>     /qualimetry-setup
>
> You'll be asked for your Qualimetry server URL and your access token.
