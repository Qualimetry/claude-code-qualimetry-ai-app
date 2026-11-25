# qualimetry-ai-app PostToolUse hook for Read (Windows / PowerShell variant).
# Mirrors on-read.sh: calls get_all_review_issues + get_standards_compliant_example
# via the configured Qualimetry MCP server and emits the findings digest as
# PostToolUse additionalContext JSON on stdout (the only hook output Claude
# Code adds to the model's context on exit 0).
#
# Credentials: $env:QUALIMETRY_MCP_URL / $env:QUALIMETRY_ACCESS_TOKEN win when
# set; otherwise they are read from the qualimetry entry that /qualimetry-setup
# writes to ~/.claude.json (Claude Code does NOT inject MCP config into hook
# processes). Self-heals silently if neither source yields a URL + token.

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'lib/fetch-review-issues.ps1')

# Hook input is a JSON object on stdin with tool_input.file_path
$InputJson = [Console]::In.ReadToEnd()
if (-not $InputJson) { exit 0 }

try {
    $Parsed = $InputJson | ConvertFrom-Json
    $FilePath = $Parsed.tool_input.file_path
} catch {
    exit 0
}

if (-not $FilePath) { exit 0 }

# Bail silently for non-source files
$Ext = [System.IO.Path]::GetExtension($FilePath).ToLowerInvariant()
$Sources = @('.cs','.ts','.tsx','.js','.jsx','.py','.java','.kt','.swift','.rs','.cpp','.cc','.c','.h','.hpp','.go','.rb','.php','.scala')
if ($Sources -notcontains $Ext) { exit 0 }

# Resolve credentials: env vars first, then the MCP entry /qualimetry-setup
# wrote to ~/.claude.json.
if (-not $env:QUALIMETRY_MCP_URL -or -not $env:QUALIMETRY_ACCESS_TOKEN) {
    $claudeConfig = Join-Path $env:USERPROFILE '.claude.json'
    if (Test-Path $claudeConfig) {
        try {
            $cfg = Get-Content -Raw -Path $claudeConfig | ConvertFrom-Json
            $entry = $cfg.mcpServers.qualimetry
            if ($entry -and $entry.url) { $env:QUALIMETRY_MCP_URL = $entry.url }
            $token = $entry.headers.'qualimetry-access-token'
            if ($token) { $env:QUALIMETRY_ACCESS_TOKEN = $token }
        } catch {}
    }
}

# Self-heal silently if URL or token still missing
if (-not $env:QUALIMETRY_MCP_URL -or -not $env:QUALIMETRY_ACCESS_TOKEN) { exit 0 }

Qualimetry-EmitFindingsForFile -FilePath $FilePath
exit 0
