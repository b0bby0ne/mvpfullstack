[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $projectRoot 'src\mt5\CCBSN_Controller_Lite.mq5'
$policyPath = Join-Path $projectRoot 'config\policy.atr-m5-balanced.v0.1.json'
$errors = [System.Collections.Generic.List[string]]::new()

if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
    throw "Missing source: $sourcePath"
}
if (-not (Test-Path -LiteralPath $policyPath -PathType Leaf)) {
    throw "Missing policy: $policyPath"
}

$source = Get-Content -LiteralPath $sourcePath -Raw -Encoding UTF8
$lines = Get-Content -LiteralPath $sourcePath -Encoding UTF8
$policy = Get-Content -LiteralPath $policyPath -Raw -Encoding UTF8 |
    ConvertFrom-Json

function Assert-Pattern {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $Pattern
    )
    if ($source -notmatch $Pattern) {
        $errors.Add("Missing contract: $Name")
    }
}

Assert-Pattern 'Alpha version' '#define\s+LITE_VERSION\s+"0\.1\.0-alpha"'
Assert-Pattern 'M5 decision timeframe' 'DECISION_TIMEFRAME\s*=\s*PERIOD_M5'
Assert-Pattern 'Visual-only default' 'InpControlMode\s*=\s*LITE_VISUAL_ONLY'
Assert-Pattern 'Closed bar rates' 'CopyRates\(_Symbol,\s*DECISION_TIMEFRAME,\s*1,\s*1'
Assert-Pattern 'Closed bar ATR' 'CopyBuffer\(g_atrHandle,\s*0,\s*1,\s*1'
Assert-Pattern 'ATR baseline average' 'baselineTotal\s*/\s*baselineCount'
Assert-Pattern 'Entry ATR lower bound' 'g_lastATRRatio\s*>=\s*InpEntryATRRatioMin'
Assert-Pattern 'Entry ATR upper bound' 'g_lastATRRatio\s*<=\s*InpEntryATRRatioMax'
Assert-Pattern 'Hold hysteresis lower bound' 'g_lastATRRatio\s*>=\s*InpHoldATRRatioMin'
Assert-Pattern 'Hold hysteresis upper bound' 'g_lastATRRatio\s*<=\s*InpHoldATRRatioMax'
Assert-Pattern 'Minimum zone suppression' 'g_zoneBars\s*<\s*InpMinimumZoneBars'
Assert-Pattern 'Soft exit confirmation' 'g_softExitCount\s*>=\s*InpSoftExitConfirmBars'
Assert-Pattern 'Bear shock ATR range' 'g_lastRangeATR\s*>=\s*InpHardBearShockRangeATR'
Assert-Pattern 'Bear shock body share' 'g_lastBodyShare\s*>=\s*InpHardBearMinBodyShare'
Assert-Pattern 'Bear shock close location' 'g_lastCloseLocation\s*<=\s*[\r\n\s]*InpHardBearMaxCloseLocation'
Assert-Pattern 'Continuous overnight session' 'minuteOfDay\s*>=\s*startMinute\s*\|\|\s*minuteOfDay\s*<\s*endMinute'
Assert-Pattern 'Spread normalized by ATR' 'g_lastSpreadATR\s*=\s*\(tick\.ask\s*-\s*tick\.bid\)\s*/\s*g_lastATR'
Assert-Pattern 'Shared controller mutex' '"CCBSN\.NC\.LOCK\."'
Assert-Pattern 'New Cycle ON transport' 'g_trade\.SellLimit'
Assert-Pattern 'New Cycle OFF transport' 'g_trade\.BuyStop'
Assert-Pattern 'Ticket is authoritative' 'ulong\s+ticket\s*=\s*g_trade\.ResultOrder\(\)'
Assert-Pattern 'Pending history reconciliation' 'HistoryOrderSelect\(g_commandTicket\)'
Assert-Pattern 'Executed command fatal path' 'COMMAND_ORDER_EXECUTED'
Assert-Pattern 'No policy work on tick' 'void\s+OnTick\(\)\s*\{\s*// Policy and command reconciliation are timer-driven\. OnTick stays empty\.\s*\}'
Assert-Pattern 'Audit event for zone start' 'POLICY_ZONE_STARTED'
Assert-Pattern 'Audit event for zone end' 'POLICY_ZONE_ENDED'
Assert-Pattern 'Risk lock event' 'BEAR_SHOCK_RISK_LOCK'

