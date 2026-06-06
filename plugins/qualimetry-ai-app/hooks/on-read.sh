#!/usr/bin/env bash
# qualimetry-ai-app PostToolUse hook for Read.
# When the agent reads a source file in a git working tree, this hook calls
# get_all_review_issues + get_standards_compliant_example via the configured
# Qualimetry MCP server and emits a <system-reminder> with the findings.
#
# Reads its config from the host-injected env vars QUALIMETRY_MCP_URL and
# QUALIMETRY_ACCESS_TOKEN (Claude Code populates these from the user's MCP
# config when the plugin's MCP server is registered). Self-heals silently
# if either is missing or empty.

set -euo pipefail

# Source the shared MCP-call + system-reminder library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/fetch-review-issues.sh
. "${SCRIPT_DIR}/lib/fetch-review-issues.sh"

# Hook input is a JSON object on stdin with tool_input.file_path
INPUT_JSON="$(cat)"
FILE_PATH="$(printf '%s' "$INPUT_JSON" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"

# Bail silently if no file path or the file isn't a source file
[ -z "${FILE_PATH:-}" ] && exit 0
case "$FILE_PATH" in
  *.cs|*.ts|*.tsx|*.js|*.jsx|*.py|*.java|*.kt|*.swift|*.rs|*.cpp|*.cc|*.c|*.h|*.hpp|*.go|*.rb|*.php|*.scala) ;;
  *) exit 0 ;;
esac

# Skip if we don't have the URL + token (self-heal silently — slash commands
# emit the verbatim "isn't configured yet" hint when invoked).
if [ -z "${QUALIMETRY_MCP_URL:-}" ] || [ -z "${QUALIMETRY_ACCESS_TOKEN:-}" ]; then
  exit 0
fi

qualimetry_emit_findings_for_file "$FILE_PATH"
exit 0
