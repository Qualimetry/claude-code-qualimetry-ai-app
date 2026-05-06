# qualimetry-ai-app PostToolUse hook for Read (Windows / PowerShell variant).
# Mirrors on-read.sh: calls get_all_review_issues + get_standards_compliant_example
# via the configured Qualimetry MCP server and emits a <system-reminder> with
# the findings.
#
# Reads its config from $env:QUALIMETRY_MCP_URL and $env:QUALIMETRY_ACCESS_TOKEN
# (Claude Code populates these from the user's MCP config when the plugin's
# MCP server is registered). Self-heals silently if either is missing.

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

# Self-heal silently if URL or token missing
if (-not $env:QUALIMETRY_MCP_URL -or -not $env:QUALIMETRY_ACCESS_TOKEN) { exit 0 }

Qualimetry-EmitFindingsForFile -FilePath $FilePath
exit 0
