---
description: Force-pull the latest Qualimetry review findings for a file (bypass cache).
argument-hint: [file-path]
---

# Compliance: Pull

Force a fresh fetch of review findings for the target file, bypassing any per-session cache the on-Read hook may have populated.

1. Resolve the target file the same way `/compliance-check` does.
2. Delete the cache entry for this file at `$TMPDIR/qualimetry-ai-app-cache/<repo>/<branch>/<file>.json` (if present).
3. Invoke the bundled `review-check` skill on the file (which always hits the MCP; the cache is only used by the on-Read hook).
4. Show the findings as `/compliance-check` would.

Use this when a fresh review has just landed server-side and you want to see the new findings immediately rather than waiting for the cache TTL (30 minutes) to expire.

If the MCP isn't configured, emit the verbatim self-healing message from `/compliance-check`.
