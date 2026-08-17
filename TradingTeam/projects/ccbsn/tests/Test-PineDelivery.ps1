param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [string]$Mt5Path = '',

    [switch]$SkipRemoteCompile
)

$ErrorActionPreference = 'Stop'
$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
$source = [System.IO.File]::ReadAllText($resolvedPath)
$lines = [System.IO.File]::ReadAllLines($resolvedPath)
$errors = [System.Collections.Generic.List[string]]::new()

if ([string]::IsNullOrWhiteSpace($Mt5Path)) {
    $Mt5Path = Join-Path $PSScriptRoot '..\src\mt5\v2\CCBSN_Trading_Zone_Controller_v2.mq5'
}
$resolvedMt5Path = (Resolve-Path -LiteralPath $Mt5Path).Path
$mt5Source = [System.IO.File]::ReadAllText($resolvedMt5Path)

if ($lines.Count -eq 0 -or $lines[0] -ne '//@version=6') {
    $errors.Add('Line 1 must be exactly //@version=6.')
}

if ($source -notmatch '(?m)^indicator\s*\(') {
    $errors.Add('Missing indicator() declaration.')
}

$boxCreateCount = [regex]::Matches($source, 'box\.new\s*\(').Count
$currentBarBoxCount = [regex]::Matches(
    $source,
    'box\.new\(\s*left\s*=\s*time\s*,[\s\S]*?\bright\s*=\s*time_close\s*,[\s\S]*?\bxloc\s*=\s*xloc\.bar_time'
).Count
$decisionBarBoxCount = [regex]::Matches(
    $source,
    'box\.new\(\s*left\s*=\s*time_close\s*,[\s\S]*?\bright\s*=\s*nextBarCloseTime\s*,[\s\S]*?\bxloc\s*=\s*xloc\.bar_time'
).Count
if ($boxCreateCount -ne ($currentBarBoxCount + $decisionBarBoxCount)) {
    $errors.Add("Box anchors must use actual M15 candle timestamps ($($currentBarBoxCount + $decisionBarBoxCount)/$boxCreateCount valid).")
}

if ($source -notmatch 'nextBarCloseTime\s*=\s*time_close\(timeframe\.period,\s*bars_back\s*=\s*-1\)') {
    $errors.Add('Missing future M15 close lookup for the MT5 decision candle.')
}

if ($source -match 'nextBarCloseTime\s*:=\s*time_close\s*\+') {
    $errors.Add('Synthetic future close fallback is forbidden for zone anchoring.')
}

if ($source -notmatch 'label\.new\(x\s*=\s*time_close\s*,') {
    $errors.Add('Event labels must use x=time_close to match MT5 decisionTime.')
}

if ($source -notmatch 'tradingZoneHistoryBars\s*=\s*input\.int\(1500,[\s\S]*?maxval\s*=\s*100000') {
    $errors.Add('Trading Zone history maximum must be 100000 bars.')
}

if ($source -notmatch 'maxStoredTradingZones\s*=\s*input\.int\(100,[\s\S]*?maxval\s*=\s*500') {
    $errors.Add('Maximum stored Trading Zones must allow the Pine limit of 500.')
}

if ($source -notmatch 'MAX_ZONE_BOX_OBJECTS\s*=\s*500' -or
    $source -notmatch 'f_deleteOldestZoneBox\(\)' -or
    $source -notmatch 'f_prepareTradingBox\(\)' -or
    $source -notmatch 'f_prepareRiskBox\(\)') {
    $errors.Add('Missing shared 500-box quota protection.')
}

if ($source -notmatch 'activeZoneHigh\s*:=\s*close' -or
    $source -notmatch 'activeZoneLow\s*:=\s*close') {
    $errors.Add('Trading Zone activation must start from the signal close, matching MT5.')
}

$priorityTokens = @(
    'if sessionExit',
    'else if bearDropVeto',
    'else if bearTwoBlock',
    'else if downsideEmaApproachBlock',
    'else if activeLowAtrBlock',
    'else if denyBlock',
    'else if fallBlock',
    'else if reverseBlock',
    'else if bearishPatternBlock',
    'else if consecutiveRedBlock',
    'else if wasRiskLock',
    'else if wasActive'
)
$previousPriorityPosition = -1
foreach ($priorityToken in $priorityTokens) {
    $priorityPosition = $source.IndexOf(
        $priorityToken,
        $previousPriorityPosition + 1,
        [System.StringComparison]::Ordinal
    )
    if ($priorityPosition -lt 0 -or $priorityPosition -le $previousPriorityPosition) {
        $errors.Add("Missing or out-of-order MT5 policy branch: $priorityToken")
        break
    }
    $previousPriorityPosition = $priorityPosition
}

