---
description: Assess dependency CVEs and apply NextSafeVersion upgrades on the current branch.
argument-hint: (no arguments — operates on the current branch)
---

# Compliance: Deps

Invoke the bundled `dependency-check` skill. It walks four phases: assess (call `get_dependency_vulnerabilities` for the current branch), locate manifests in the workspace, resolve (apply each vulnerability's `NextSafeVersion` — auto for low-risk, propose for medium/high), and validate (run package restore + build).

Always upgrade to **`NextSafeVersion`**, not the latest version, to minimise breaking-change risk. The skill handles this — do not override.

Requires Qualimetry **Enterprise** — if the MCP returns an "Enterprise feature" error, surface that to the user verbatim and stop.

If the MCP isn't configured, emit the verbatim self-healing message from `/compliance-check`.
