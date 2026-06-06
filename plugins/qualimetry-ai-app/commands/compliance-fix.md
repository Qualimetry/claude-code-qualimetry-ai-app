---
description: Show Qualimetry review findings for a file and apply the standards-compliant fix.
argument-hint: [file-path]
---

# Compliance: Fix

Same as `/compliance-check`, then apply the fix.

1. Resolve the target file the same way `/compliance-check` does (`$ARGUMENTS`, or the current file, or ask).
2. Invoke the bundled `review-check` skill against the file. Capture the violations and the standards-compliant example returned by `get_standards_compliant_example`.
3. **Read the file's current contents** before changing anything. Apply the corrections from the compliant example, preserving any user-authored content the violations don't touch. Group changes logically (one Edit per related cluster of violations) so the diff is reviewable.
4. After applying, re-invoke `review-check` to confirm the violations are resolved. If new violations appear (rare — usually means the fix introduced a new issue), surface them and stop; do not loop.
5. End with a one-line summary: `Resolved <N> violations across <pillars>. Re-run /compliance-check to confirm.`

If the MCP isn't configured, emit the verbatim self-healing message from `/compliance-check`.

Do not commit or push. The user owns the diff.