$downsideSafetyContracts = @(
    @{ Name = 'Downside entry ATR default'; Pattern = 'downsideMinAtrPrice\s*=\s*input\.float\(7\.0,' },
    @{ Name = 'Downside entry ATR isolation'; Pattern = 'downsideEntryAtrOk\s*=\s*atrOk\s+and\s+atrValue\s*>=\s*downsideMinAtrPrice' },
    @{ Name = 'Downside entry uses raised ATR gate'; Pattern = 'downsideEntryPass\s*=\s*enableDownsidePolicy\s+and\s+downsideEntryAtrOk' },
    @{ Name = 'Downside hold defers ATR OFF to streak'; Pattern = 'downsideHoldPass\s*=\s*enableDownsidePolicy\s+and\s+dataReady\s+and' },
    @{ Name = 'EMA approach tolerance default'; Pattern = 'downsideEmaApproachTolerance\s*=\s*input\.float\(0\.2,' },
    @{ Name = 'EMA approach full-range intersection'; Pattern = 'high\s*>=\s*emaValue\s*-\s*downsideEmaApproachTolerance\s+and[\s\S]*?low\s*<=\s*emaValue\s*\+\s*downsideEmaApproachTolerance' },
    @{ Name = 'Low ATR threshold default'; Pattern = 'activeLowAtrThreshold\s*=\s*input\.float\(7\.0,' },
    @{ Name = 'Low ATR streak default'; Pattern = 'activeLowAtrBars\s*=\s*input\.int\(3,' },
    @{ Name = 'Low ATR is strict'; Pattern = 'atrValue\s*<\s*activeLowAtrThreshold\s*\?' },
    @{ Name = 'Low ATR is ACTIVE for both policies'; Pattern = 'activePolicyBar\s*=\s*wasActive\s+and\s+currentBarSession\s*==\s*activeSession' },
    @{ Name = 'Downside EMA remains isolated'; Pattern = 'downsideActiveBar\s*=\s*activePolicyBar\s+and\s+activePolicy\s*==\s*POLICY_DOWNSIDE' },
    @{ Name = 'Low ATR waits for configured streak'; Pattern = 'activeLowAtrCount\s*>=\s*activeLowAtrBars' }
)
foreach ($contract in $downsideSafetyContracts) {
    if ($source -notmatch $contract.Pattern) {
        $errors.Add("Downside safety contract failed: $($contract.Name)")
    }
}

$bearTwoContracts = @(
    @{ Name = 'BearTwo enabled by default'; Pattern = 'enableBearTwoBlock\s*=\s*input\.bool\(true,' },
    @{ Name = 'BearTwo threshold default'; Pattern = 'bearTwoAtrThreshold\s*=\s*input\.float\(10\.0,' },
    @{ Name = 'BearTwo strict ATR comparison'; Pattern = 'currentBearish\s+and\s+atrValue\s*>\s*bearTwoAtrThreshold\s*\?' },
    @{ Name = 'BearTwo both active policies'; Pattern = 'bearTwoBlock\s*=\s*enableBearTwoBlock\s+and\s+activePolicyBar' },
    @{ Name = 'BearTwo fixed two-bar sequence'; Pattern = 'activeBearTwoCount\s*>=\s*2' },
    @{ Name = 'BearTwo event default name'; Pattern = 'nameBearTwo\s*=\s*input\.string\("BearTwo"' }
)
foreach ($contract in $bearTwoContracts) {
    if ($source -notmatch $contract.Pattern) {
        $errors.Add("BearTwo contract failed: $($contract.Name)")
    }
}

