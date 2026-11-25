---
description: Assess dependency CVEs and suppressions and apply NextSafeVersion upgrades on the current branch.
argument-hint: (no arguments — operates on the current branch)
---

# Compliance: Deps

Invoke the bundled `dependency-check` skill. It walks four phases: assess (call `get_dependency_vulnerabilities` for the current branch), locate manifests in the workspace, resolve (apply each vulnerability's `NextSafeVersion` — auto for low-risk, propose for medium/high), and validate (run package restore + build).

Always upgrade to **`NextSafeVersion`**, not the latest version, to minimise breaking-change risk. The skill handles this - do not override.

The skill is suppression-aware. A CVE whose suppression request is still waiting for approval is reported, not fixed, so no effort goes into risk the organisation is already accepting. An approved suppression that expires within 15 days is flagged before the finding comes back. The CVEs a suppression has already removed from the report can be listed on request, with the scope, requester and reason behind each one. Raising and approving suppressions is a human step in the Qualimetry dashboard.

Requires Qualimetry **Enterprise** — if the MCP returns an "Enterprise feature" error, surface that to the user verbatim and stop.

If the MCP isn't configured, emit the verbatim self-healing message from `/compliance-check`.
