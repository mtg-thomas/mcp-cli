param(
  [string]$SkillsRoot = $(if ($env:CODEX_HOME) { Join-Path $env:CODEX_HOME "skills" } else { Join-Path $HOME ".codex\skills" }),
  [string]$SkillName = "mcp-cli"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot "SKILL.md"
$targetDir = Join-Path $SkillsRoot $SkillName
$target = Join-Path $targetDir "SKILL.md"

if (-not (Test-Path -LiteralPath $source)) {
  throw "Cannot find source skill: $source"
}

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
Copy-Item -LiteralPath $source -Destination $target -Force

Write-Output "Installed mcp-cli skill to $target"