$consecutiveRedContracts = @(
    @{ Name = 'Unified consecutive RED default'; Pattern = 'consecutiveRedBars\s*=\s*input\.int\(3,' },
    @{ Name = 'Any bearish morphology definition'; Pattern = 'currentBearish\s*=\s*close\s*<\s*open' },
    @{ Name = 'Pure bearish counter'; Pattern = 'activeConsecutiveRedCount\s*:=\s*currentBearish\s*\?\s*activeConsecutiveRedCount\s*\+\s*1\s*:\s*0' },
    @{ Name = 'Both active policies'; Pattern = 'consecutiveRedBlock\s*=\s*enableConsecutiveRedBlock\s+and\s+activePolicyBar' },
    @{ Name = 'Three-bar configurable threshold'; Pattern = 'activeConsecutiveRedCount\s*>=\s*consecutiveRedBars' }
)
foreach ($contract in $consecutiveRedContracts) {
    if ($source -notmatch $contract.Pattern) {
        $errors.Add("Consecutive RED contract failed: $($contract.Name)")
    }
}

if ($source -match 'upsideConsecutiveRedBars|downsideConsecutiveRedBars') {
    $errors.Add('Policy-specific consecutive RED thresholds must not reappear.')
}

if ($source -match 'else if (bearTwo|downsideEmaApproach|activeLowAtr)Block[\s\S]{0,1200}?policyState\s*:=\s*STATE_RISK_LOCK') {
    $errors.Add('BearTwo/EMA/low-ATR events must be Soft OFF, never RISK LOCK.')
}

