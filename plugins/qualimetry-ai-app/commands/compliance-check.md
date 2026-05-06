---
description: Show open Qualimetry review findings for a file (or the current file).
argument-hint: [file-path]
---

# Compliance: Check

Run the bundled `review-check` skill on the target file.

- If the user passed a `$ARGUMENTS` value, treat it as the path of the file to check.
- If not, infer "the current file" from the most recent file the agent has read or edited in this session, or ask the user which file to check if it cannot be inferred.

Then invoke the `review-check` skill with that file path. The skill calls `get_all_review_issues` (with per-pillar fallbacks) and `get_standards_compliant_example`, and presents findings grouped by pillar (Coding Standards, Design & Best Practice, General Principles, Secure Principles, Policies) and severity (High → Medium → Low).

If the Qualimetry MCP server is not configured (auth failure or unreachable), surface the verbatim message:

> Qualimetry isn't configured yet. To finish setup, type the following in the chat input box and press Enter:
>
>     /qualimetry-setup
>
> You'll be asked for your Qualimetry server URL and your access token.

Do not attempt to fix issues in this command — that is what `/compliance-fix` is for.