foreach ($forbidden in @(
    'PositionOpen\(', 'PositionClose\(', 'PositionModify\(',
    'WebRequest', 'TELEGRAM_BOT_TOKEN', 'api\.telegram\.org'
)) {
    if ($source -match $forbidden) {
        $errors.Add("Forbidden capability found: $forbidden")
    }
}

if ($policy.decision_timeframe -ne 'M5') {
    $errors.Add('Policy JSON decision timeframe is not M5.')
}
if (-not $policy.closed_bar_only) {
    $errors.Add('Policy JSON must be closed-bar only.')
}
if ($policy.control.default_mode -ne 'VISUAL_ONLY' -or
    $policy.control.live_approved) {
    $errors.Add('Policy JSON control safety defaults are invalid.')
}

$sourceDefaults = @{
    atr_period = [int]$policy.atr.period
    baseline_bars = [int]$policy.atr.baseline_bars
    entry_min = [double]$policy.atr.entry_ratio_min
    entry_max = [double]$policy.atr.entry_ratio_max
    hold_min = [double]$policy.atr.hold_ratio_min
    hold_max = [double]$policy.atr.hold_ratio_max
    entry_range = [double]$policy.atr.entry_max_range_atr
    soft_range = [double]$policy.atr.soft_expansion_range_atr
    hard_range = [double]$policy.bearish_shock.range_atr_min
}

$defaultPatterns = @(
    @{ Name='ATR period JSON/source'; Pattern="InpATRPeriod\s*=\s*$($sourceDefaults.atr_period);" },
    @{ Name='Baseline JSON/source'; Pattern="InpATRBaselineBars\s*=\s*$($sourceDefaults.baseline_bars);" },
    @{ Name='Entry min JSON/source'; Pattern=('InpEntryATRRatioMin\s*=\s*' + $sourceDefaults.entry_min.ToString('0.00', [Globalization.CultureInfo]::InvariantCulture) + ';') },
    @{ Name='Entry max JSON/source'; Pattern=('InpEntryATRRatioMax\s*=\s*' + $sourceDefaults.entry_max.ToString('0.00', [Globalization.CultureInfo]::InvariantCulture) + ';') },
    @{ Name='Hold min JSON/source'; Pattern=('InpHoldATRRatioMin\s*=\s*' + $sourceDefaults.hold_min.ToString('0.00', [Globalization.CultureInfo]::InvariantCulture) + ';') },
    @{ Name='Hold max JSON/source'; Pattern=('InpHoldATRRatioMax\s*=\s*' + $sourceDefaults.hold_max.ToString('0.00', [Globalization.CultureInfo]::InvariantCulture) + ';') },
    @{ Name='Entry range JSON/source'; Pattern=('InpEntryMaxRangeATR\s*=\s*' + $sourceDefaults.entry_range.ToString('0.00', [Globalization.CultureInfo]::InvariantCulture) + ';') },
    @{ Name='Soft range JSON/source'; Pattern=('InpSoftExpansionRangeATR\s*=\s*' + $sourceDefaults.soft_range.ToString('0.00', [Globalization.CultureInfo]::InvariantCulture) + ';') },
    @{ Name='Hard range JSON/source'; Pattern=('InpHardBearShockRangeATR\s*=\s*' + $sourceDefaults.hard_range.ToString('0.00', [Globalization.CultureInfo]::InvariantCulture) + ';') }
)
foreach ($contract in $defaultPatterns) {
    Assert-Pattern $contract.Name $contract.Pattern
}