$sharedDefaults = @(
    @{ Name = 'ATR period'; Pine = 'atrPeriod\s*=\s*input\.int\(20,'; Mt5 = 'InpATRPeriod\s*=\s*20;' },
    @{ Name = 'Minimum ATR'; Pine = 'minAtrPrice\s*=\s*input\.float\(3\.0,'; Mt5 = 'InpMinATRPrice\s*=\s*3\.0;' },
    @{ Name = 'EMA period'; Pine = 'emaPeriod\s*=\s*input\.int\(23,'; Mt5 = 'InpEMAPeriod\s*=\s*23;' },
    @{ Name = 'Upside maximum'; Pine = 'upsideMaxAboveEma\s*=\s*input\.float\(20\.0,'; Mt5 = 'InpMaxAboveEMAPrice\s*=\s*20\.0;' },
    @{ Name = 'Upside confirm bars'; Pine = 'upsideConfirmBars\s*=\s*input\.int\(2,'; Mt5 = 'InpEnableConfirmBars\s*=\s*2;' },
    @{ Name = 'Consecutive red'; Pine = 'consecutiveRedBars\s*=\s*input\.int\(3,'; Mt5 = 'InpConsecutiveRedBars\s*=\s*3;' },
    @{ Name = 'Upside risk lock'; Pine = 'upsideRiskLockBars\s*=\s*input\.int\(2,'; Mt5 = 'InpRiskLockBars\s*=\s*2;' },
    @{ Name = 'Bear Drop lookback'; Pine = 'bearDropLookback\s*=\s*input\.int\(8,'; Mt5 = 'InpBearDropLookback\s*=\s*8;' },
    @{ Name = 'Bear Drop relative price'; Pine = 'minRelativeDropPrice\s*=\s*input\.float\(30\.0,'; Mt5 = 'InpMinRelativeDropPrice\s*=\s*30\.0;' },
    @{ Name = 'Bearish window'; Pine = 'bearishWindow\s*=\s*input\.int\(3,'; Mt5 = 'InpBearishWindow\s*=\s*3;' },
    @{ Name = 'Minimum bearish bars'; Pine = 'minBearishBars\s*=\s*input\.int\(2,'; Mt5 = 'InpMinBearishBars\s*=\s*2;' },
    @{ Name = 'Two-bar Bear Drop'; Pine = 'minTwoBarDropPrice\s*=\s*input\.float\(30\.0,'; Mt5 = 'InpMinTwoBarDropPrice\s*=\s*30\.0;' },
    @{ Name = 'Bearish body multiplier'; Pine = 'bearishBodyMultiplier\s*=\s*input\.float\(2\.0,'; Mt5 = 'InpBearishBodyMultiplier\s*=\s*2\.0;' },
    @{ Name = 'Deny lookback'; Pine = 'denyLookback\s*=\s*input\.int\(8,'; Mt5 = 'InpDenyLookback\s*=\s*8;' },
    @{ Name = 'Deny sweep'; Pine = 'denySweepBufferAtr\s*=\s*input\.float\(0\.05,'; Mt5 = 'InpDenySweepBufferATR\s*=\s*0\.05;' },
    @{ Name = 'Deny wick/body'; Pine = 'denyMinUpperWickBody\s*=\s*input\.float\(0\.50,'; Mt5 = 'InpDenyMinUpperWickBody\s*=\s*0\.50;' },
    @{ Name = 'Deny body multiplier'; Pine = 'denyBodyMultiplier\s*=\s*input\.float\(1\.0,'; Mt5 = 'InpDenyBodyMultiplier\s*=\s*1\.00;' },
    @{ Name = 'Deny overlap'; Pine = 'denyMinBodyOverlapPercent\s*=\s*input\.float\(60\.0,'; Mt5 = 'InpDenyMinBodyOverlapPercent\s*=\s*60\.0;' },
    @{ Name = 'Reverse upper wick'; Pine = 'reversePinMinUpperWickBody\s*=\s*input\.float\(2\.0,'; Mt5 = 'InpReversePinMinUpperWickBody\s*=\s*2\.0;' },
    @{ Name = 'Reverse lower wick'; Pine = 'reversePinMaxLowerWickBody\s*=\s*input\.float\(1\.0,'; Mt5 = 'InpReversePinMaxLowerWickBody\s*=\s*1\.0;' },
    @{ Name = 'Reverse body'; Pine = 'reverseBodyMultiplier\s*=\s*input\.float\(1\.0,'; Mt5 = 'InpReverseBodyMultiplier\s*=\s*1\.0;' },
    @{ Name = 'Fall range'; Pine = 'fallRangeMultiplier\s*=\s*input\.float\(1\.0,'; Mt5 = 'InpFallRangeMultiplier\s*=\s*1\.00;' },
    @{ Name = 'Session 1'; Pine = 'session1\s*=\s*input\.session\("0600-1200"'; Mt5 = 'InpSession1\s*=\s*"0600-1200";' },
    @{ Name = 'Session 2'; Pine = 'session2\s*=\s*input\.session\("1200-1800"'; Mt5 = 'InpSession2\s*=\s*"1200-1800";' },
    @{ Name = 'Session 3'; Pine = 'session3\s*=\s*input\.session\("1800-0300"'; Mt5 = 'InpSession3\s*=\s*"1800-0300";' },
    @{ Name = 'Recovery bars'; Pine = 'recoveryBars\s*=\s*input\.int\(1,'; Mt5 = 'InpRecoveryBars\s*=\s*1;' },
    @{ Name = 'Recovery buffer'; Pine = 'recoveryBufferAtr\s*=\s*input\.float\(0\.0,'; Mt5 = 'InpRecoveryBufferATR\s*=\s*0\.0;' },
    @{ Name = 'Recovery D rising'; Pine = 'requireRecoveryDRising\s*=\s*input\.bool\(true,'; Mt5 = 'InpRequireRecoveryDRising\s*=\s*true;' },
    @{ Name = 'Recovery EMA non-down'; Pine = 'requireRecoveryEmaNonDown\s*=\s*input\.bool\(false,'; Mt5 = 'InpRequireRecoveryEMANonDown\s*=\s*false;' },
    @{ Name = 'Recovery EMA slope'; Pine = 'recoveryEmaSlopeBars\s*=\s*input\.int\(3,'; Mt5 = 'InpRecoveryEMASlopeBars\s*=\s*3;' },
    @{ Name = 'Bullish SCOB recovery'; Pine = 'enableBullishScobRecovery\s*=\s*input\.bool\(true,'; Mt5 = 'InpEnableBullishSCOBRecovery\s*=\s*true;' },
    @{ Name = 'Trading history'; Pine = 'tradingZoneHistoryBars\s*=\s*input\.int\(1500,'; Mt5 = 'InpTradingZoneHistoryBars\s*=\s*1500;' },
    @{ Name = 'Risk history'; Pine = 'riskLockHistoryBars\s*=\s*input\.int\(1500,'; Mt5 = 'InpRiskLockHistoryBars\s*=\s*1500;' },
    @{ Name = 'Event history'; Pine = 'eventHistoryBars\s*=\s*input\.int\(1500,'; Mt5 = 'InpEventHistoryBars\s*=\s*1500;' },
    @{ Name = 'EMA history'; Pine = 'emaHistoryBars\s*=\s*input\.int\(400,'; Mt5 = 'InpEMADisplayBars\s*=\s*400;' }
)

foreach ($sharedDefault in $sharedDefaults) {
    if ($source -notmatch $sharedDefault.Pine -or $mt5Source -notmatch $sharedDefault.Mt5) {
        $errors.Add("MT5/Pine shared default mismatch: $($sharedDefault.Name)")
    }
}

