param(
  [string]$IndicatorPath = ""
)

$ErrorActionPreference = "Stop"
$workspaceRoot = Split-Path -Parent $PSScriptRoot
$defaultPath = Join-Path $workspaceRoot "indicators\trading-hub\swing-structure-r0.1.pine"
$targetPath = if ($IndicatorPath) { $IndicatorPath } else { $defaultPath }
$resolvedPath = (Resolve-Path -LiteralPath $targetPath).Path

if (-not $resolvedPath.StartsWith($workspaceRoot + [IO.Path]::DirectorySeparatorChar)) {
  throw "Indicator path must stay inside this workspace: $resolvedPath"
}

$source = Get-Content -LiteralPath $resolvedPath -Raw -Encoding UTF8
$required = [ordered]@{
  "Pine v6" = "//@version=6"
  "Overlay indicator" = "overlay = true"
  "Closed-bar gate" = "if barstate.isconfirmed"
  "High IDM ordering" = "candidateHighIdmBar < candidateHighBar"
  "Low IDM ordering" = "candidateLowIdmBar < candidateLowBar"
  "High confirmation" = "sweptHighIdm"
  "Low confirmation" = "sweptLowIdm"
  "High alert" = "alertcondition(confirmedHighThisBar"
  "Low alert" = "alertcondition(confirmedLowThisBar"
  "Research disclosure" = "not a claim that every fractal is a canonical Trading Hub IDM"
}

$forbidden = [ordered]@{
  "Cross-timeframe request" = "request.security("
  "Future lookahead" = "lookahead_on"
  "Tick strategy execution" = "calc_on_every_tick"
}

$failed = $false
foreach ($entry in $required.GetEnumerator()) {
  if ($source.Contains($entry.Value)) {
    Write-Host "[PASS] $($entry.Key)"
  } else {
    Write-Host "[FAIL] $($entry.Key): missing '$($entry.Value)'" -ForegroundColor Red
    $failed = $true
  }
}

foreach ($entry in $forbidden.GetEnumerator()) {
  if ($source.Contains($entry.Value)) {
    Write-Host "[FAIL] $($entry.Key): found '$($entry.Value)'" -ForegroundColor Red
    $failed = $true
  } else {
    Write-Host "[PASS] No $($entry.Key)"
  }
}

if ($failed) {
  exit 1
}

$hash = (Get-FileHash -LiteralPath $resolvedPath -Algorithm SHA256).Hash.ToLowerInvariant()
$lineCount = ($source -split "`n").Count
Write-Host "Verified $lineCount lines · sha256:$hash" -ForegroundColor Green
