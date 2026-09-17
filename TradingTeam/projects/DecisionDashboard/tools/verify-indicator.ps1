param(
  [string]$IndicatorPath = ""
)

$ErrorActionPreference = "Stop"
$workspaceRoot = Split-Path -Parent $PSScriptRoot
$defaultPath = Join-Path $workspaceRoot "indicators\trading-hub\structure-events-r0.5.pine"
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
  "High confirmation" = "confirmsHigh"
  "Low confirmation" = "confirmsLow"
  "Any-take default" = 'input.string("Any take"'
  "High any-take gate" = 'confirmationMode == "Any take" ? highIdmTaken'
  "Low any-take gate" = 'confirmationMode == "Any take" ? lowIdmTaken'
  "High alert" = "alertcondition(confirmedHighThisBar"
  "Low alert" = "alertcondition(confirmedLowThisBar"
  "IDM break alert" = "alertcondition(idmBrokenThisBar"
  "Buy-side sweep re-entry" = "if close < previousConfirmedHigh"
  "Sell-side sweep re-entry" = "if close > previousConfirmedLow"
  "Active IDM" = "IDM ACTIVE"
  "Important imbalance" = '"IMP-FVG"'
  "Decision POI" = '"D-POI"'
  "Extreme POI" = '"E-POI"'
  "Zone lifecycle update" = "f_updateZones("
  "Extreme validity gate" = "effectiveBullExtreme"
  "First-breach Extreme gate" = "candidateHighSweptReference"
  "Structural sweep origin" = "previousConfirmedHighBar"
  "BSL origin line" = "line.new(previousConfirmedHighBar, previousConfirmedHigh, bar_index"
  "SSL origin line" = "line.new(previousConfirmedLowBar, previousConfirmedLow, bar_index"
  "IDM source line" = "line.new(candidateHighIdmBar, candidateHighIdm, bar_index"
  "Symbol-only event layer" = "Symbol-only event layer"
  "BSL symbol" = 'title = "BSL sweep"'
  "SSL symbol" = 'title = "SSL sweep"'
  "IDM sweep symbol" = 'title = "IDM downside sweep"'
  "Liquidity shape option" = 'input.string("Triangle", "Liquidity sweep"'
  "IDM shape option" = 'input.string("Diamond", "IDM sweep"'
  "Imbalance shape option" = 'input.string("Square", "Imbalance / FVG"'
  "Decision POI shape option" = 'input.string("Circle", "Decision POI"'
  "Extreme POI shape option" = 'input.string("Diamond", "Extreme POI"'
  "Zone bar padding" = 'input.int(1, "POI/FVG start padding (bars)"'
  "Zone ATR padding" = 'input.float(1.0, "POI/FVG symbol padding (ATR)"'
  "FVG starts after pattern" = "imbalanceBar + 2 + zoneStartPaddingBars"
  "Lifecycle respects padding" = "bar_index >= box.get_left(zone)"
  "Research disclosure" = "not every fractal is claimed to be canonical Trading Hub IDM"
}

$forbidden = [ordered]@{
  "Cross-timeframe request" = "request.security("
  "Future lookahead" = "lookahead_on"
  "Tick strategy execution" = "calc_on_every_tick"
  "Legacy event summary text" = "eventText"
  "BSL text label" = 'label.new(bar_index, high, "BSL SWEPT"'
  "SSL text label" = 'label.new(bar_index, low, "SSL SWEPT"'
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
Write-Host "Verified $lineCount lines | sha256:$hash" -ForegroundColor Green
