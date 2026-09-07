[CmdletBinding()]
param(
    [string] $Path = '',
    [switch] $SkipRemoteCompile
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Path)) {
    $Path = Join-Path $projectRoot 'src\pine\CCBSN_Controller_Lite_Ver3_M5.pine'
}

$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
$source = Get-Content -LiteralPath $resolvedPath -Raw -Encoding UTF8
$lines = Get-Content -LiteralPath $resolvedPath -Encoding UTF8
$errors = [System.Collections.Generic.List[string]]::new()

function Assert-PinePattern {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $Pattern
    )
    if ($source -notmatch $Pattern) {
        $errors.Add("Missing Pine contract: $Name")
    }
}

if ($lines.Count -eq 0 -or $lines[0] -ne '//@version=6') {
    $errors.Add('Line 1 must be exactly //@version=6.')
}

Assert-PinePattern 'Indicator declaration' '(?m)^indicator\('
Assert-PinePattern 'M5 chart gate' 'timeframe\.isminutes\s+and\s+timeframe\.multiplier\s*==\s*5'
Assert-PinePattern 'Confirmed bars only' 'isM5Chart\s+and\s+barstate\.isconfirmed'
Assert-PinePattern 'ATR20 default' 'atrPeriod\s*=\s*input\.int\(20,'
Assert-PinePattern 'EMA23 default' 'emaPeriod\s*=\s*input\.int\(23,'
Assert-PinePattern 'M5 scale default' 'm5PriceScale\s*=\s*input\.float\(0\.50,'
Assert-PinePattern 'D formula' 'currentD\s*=\s*close\s*-\s*emaValue'
Assert-PinePattern 'Scaled minimum ATR' 'minAtrPrice\s*=\s*3\.0\s*\*\s*m5PriceScale'
Assert-PinePattern 'Scaled upside ceiling' 'upsideMaxAboveEma\s*=\s*upsideMaxBase\s*\*\s*m5PriceScale'
Assert-PinePattern 'Scaled downside ATR' 'downsideMinAtrPrice\s*=\s*downsideMinAtrBase\s*\*\s*m5PriceScale'
Assert-PinePattern 'Scaled downside band' 'downsideBandBoundary\s*=\s*downsideBandBase\s*\*\s*m5PriceScale'
Assert-PinePattern 'Scaled downside hold' 'downsideHoldMaxAboveEma\s*=\s*downsideHoldMaxBase\s*\*\s*m5PriceScale'
Assert-PinePattern 'Scaled Bear Drop PeakD' 'minRelativeDropPrice\s*=\s*minRelativeDropBase\s*\*\s*m5PriceScale'
Assert-PinePattern 'Scaled Bear Drop two-bar' 'minTwoBarDropPrice\s*=\s*minTwoBarDropBase\s*\*\s*m5PriceScale'
Assert-PinePattern 'Upside entry' 'upsideEntryPass[\s\S]*?currentD\s*>=\s*0\.0[\s\S]*?currentD\s*<=\s*upsideMaxAboveEma'
Assert-PinePattern 'Downside near entry' 'currentD\s*<\s*0\.0\s+and[\s\S]*?currentD\s*>\s*-downsideBandBoundary'
Assert-PinePattern 'Downside deep entry' 'currentD\s*<=\s*-downsideBandBoundary'
Assert-PinePattern 'Downside D rising gate' 'not\s+downsideRequireDRising\s+or\s+dRising'
Assert-PinePattern 'Downside hold hysteresis' 'downsideHoldPass[\s\S]*?currentD\s*<=\s*downsideHoldMaxAboveEma'
Assert-PinePattern 'PeakD Bear Drop' 'relativeDrop\s*>=\s*relativeDropMinimum'
Assert-PinePattern 'Two-bar Bear Drop' 'twoBarDrop\s*>=\s*twoBarDropMinimum'
Assert-PinePattern 'Downside Bear Drop multiplier' 'downsideBearDropMultiplier\s*:\s*1\.0'
Assert-PinePattern 'Continuous session default' 'input\.session\("0600-0300"'
Assert-PinePattern 'Decision-time session lookup' 'bars_back\s*=\s*-1'
Assert-PinePattern 'Risk recovery returns to ARMING' 'policyState\s*:=\s*STATE_ARMING'
Assert-PinePattern 'Zone starts at decision time' 'box\.new\(left\s*=\s*time_close'
Assert-PinePattern 'Zone extends to next close' 'nextBarCloseTime\s*=\s*time_close\(timeframe\.period,\s*bars_back\s*=\s*-1\)'
Assert-PinePattern 'Policy allow alert' 'alertcondition\(onEvent'
Assert-PinePattern 'Policy block alert' 'alertcondition\(offEvent'
Assert-PinePattern 'Bear Drop alert' 'alertcondition\(bearDropEvent'
Assert-PinePattern 'Soft event alert' 'alertcondition\(bearTwoEvent'
Assert-PinePattern 'Recovery alert' 'alertcondition\(recoveryEvent'

