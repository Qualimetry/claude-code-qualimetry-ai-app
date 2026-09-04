#!/usr/bin/env bash
# qualimetry-ai-app PostToolUse hook for Read.
# When the agent reads a source file in a git working tree, this hook calls
# get_all_review_issues + get_standards_compliant_example via the configured
# Qualimetry MCP server and emits the findings digest as PostToolUse
# additionalContext JSON on stdout (the only hook output Claude Code adds to
# the model's context on exit 0).
#
# Prerequisites: git plus curl-or-wget only. jq is OPTIONAL - with it the
# digest is grouped per pillar; without it a raw findings payload is emitted.
#
# Credentials: QUALIMETRY_MCP_URL / QUALIMETRY_ACCESS_TOKEN env vars win when
# set; otherwise they are read from the qualimetry entry that /qualimetry-setup
# writes to ~/.claude.json (Claude Code does NOT inject MCP config into hook
# processes). Self-heals silently if neither source yields a URL + token.

set -euo pipefail

# Source the shared MCP-call + digest library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/fetch-review-issues.sh
. "${SCRIPT_DIR}/lib/fetch-review-issues.sh"

# Extract a top-level-ish string field from JSON on stdin without jq.
# Good enough for harness-generated JSON; unescapes \\ and \" and \/.
qualimetry_sed_json_field() {
    # qualimetry_sed_json_field <json> <field>
    printf '%s' "$1" \
        | grep -o "\"$2\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
        | head -1 \
        | sed -e "s/^\"$2\"[[:space:]]*:[[:space:]]*\"//" -e 's/"$//' \
              -e 's/\\\\/\\/g' -e 's/\\\//\//g'
}

# Hook input is a JSON object on stdin with tool_input.file_path
INPUT_JSON="$(cat)"
if qualimetry_have_jq; then
    FILE_PATH="$(printf '%s' "$INPUT_JSON" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"
else
    FILE_PATH="$(qualimetry_sed_json_field "$INPUT_JSON" "file_path" || true)"
fi

# Bail silently if no file path or the file isn't a source file
[ -z "${FILE_PATH:-}" ] && exit 0
case "$FILE_PATH" in
  *.cs|*.ts|*.tsx|*.js|*.jsx|*.py|*.java|*.kt|*.swift|*.rs|*.cpp|*.cc|*.c|*.h|*.hpp|*.go|*.rb|*.php|*.scala) ;;
  *) exit 0 ;;
esac

# Resolve credentials: env vars first, then the MCP entry /qualimetry-setup
# wrote to ~/.claude.json. JSON parser fallback chain keeps jq optional:
# jq -> powershell (always present on Windows) -> python3/python.
qualimetry_claude_cfg() {
    # qualimetry_claude_cfg <config-file> <url|token>
    local cfg="$1" what="$2"
    if qualimetry_have_jq; then
        if [ "$what" = "url" ]; then
            jq -r '.mcpServers.qualimetry.url // empty' "$cfg" 2>/dev/null
        else
            jq -r '.mcpServers.qualimetry.headers["qualimetry-access-token"] // empty' "$cfg" 2>/dev/null
        fi
        return 0
    fi
    if command -v powershell.exe >/dev/null 2>&1; then
        local cfg_win
        cfg_win=$(cygpath -w "$cfg" 2>/dev/null || printf '%s' "$cfg")
        if [ "$what" = "url" ]; then
            powershell.exe -NoProfile -Command "(Get-Content -Raw '$cfg_win' | ConvertFrom-Json).mcpServers.qualimetry.url" 2>/dev/null | tr -d '\r'
        else
            powershell.exe -NoProfile -Command "(Get-Content -Raw '$cfg_win' | ConvertFrom-Json).mcpServers.qualimetry.headers.'qualimetry-access-token'" 2>/dev/null | tr -d '\r'
        fi
        return 0
    fi
    local py
    for py in python3 python; do
        if command -v "$py" >/dev/null 2>&1; then
            if [ "$what" = "url" ]; then
                "$py" -c 'import json,sys; print(json.load(open(sys.argv[1])).get("mcpServers",{}).get("qualimetry",{}).get("url",""))' "$cfg" 2>/dev/null
            else
                "$py" -c 'import json,sys; print(json.load(open(sys.argv[1])).get("mcpServers",{}).get("qualimetry",{}).get("headers",{}).get("qualimetry-access-token",""))' "$cfg" 2>/dev/null
            fi
            return 0
        fi
    done
    return 0
}

if [ -z "${QUALIMETRY_MCP_URL:-}" ] || [ -z "${QUALIMETRY_ACCESS_TOKEN:-}" ]; then
  CLAUDE_CONFIG="${HOME}/.claude.json"
  if [ -f "$CLAUDE_CONFIG" ]; then
    QUALIMETRY_MCP_URL="$(qualimetry_claude_cfg "$CLAUDE_CONFIG" url || true)"
    QUALIMETRY_ACCESS_TOKEN="$(qualimetry_claude_cfg "$CLAUDE_CONFIG" token || true)"
    export QUALIMETRY_MCP_URL QUALIMETRY_ACCESS_TOKEN
  fi
fi

# Skip if we still don't have the URL + token (self-heal silently - slash
# commands emit the verbatim "isn't configured yet" hint when invoked).
if [ -z "${QUALIMETRY_MCP_URL:-}" ] || [ -z "${QUALIMETRY_ACCESS_TOKEN:-}" ]; then
  exit 0
fi

qualimetry_emit_findings_for_file "$FILE_PATH"
exit 0
