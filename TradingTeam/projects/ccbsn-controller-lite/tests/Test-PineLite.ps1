[CmdletBinding()]
param(
    [string] $Path = '',
    [switch] $SkipRemoteCompile
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Path)) {
    $Path = Join-Path $projectRoot 'src\pine\CCBSN_Controller_Lite_ATR_M5.pine'
}
$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
$policyPath = Join-Path $projectRoot 'config\policy.atr-m5-balanced.v0.1.json'
$mt5Path = Join-Path $projectRoot 'src\mt5\CCBSN_Controller_Lite.mq5'
$source = Get-Content -LiteralPath $resolvedPath -Raw -Encoding UTF8
$lines = Get-Content -LiteralPath $resolvedPath -Encoding UTF8
$policy = Get-Content -LiteralPath $policyPath -Raw -Encoding UTF8 |
    ConvertFrom-Json
$mt5 = Get-Content -LiteralPath $mt5Path -Raw -Encoding UTF8
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
Assert-PinePattern 'Confirmed bars only' 'barstate\.isconfirmed\s+and\s+isM5Chart'
Assert-PinePattern 'ATR calculation' 'ta\.atr\(atrPeriod\)'
Assert-PinePattern 'ATR baseline SMA' 'ta\.sma\(atrValue,\s*atrBaselineBars\)'
Assert-PinePattern 'ATR ratio' 'atrValue\s*/\s*atrBaseline'
Assert-PinePattern 'Range normalized by ATR' 'candleRange\s*/\s*atrValue'
Assert-PinePattern 'Body share' 'math\.abs\(close\s*-\s*open\)\s*/\s*candleRange'
Assert-PinePattern 'Close location' '\(close\s*-\s*low\)\s*/\s*candleRange'
Assert-PinePattern 'Entry hysteresis lower' 'atrRatio\s*>=\s*entryRatioMin'
Assert-PinePattern 'Entry hysteresis upper' 'atrRatio\s*<=\s*entryRatioMax'
Assert-PinePattern 'Hold hysteresis lower' 'atrRatio\s*>=\s*holdRatioMin'
Assert-PinePattern 'Hold hysteresis upper' 'atrRatio\s*<=\s*holdRatioMax'
Assert-PinePattern 'Minimum zone bars' 'zoneBars\s*<\s*minimumZoneBars'
Assert-PinePattern 'Soft exit confirmation' 'softExitCount\s*>=\s*softExitConfirmBars'
Assert-PinePattern 'Hard shock range' 'rangeAtr\s*>=\s*hardBearShockRangeAtr'
Assert-PinePattern 'Hard shock body' 'bodyShare\s*>=\s*hardBearMinBodyShare'
Assert-PinePattern 'Hard shock close' 'closeLocation\s*<=\s*hardBearMaxCloseLocation'
Assert-PinePattern 'Continuous session default' 'input\.session\("0600-0300"'
Assert-PinePattern 'Decision-time session lookup' 'bars_back\s*=\s*-1'
Assert-PinePattern 'Decision time event labels' 'label\.new\(x\s*=\s*time_close'
Assert-PinePattern 'Decision time zone boxes' 'box\.new\(left\s*=\s*leftTime'
Assert-PinePattern 'Future close zone extent' 'nextBarCloseTime\s*=\s*time_close\(timeframe\.period,\s*bars_back\s*=\s*-1\)'
Assert-PinePattern 'Balanced profile' '"Balanced Lite"\s*=>\s*0\.65'
Assert-PinePattern 'Wide profile' '"Wide Lite"\s*=>\s*0\.45'
Assert-PinePattern 'High-veto profile' '"High-Veto Only"\s*=>\s*0\.00'
Assert-PinePattern 'Zone start alert' 'alertcondition\(zoneStartedEvent'
Assert-PinePattern 'Zone end alert' 'alertcondition\(zoneEndedEvent'
Assert-PinePattern 'Bear shock alert' 'alertcondition\(shockEvent'
Assert-PinePattern 'Recovery alert' 'alertcondition\(recoveredEvent'