$softStart = $source.IndexOf('string softBlockCode = ""', [StringComparison]::Ordinal)
$softEnd = $source.IndexOf('bool softBlock =', $softStart, [StringComparison]::Ordinal)
if ($softStart -lt 0 -or $softEnd -lt 0) {
    $errors.Add('Cannot locate Ver3 Soft OFF priority block.')
}
else {
    $softBody = $source.Substring($softStart, $softEnd - $softStart)
    $priorityTokens = @(
        'if bearTwoBlock',
        'else if downsideEmaApproachBlock',
        'else if activeLowAtrBlock',
        'else if denyBlock',
        'else if fallBlock',
        'else if reverseBlock',
        'else if bearishPatternBlock',
        'else if consecutiveRedBlock'
    )
    $previous = -1
    foreach ($token in $priorityTokens) {
        $position = $softBody.IndexOf($token, $previous + 1,
            [StringComparison]::Ordinal)
        if ($position -le $previous) {
            $errors.Add("Missing/out-of-order Soft OFF event: $token")
            break
        }
        $previous = $position
    }
}

$mainStart = $source.IndexOf('if sessionExit', [StringComparison]::Ordinal)
$mainEnd = $source.IndexOf('if barstate.islast', $mainStart,
    [StringComparison]::Ordinal)
if ($mainStart -lt 0 -or $mainEnd -lt 0) {
    $errors.Add('Cannot locate Ver3 state/event priority branch.')
}
else {
    $mainBody = $source.Substring($mainStart, $mainEnd - $mainStart)
    $priorityTokens = @(
        'if sessionExit',
        'else if bearDropVeto',
        'else if softBlock',
        'else if wasRiskLock',
        'else if wasActive',
        'else if candidatePass'
    )
    $previous = -1
    foreach ($token in $priorityTokens) {
        $position = $mainBody.IndexOf($token, $previous + 1,
            [StringComparison]::Ordinal)
        if ($position -le $previous) {
            $errors.Add("Missing/out-of-order state branch: $token")
            break
        }
        $previous = $position
    }
}

foreach ($forbidden in @(
    '(?m)^strategy\s*\(', 'strategy\.', 'request\.', 'alert\s*\(',
    'CCBSN_CTRL:', 'SellLimit', 'BuyStop'
)) {
    if ($source -match $forbidden) {
        $errors.Add("Forbidden Pine capability found: $forbidden")
    }
}

if ($source.Contains("`t")) {
    $errors.Add('Tab characters are not allowed.')
}
for ($index = 0; $index -lt $lines.Count; $index++) {
    if ($lines[$index] -match '[ \t]+$') {
        $errors.Add("Trailing whitespace at line $($index + 1).")
    }
}

if ($errors.Count -gt 0) {
    Write-Host "FAIL: $resolvedPath" -ForegroundColor Red
    foreach ($failure in $errors) {
        Write-Host "  - $failure" -ForegroundColor Red
    }
    exit 1
}

if (-not $SkipRemoteCompile) {
    $compileScript = Join-Path $PSScriptRoot 'Test-PineCompile.mjs'
    & node $compileScript $resolvedPath
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

$sourceHash = (Get-FileHash -LiteralPath $resolvedPath -Algorithm SHA256).Hash
Write-Host "PASS: $resolvedPath" -ForegroundColor Green
Write-Host "  Source lines: $($lines.Count)"
Write-Host '  Pine v6 visual-only M5 contract: PASS'
Write-Host '  Ver3 ATR20/EMA23/scaled-price contract: PASS'
Write-Host '  Ver3 Soft OFF and state priority: PASS'
Write-Host '  Alerts: PASS (ARM, Allow/Block, Bear Drop, Soft OFF, Recovery)'
Write-Host '  Trading/control/network capability: NONE'
Write-Host "  Pine SHA256: $sourceHash"