function Test-EntryCandidate {
    param([double]$Ratio, [double]$RangeAtr, [bool]$Operational = $true)
    return $Operational -and
        $Ratio -ge $sourceDefaults.entry_min -and
        $Ratio -le $sourceDefaults.entry_max -and
        $RangeAtr -le $sourceDefaults.entry_range
}

function Test-HoldCandidate {
    param([double]$Ratio, [double]$RangeAtr, [bool]$Operational = $true)
    return $Operational -and
        $Ratio -ge $sourceDefaults.hold_min -and
        $Ratio -le $sourceDefaults.hold_max -and
        $RangeAtr -lt $sourceDefaults.soft_range
}

$truthCases = @(
    @{ Name='Entry lower boundary'; Actual=(Test-EntryCandidate 0.65 1.0); Expected=$true },
    @{ Name='Entry upper boundary'; Actual=(Test-EntryCandidate 1.65 1.8); Expected=$true },
    @{ Name='Entry low fail'; Actual=(Test-EntryCandidate 0.64 1.0); Expected=$false },
    @{ Name='Entry range fail'; Actual=(Test-EntryCandidate 1.00 1.81); Expected=$false },
    @{ Name='Hold below entry remains valid'; Actual=(Test-HoldCandidate 0.55 1.2); Expected=$true },
    @{ Name='Hold above entry remains valid'; Actual=(Test-HoldCandidate 1.90 1.2); Expected=$true },
    @{ Name='Soft expansion strict boundary'; Actual=(Test-HoldCandidate 1.00 2.00); Expected=$false },
    @{ Name='Operational veto'; Actual=(Test-EntryCandidate 1.00 1.0 $false); Expected=$false }
)

foreach ($case in $truthCases) {
    if ($case.Actual -ne $case.Expected) {
        $errors.Add("Truth table failed: $($case.Name)")
    }
}

function Test-SessionMinute {
    param([int]$MinuteOfDay, [int]$Start = 360, [int]$End = 180)
    if ($Start -eq $End) { return $true }
    if ($Start -lt $End) {
        return $MinuteOfDay -ge $Start -and $MinuteOfDay -lt $End
    }
    return $MinuteOfDay -ge $Start -or $MinuteOfDay -lt $End
}

$sessionCases = @(
    @{ Name='Session start'; Actual=(Test-SessionMinute 360); Expected=$true },
    @{ Name='Midday'; Actual=(Test-SessionMinute 720); Expected=$true },
    @{ Name='Before midnight'; Actual=(Test-SessionMinute 1439); Expected=$true },
    @{ Name='After midnight'; Actual=(Test-SessionMinute 179); Expected=$true },
    @{ Name='Session end exclusive'; Actual=(Test-SessionMinute 180); Expected=$false },
    @{ Name='Pre-session block'; Actual=(Test-SessionMinute 359); Expected=$false }
)
foreach ($case in $sessionCases) {
    if ($case.Actual -ne $case.Expected) {
        $errors.Add("Session truth table failed: $($case.Name)")
    }
}