$activeStart = $source.IndexOf('if wasActive')
$activeEnd = $source.IndexOf('else if wasRiskLock', $activeStart)
if ($activeStart -lt 0 -or $activeEnd -lt 0) {
    $errors.Add('Cannot locate ACTIVE policy branch.')
}
else {
    $activeBody = $source.Substring($activeStart, $activeEnd - $activeStart)
    $priorityTokens = @(
        'if hardBearShock',
        'else if not decisionSessionOpen or not dataReady',
        'else if activeHoldPass',
        'else if zoneBars < minimumZoneBars'
    )
    $previous = -1
    foreach ($token in $priorityTokens) {
        $position = $activeBody.IndexOf($token, $previous + 1,
            [StringComparison]::Ordinal)
        if ($position -le $previous) {
            $errors.Add("Missing/out-of-order ACTIVE branch: $token")
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

$jsonDefaults = @(
    @{ Name='ATR period'; Pine='atrPeriod\s*=\s*input\.int\(14,'; Mt5='InpATRPeriod\s*=\s*14;' },
    @{ Name='ATR baseline'; Pine='atrBaselineBars\s*=\s*input\.int\(48,'; Mt5='InpATRBaselineBars\s*=\s*48;' },
    @{ Name='Entry range'; Pine='entryMaxRangeAtr\s*=\s*input\.float\(1\.80,'; Mt5='InpEntryMaxRangeATR\s*=\s*1\.80;' },
    @{ Name='Soft range'; Pine='softExpansionRangeAtr\s*=\s*input\.float\(2\.00,'; Mt5='InpSoftExpansionRangeATR\s*=\s*2\.00;' },
    @{ Name='Enable confirm'; Pine='enableConfirmBars\s*=\s*input\.int\(2,'; Mt5='InpEnableConfirmBars\s*=\s*2;' },
    @{ Name='Soft confirm'; Pine='softExitConfirmBars\s*=\s*input\.int\(2,'; Mt5='InpSoftExitConfirmBars\s*=\s*2;' },
    @{ Name='Minimum zone'; Pine='minimumZoneBars\s*=\s*input\.int\(4,'; Mt5='InpMinimumZoneBars\s*=\s*4;' },
    @{ Name='Hard shock'; Pine='hardBearShockRangeAtr\s*=\s*input\.float\(2\.80,'; Mt5='InpHardBearShockRangeATR\s*=\s*2\.80;' },
    @{ Name='Body share'; Pine='hardBearMinBodyShare\s*=\s*input\.float\(0\.60,'; Mt5='InpHardBearMinBodyShare\s*=\s*0\.60;' },
    @{ Name='Close location'; Pine='hardBearMaxCloseLocation\s*=\s*input\.float\(0\.25,'; Mt5='InpHardBearMaxCloseLocation\s*=\s*0\.25;' },
    @{ Name='Risk lock'; Pine='riskLockBars\s*=\s*input\.int\(6,'; Mt5='InpRiskLockBars\s*=\s*6;' },
    @{ Name='Recovery'; Pine='recoveryConfirmBars\s*=\s*input\.int\(2,'; Mt5='InpRecoveryConfirmBars\s*=\s*2;' }
)
foreach ($contract in $jsonDefaults) {
    if ($source -notmatch $contract.Pine -or $mt5 -notmatch $contract.Mt5) {
        $errors.Add("Pine/MT5 default mismatch: $($contract.Name)")
    }
}

if ($policy.decision_timeframe -ne 'M5' -or -not $policy.closed_bar_only) {
    $errors.Add('Policy JSON M5 closed-bar contract is invalid.')
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
Write-Host '  Pine v6 visual-only contract: PASS'
Write-Host "  Pine/MT5 defaults: PASS ($($jsonDefaults.Count) checks)"
Write-Host '  ACTIVE event priority: PASS'
Write-Host '  Alerts: PASS (ARM, Zone, Soft OFF, Shock, Recovery)'
Write-Host '  Trading/control/network capability: NONE'
Write-Host "  Pine SHA256: $sourceHash"