if ($source -notmatch 'policyState\s*==\s*STATE_RISK_LOCK[\s\S]*?box\.set_right\(activeRiskBox,\s*time_close\)') {
    $errors.Add('RISK LOCK live renderer is not synchronized with MT5.')
}

if ($source.Contains("`t")) {
    $errors.Add('Tab characters are not allowed; use spaces.')
}

for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
    if ($lines[$lineIndex] -match '[ \t]+$') {
        $errors.Add("Trailing whitespace at line $($lineIndex + 1).")
    }
}

$stack = [System.Collections.Generic.Stack[object]]::new()
$pairs = @{ ')' = '('; ']' = '['; '}' = '{' }
$openers = @('(', '[', '{')
$inString = $false
$escaped = $false
$line = 1
$column = 0

for ($index = 0; $index -lt $source.Length; $index++) {
    $character = $source[$index]
    $column++

    if ($character -eq "`n") {
        $line++
        $column = 0
        $escaped = $false
        continue
    }

    if (-not $inString -and $character -eq '/' -and
        $index + 1 -lt $source.Length -and $source[$index + 1] -eq '/') {
        while ($index -lt $source.Length -and $source[$index] -ne "`n") {
            $index++
        }
        $line++
        $column = 0
        $escaped = $false
        continue
    }

    if ($inString) {
        if ($escaped) {
            $escaped = $false
        }
        elseif ($character -eq '\') {
            $escaped = $true
        }
        elseif ($character -eq '"') {
            $inString = $false
        }
        continue
    }

    if ($character -eq '"') {
        $inString = $true
        continue
    }

    if ($openers -contains [string]$character) {
        $stack.Push([pscustomobject]@{
            Character = [string]$character
            Line = $line
            Column = $column
        })
        continue
    }

    if ($pairs.ContainsKey([string]$character)) {
        if ($stack.Count -eq 0) {
            $errors.Add("Unexpected '$character' at ${line}:${column}.")
            continue
        }
        $opening = $stack.Pop()
        if ($opening.Character -ne $pairs[[string]$character]) {
            $errors.Add("Mismatched '$($opening.Character)' at $($opening.Line):$($opening.Column) and '$character' at ${line}:${column}.")
        }
    }
}

if ($inString) {
    $errors.Add('Unterminated string literal at end of file.')
}

while ($stack.Count -gt 0) {
    $opening = $stack.Pop()
    $errors.Add("Unclosed '$($opening.Character)' from $($opening.Line):$($opening.Column).")
}

$requiredTokens = @(
    'barstate.isconfirmed',
    'STATE_OFF',
    'STATE_ARMING',
    'STATE_ACTIVE',
    'STATE_RISK_LOCK',
    'POLICY_UPSIDE',
    'POLICY_DOWNSIDE',
    'alertcondition('
)

foreach ($token in $requiredTokens) {
    if (-not $source.Contains($token)) {
        $errors.Add("Missing required delivery token: $token")
    }
}

if ($errors.Count -gt 0) {
    Write-Host "FAIL: $resolvedPath" -ForegroundColor Red
    foreach ($failure in $errors) {
        Write-Host "  - $failure" -ForegroundColor Red
    }
    exit 1
}

$remoteWarningCount = 0
if (-not $SkipRemoteCompile) {
    $compilerCheck = Join-Path $PSScriptRoot 'Test-PineCompile.mjs'
    & node $compilerCheck $resolvedPath
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

Write-Host "PASS: $resolvedPath" -ForegroundColor Green
Write-Host "  Pine version: 6"
Write-Host "  Lines: $($lines.Count)"
Write-Host '  Strings and delimiters: balanced'
Write-Host '  Required state-machine tokens: present'
Write-Host "  Candle coordinate contract: PASS ($boxCreateCount box constructor(s))"
Write-Host '  Zone capacity: PASS (500 boxes / 100000 history bars)'
Write-Host '  MT5 decision-time and event-priority contract: PASS'
Write-Host "  MT5 shared-default parity: PASS ($($sharedDefaults.Count) checks)"
Write-Host '  Whitespace policy: clean'
if ($SkipRemoteCompile) {
    Write-Host '  TradingView compiler: SKIPPED' -ForegroundColor Yellow
}
else {
    Write-Host '  TradingView compiler: PASS'
}