function Invoke-LitePolicySequence {
    param([Parameter(Mandatory)] [object[]] $Steps)

    $state = 'OFF'
    $entryCount = 0
    $softCount = 0
    $zoneBars = 0
    $riskRemaining = 0
    $recoveryCount = 0
    $states = [System.Collections.Generic.List[string]]::new()

    foreach ($step in $Steps) {
        $candidate = [bool]$step.Candidate
        $hold = [bool]$step.Hold
        $shock = [bool]$step.Shock

        if ($state -eq 'ACTIVE') {
            $zoneBars++
            if ($shock) {
                $state = 'RISK_LOCK'
                $zoneBars = 0
                $softCount = 0
                $riskRemaining = [int]$policy.bearish_shock.risk_lock_bars
                $recoveryCount = 0
            }
            elseif ($hold) {
                $softCount = 0
            }
            elseif ($zoneBars -lt [int]$policy.stability.minimum_zone_bars) {
                $softCount = 0
            }
            else {
                $softCount++
                if ($softCount -ge [int]$policy.stability.soft_exit_confirm_bars) {
                    $state = 'OFF'
                    $zoneBars = 0
                    $softCount = 0
                }
            }
        }
        elseif ($state -eq 'RISK_LOCK') {
            if ($shock) {
                $riskRemaining = [int]$policy.bearish_shock.risk_lock_bars
                $recoveryCount = 0
            }
            elseif ($riskRemaining -gt 0) {
                $riskRemaining--
                $recoveryCount = 0
            }
            elseif ($candidate) {
                $recoveryCount++
                if ($recoveryCount -ge [int]$policy.bearish_shock.recovery_confirm_bars) {
                    $state = 'ACTIVE'
                    $zoneBars = 1
                    $recoveryCount = 0
                }
            }
            else {
                $recoveryCount = 0
            }
        }
        elseif ($shock) {
            $state = 'RISK_LOCK'
            $entryCount = 0
            $riskRemaining = [int]$policy.bearish_shock.risk_lock_bars
        }
        elseif ($candidate) {
            if ($state -ne 'ARMING') {
                $state = 'ARMING'
                $entryCount = 0
            }
            $entryCount++
            if ($entryCount -ge [int]$policy.stability.enable_confirm_bars) {
                $state = 'ACTIVE'
                $zoneBars = 1
                $entryCount = 0
            }
        }
        else {
            $state = 'OFF'
            $entryCount = 0
        }
        $states.Add($state)
    }
    return ,$states.ToArray()
}

$safe = @{ Candidate=$true; Hold=$true; Shock=$false }
$unsafe = @{ Candidate=$false; Hold=$false; Shock=$false }
$soft = @{ Candidate=$false; Hold=$false; Shock=$false }
$shock = @{ Candidate=$false; Hold=$false; Shock=$true }

$sequenceCases = @(
    @{ Name='Two-bar enable confirmation'; Steps=@($safe,$safe); Expected='ACTIVE' },
    @{ Name='Arming cancellation'; Steps=@($safe,$unsafe); Expected='OFF' },
    @{ Name='Entry boundary can fail while hold survives'; Steps=@($safe,$safe,@{ Candidate=$false; Hold=$true; Shock=$false }); Expected='ACTIVE' },
    @{ Name='Minimum hold and two-bar soft exit'; Steps=@($safe,$safe,$soft,$soft,$soft,$soft); Expected='OFF' },
    @{ Name='Hard shock bypasses soft exit'; Steps=@($safe,$safe,$shock); Expected='RISK_LOCK' },
    @{ Name='Shock outside active also locks'; Steps=@($shock); Expected='RISK_LOCK' }
)
foreach ($case in $sequenceCases) {
    $states = Invoke-LitePolicySequence -Steps $case.Steps
    $actual = $states[-1]
    if ($actual -ne $case.Expected) {
        $errors.Add("State sequence failed: $($case.Name), actual=$actual expected=$($case.Expected)")
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
    Write-Host "FAIL: $sourcePath" -ForegroundColor Red
    foreach ($failure in $errors) {
        Write-Host "  - $failure" -ForegroundColor Red
    }
    exit 1
}

$sourceHash = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash
Write-Host "PASS: $sourcePath" -ForegroundColor Green
Write-Host "  Source lines: $($lines.Count)"
Write-Host "  Static contracts: PASS"
Write-Host "  Policy JSON parity: PASS"
Write-Host "  ATR truth table: PASS ($($truthCases.Count) cases)"
Write-Host "  Continuous-session truth table: PASS ($($sessionCases.Count) cases)"
Write-Host "  State-sequence truth table: PASS ($($sequenceCases.Count) cases)"
Write-Host '  Strategy position management capability: NONE'
Write-Host '  Network/credential capability: NONE'
Write-Host "  MQ5 SHA256: $sourceHash"
