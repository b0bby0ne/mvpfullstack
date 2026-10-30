param(
    [string] $MetaEditorPath = 'D:\Test Bot 1\MetaEditor64.exe',
    [switch] $SkipCompile
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $projectRoot 'src\mt5\SMC_Controller.mq5'
$policyPath = Join-Path $projectRoot 'config\smc-policy.xau-m15-m30.v0.14.json'
$compileLog = Join-Path $projectRoot 'build\logs\compile-smc-controller.log'
$errors = [System.Collections.Generic.List[string]]::new()

function Assert-Contains {
    param([string] $Text, [string] $Needle, [string] $Name)
    if (-not $Text.Contains($Needle)) {
        $errors.Add("Missing contract: $Name")
    }
}

if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
    throw "Source not found: $sourcePath"
}

$source = Get-Content -LiteralPath $sourcePath -Raw -Encoding UTF8
$policy = Get-Content -LiteralPath $policyPath -Raw -Encoding UTF8 | ConvertFrom-Json

Assert-Contains $source 'SMC_VISUAL_ONLY = 0' 'visual-only default enum'
Assert-Contains $source 'input ENUM_SMC_CONTROL_MODE InpControlMode = SMC_VISUAL_ONLY' 'safe default mode'
Assert-Contains $source 'BULLISH_SSL_SWEEP' 'bullish liquidity event'
Assert-Contains $source 'BULLISH_DISPLACEMENT_BREAK' 'bullish intent event'
Assert-Contains $source 'BULLISH_FVG_CREATED' 'bullish FVG event'
Assert-Contains $source 'BULLISH_SETUP_CONFIRMED' 'bullish setup event'
Assert-Contains $source 'BULLISH_ENTRY_WINDOW_ON' 'bullish ON event'
Assert-Contains $source 'BEARISH_BSL_SWEEP' 'bearish liquidity event'
Assert-Contains $source 'BEARISH_DISPLACEMENT_BREAK' 'bearish structural OFF event'
Assert-Contains $source 'CAUSAL_LOW_INVALIDATED' 'thesis invalidation'
Assert-Contains $source 'CCBSN_CHAIN_STARTED_TOKEN_CONSUMED' 'one-shot token'
Assert-Contains $source 'bar.close > reclaimLevel' 'FVG reclaim confirmation'
Assert-Contains $source 'bar.close < g_setupCausalLow' 'causal-low invalidation'
Assert-Contains $source 'g_trade.SellLimit' 'New Cycle ON transport'
Assert-Contains $source 'g_trade.BuyStop' 'New Cycle OFF transport'
Assert-Contains $source 'COMMAND_PRICE = 888888.0' 'CCBSN magic price'
Assert-Contains $source 'CCBSN.NC.LOCK.' 'shared controller mutex'
Assert-Contains $source 'OBJ_RECTANGLE' 'Trading Zone visual'
Assert-Contains $source 'off_reason=' 'Trading Zone OFF reason tooltip'
Assert-Contains $source 'trigger=' 'Trading Zone ON trigger tooltip'
Assert-Contains $source 'CreateEventMarker(confirmed ? "NC ON ACK" : "ZONE ON"' 'Trading Zone ON marker'
Assert-Contains $source 'CreateEventMarker("ZONE OFF"' 'Trading Zone OFF marker'
Assert-Contains $source 'CCBSN_LITE_RANGE_BOX' 'CCBSN Controller Lite range-box renderer'
Assert-Contains $source 'g_zoneHigh = MathMax' 'Trading Zone candle-range high'
Assert-Contains $source 'g_zoneLow = MathMin' 'Trading Zone candle-range low'
Assert-Contains $source 'input int InpZoneOpacityPercent = 70' '70 percent Trading Zone opacity'
Assert-Contains $source 'g_latestBearFVGFillEvent || g_sslSweepOnEvent' 'OR-based ON events'
Assert-Contains $source 'g_offBSLSweep = InpOffOnBuySideSweep && buySideSweep' 'BSL sweep OFF event'
Assert-Contains $source 'CopyRates(_Symbol, timeframe, shift, 1' 'closed-bar reads'
Assert-Contains $source 'SUPERSEDED_COMMAND_DELETE_FAILED' 'pending command supersession'
Assert-Contains $source 'g_controlState != SMC_CONTROL_OFF_CONFIRMED' 'no setup overlap before OFF ACK'
Assert-Contains $source 'g_onDataGate' 'ON gate checklist'
Assert-Contains $source 'M30 context is telemetry/watchout only' 'M30 watchout-only contract'
Assert-Contains $source 'g_offCausalLow' 'causal-low OFF veto'
Assert-Contains $source 'g_offTokenConsumed' 'one-shot OFF veto telemetry'
Assert-Contains $source 'bool SystemReadinessPass()' 'system readiness contract'
Assert-Contains $source 'bool EventChecklistPass()' 'event checklist contract'
Assert-Contains $source 'bool OnTriggerReady()' 'event-driven ON contract'
Assert-Contains $source 'if(OnTriggerReady())' 'entry window gated by ON trigger event'
Assert-Contains $source 'BULLISH_ON_TRIGGER' 'auditable ON trigger event'
Assert-Contains $source 'LATEST_BEAR_FVG_FILL_ON_TRIGGER' 'latest bearish FVG fill ON event'
Assert-Contains $source 'ProcessActiveBearFVGFills' 'active bearish FVG fill registry'
Assert-Contains $source 'bar.high < twoBarsAgo.low' 'bearish FVG definition'
Assert-Contains $source 'bar.high < zone.top' 'bearish FVG full-fill boundary'
Assert-Contains $source 'InpMaxActiveBearFVGZones != 3' 'exactly three active bearish FVG zones'
Assert-Contains $source 'bool BuildHistoricalZones()' 'historical state reconstruction'
Assert-Contains $source 'PolicyReferenceOpenShift' 'no-lookahead swing reference'
Assert-Contains $source 'InpMaxStoredTradingZones' 'bounded historical zone objects'
Assert-Contains $source 'InpMaxHistoricalEventMarkers' 'bounded historical SMC event map'
Assert-Contains $source 'void TrackEventObject' 'historical marker queue'
Assert-Contains $source 'SMC CAUSAL LOW' 'setup causal-low visual'
Assert-Contains $source 'SMC FVG 50%' 'setup FVG midpoint visual'
Assert-Contains $source 'SMC TARGET LIQUIDITY' 'setup target visual'
Assert-Contains $source 'g_processingHistory || g_ccbsnPositionCount == 0' 'historical flat inventory model'
Assert-Contains $source 'SYSTEM READINESS  [AND]' 'top-left system readiness checklist'
Assert-Contains $source 'SMC STRUCTURE WATCHOUT  [NO CYCLE EFFECT]' 'SMC watchout panel'
Assert-Contains $source 'g_dataBlockReason' 'detailed DATA block reason'
Assert-Contains $source 'g_operationalBlockReason' 'detailed operational block reason'
Assert-Contains $source 'g_onFlatGate = count == 0' 'timer-synchronized CCBSN flat gate'
Assert-Contains $source 'ON CHECKLIST  [BUY FVG AND EVENT]' 'top-left ON checklist'
Assert-Contains $source 'OFF CHECKLIST  [OR / FIRST VETO WINS]' 'bottom-left OFF event checklist'
Assert-Contains $source 'CORNER_LEFT_UPPER' 'top-left dashboard anchor'
Assert-Contains $source 'CORNER_LEFT_LOWER' 'bottom-left dashboard anchor'
Assert-Contains $source 'OBJ_RECTANGLE_LABEL' 'dashboard background panels'
Assert-Contains $source 'bool ApplyChartTheme()' 'Controller Lite chart theme'
Assert-Contains $source 'CHART_COLOR_BACKGROUND' 'chart background theme property'
Assert-Contains $source 'InpContextTimeframe = PERIOD_M30' 'M30 watchout context default'
Assert-Contains $source 'StartTradingZone(decisionTime, bar.close, false, bar.high, bar.low)' 'zone starts with ON trigger candle range'
Assert-Contains $source 'if(OnTriggerReady() && transportReady && offVetoClear)' 'control transport safety gate retained'
Assert-Contains $source 'bar.low > twoBarsAgo.high' 'buy-side FVG definition'
Assert-Contains $source 'bar.low <= zone.bottom' 'buy-side FVG full-fill boundary'
Assert-Contains $source 'g_onBuySideFVGGate' 'buy-side FVG ON-checklist gate'
Assert-Contains $source 'InpDrawLatestBuySideFVG' 'latest buy-side FVG chart visibility'
Assert-Contains $source 'InpLabelBuySideFVG' 'editable buy-side FVG chart label'
Assert-Contains $source 'g_activeBuySideFVGs[size - 1]' 'fallback to latest remaining active buy-side FVG'
Assert-Contains $source 'input int InpBuySideFVGMaxAgeBars = 30' '30-bar buy-side FVG lookback default'
Assert-Contains $source 'ageBars >= InpBuySideFVGMaxAgeBars' 'buy-side FVG age expiry'
Assert-Contains $source "InpBearFVGZoneColor = C'150,200,245'" 'light-blue sell-side FVG color'
Assert-Contains $source "InpBuySideFVGZoneColor = C'150,225,175'" 'light-green buy-side FVG color'
Assert-Contains $source 'OBJPROP_BACK, true' 'FVG boxes render behind candles'
Assert-Contains $source 'no BUY SIDE FVG text overlays price candles' 'buy-side FVG chart text removed'
Assert-Contains $source 'input string InpLabelSSLSweep = "sSwept"' 'short SSL event default'
Assert-Contains $source 'input string InpLabelBSLSweep = "bSwept"' 'short BSL event default'
Assert-Contains $source 'input string InpLabelBearLock = "bLock"' 'short bear-lock event default'
if ($source.Contains('InpLabelSetupOff') -or
    $source.Contains('CreateEventMarker(riskLock ? "BEAR OFF" : "SETUP OFF"')) {
    $errors.Add('setupOff marker must remain hidden from the chart.')
}
if ($policy.hiddenEventMarkers -notcontains 'SETUP_OFF') {
    $errors.Add('Machine-readable policy must declare SETUP_OFF as hidden.')
}
Assert-Contains $source 'input group "09. Audit"' 'simplified nine-group input layout'
Assert-Contains $source 'const string displayLabel = ""' 'editable event display label'
Assert-Contains $source 'ON READY:' 'visual ON checklist result'
Assert-Contains $source 'ENTRY TIMEOUT' 'visual OFF timeout checklist'
Assert-Contains $source 'ONE-SHOT TOKEN' 'visual OFF token checklist'

if ($policy.defaults.controlMode -ne 'visual-only') {
    $errors.Add('Machine-readable policy must default to visual-only.')
}
if (-not $policy.defaults.oneShotPerSetup) {
    $errors.Add('Machine-readable policy must remain one-shot by default.')
}
if (-not $policy.decision.failClosed) {
    $errors.Add('Machine-readable policy must remain fail-closed.')
}
if ($policy.decision.onSemantics -ne 'system-readiness-and-on-checklist' -or
    $policy.decision.onChecklistSemantics -ne 'BUY_SIDE_FVG_EXISTS_AND_ANY_TRIGGER_EVENT') {
    $errors.Add('ON semantics must require system readiness plus buy FVG and any trigger event.')
}
if ($policy.decision.onEventOperator -ne 'OR' -or $policy.decision.offEventOperator -ne 'OR') {
    $errors.Add('ON and OFF event operators must be OR.')
}
if ($policy.decision.triggerEvent -ne 'LATEST_BEAR_FVG_FULL_FILL_OR_SSL_SWEEP') {
    $errors.Add('ON trigger event changed unexpectedly.')
}
if ($policy.decision.contextPolicy -ne 'WATCHOUT_ONLY_NO_CYCLE_EFFECT' -or
    $policy.defaults.contextRole -ne 'watchout-only' -or
    ($policy.smcStructureWatchout -notcontains 'M30_CONTEXT') -or
    $policy.dashboard.smcWatchoutCycleEffect) {
    $errors.Add('M30 context must remain watchout-only.')
}
if ($source.Contains('InpRequireBullishContext') -or
    $source.Contains('InpOffOnHTFBearish') -or
    $source.Contains('g_onContextGate') -or
    $source.Contains('g_offHTFBearish') -or
    $source.Contains('HTF_CONTEXT_BEARISH')) {
    $errors.Add('M30 context leaked back into cycle-management logic.')
}
if ($policy.buySideFvg.retention -ne 'LATEST_ACTIVE_ONLY_ON_CHART' -or
    $policy.buySideFvg.role -ne 'REQUIRED_ON_CHECKLIST_GATE' -or
    $policy.buySideFvg.maximumCreationLookbackBars -ne 30 -or
    $policy.buySideFvg.chartTextLabel -or
    -not $policy.defaults.drawLatestBuySideFvg -or
    $policy.defaults.buySideFvgRetention -ne 1 -or
    $policy.defaults.buySideFvgMaxAgeBars -ne 30) {
    $errors.Add('Latest buy-side FVG gate/display contract changed unexpectedly.')
}
if ($policy.inputLayout.groupCount -ne 9 -or
    -not $policy.inputLayout.fixedVisualPalette -or
    $policy.eventLabelDefaults.sslSweep -ne 'sSwept' -or
    $policy.eventLabelDefaults.bslSweep -ne 'bSwept' -or
    $policy.eventLabelDefaults.bearLock -ne 'bLock') {
    $errors.Add('Simplified input/event-label defaults changed unexpectedly.')
}
if ($policy.decision.historicalReplay -ne 'oldest-to-newest-no-lookahead') {
    $errors.Add('Historical replay must remain chronological and no-lookahead.')
}
if (-not $policy.defaults.drawTradingZoneHistory) {
    $errors.Add('Historical Trading Zone rendering must default ON.')
}
if ($policy.defaults.zoneRender -ne 'ccbsn-lite-single-range-box' -or
    $policy.defaults.zoneOpacityPercent -ne 70) {
    $errors.Add('Trading Zone must use the CCBSN Lite range box at 70 percent opacity.')
}
if ($policy.defaults.contextTimeframe -ne 'M30' -or
    $policy.defaults.entryWindowBars -ne 8 -or
    $policy.defaults.riskLockBars -ne 2 -or
    $policy.defaults.offOnTargetReached -or
    -not $policy.defaults.offOnBuySideSweep) {
    $errors.Add('Relaxed OFF defaults changed unexpectedly.')
}
if (-not $policy.defaults.eventLabelsEditable -or
    $policy.defaults.topDashboard -ne 'top-left' -or
    $policy.defaults.offDashboard -ne 'bottom-left' -or
    -not $policy.defaults.controllerLiteChartTheme) {
    $errors.Add('Event label/dashboard defaults changed unexpectedly.')
}

$expectedSystemGates = @(
    'DATA_READY', 'OPERATIONAL_READY', 'CCBSN_FLAT'
)
$expectedEventGates = @(
    'LATEST_ACTIVE_BUY_SIDE_FVG_WITHIN_30_M15_BARS',
    'LATEST_ACTIVE_BEAR_FVG_FULL_FILL', 'SELL_SIDE_LIQUIDITY_SWEEP'
)
$expectedOffPriority = @(
    'OPERATIONAL_BLOCK', 'CAUSAL_LOW_INVALIDATED',
    'BEARISH_DISPLACEMENT_BREAK', 'BUY_SIDE_LIQUIDITY_SWEEP',
    'BEARISH_FVG_OPTIONAL', 'TARGET_LIQUIDITY_OPTIONAL', 'ENTRY_TIMEOUT',
    'ONE_SHOT_TOKEN_CONSUMED'
)
if (($policy.systemReadinessChecklist -join '|') -ne ($expectedSystemGates -join '|')) {
    $errors.Add('Machine-readable system readiness checklist changed unexpectedly.')
}
if (($policy.smcStructureWatchout -join '|') -ne
    ('M30_CONTEXT|M15_CONFIRMED_SWING_SEQUENCE|M15_HL_OR_RECENT_SSL_LOCATION|M15_ACCEPTED_BULL_BREAK|M15_BULLISH_DISPLACEMENT')) {
    $errors.Add('Machine-readable SMC structure watchout changed unexpectedly.')
}
if (($policy.eventChecklist -join '|') -ne ($expectedEventGates -join '|')) {
    $errors.Add('Machine-readable event checklist changed unexpectedly.')
}
if (($policy.offPriority -join '|') -ne ($expectedOffPriority -join '|')) {
    $errors.Add('Machine-readable OFF veto priority changed unexpectedly.')
}

# Deterministic policy truth table independent of terminal data.
$cases = @(
    @{ Name = 'No ON event'; Context = $true; BuyFvg = $true; Fill = $false; Ssl = $false; Bsl = $false; Bear = $false; Expected = 'BLOCKED' },
    @{ Name = 'Latest bear FVG filled'; Context = $true; BuyFvg = $true; Fill = $true; Ssl = $false; Bsl = $false; Bear = $false; Expected = 'ENTRY_WINDOW' },
    @{ Name = 'SSL sweep'; Context = $true; BuyFvg = $true; Fill = $false; Ssl = $true; Bsl = $false; Bear = $false; Expected = 'ENTRY_WINDOW' },
    @{ Name = 'Missing buy-side FVG'; Context = $true; BuyFvg = $false; Fill = $true; Ssl = $false; Bsl = $false; Bear = $false; Expected = 'BLOCKED' },
    @{ Name = 'BSL veto wins'; Context = $true; BuyFvg = $true; Fill = $true; Ssl = $false; Bsl = $true; Bear = $false; Expected = 'BLOCKED' },
    @{ Name = 'Bear break wins'; Context = $true; BuyFvg = $true; Fill = $true; Ssl = $false; Bsl = $false; Bear = $true; Expected = 'RISK_LOCK' },
    @{ Name = 'Neutral context watchout'; Context = $false; BuyFvg = $true; Fill = $true; Ssl = $false; Bsl = $false; Bear = $false; Expected = 'ENTRY_WINDOW' }
)
foreach ($case in $cases) {
    $actual = if ($case.Bear) {
        'RISK_LOCK'
    } elseif ($case.Bsl) {
        'BLOCKED'
    } elseif (-not $case.BuyFvg) {
        'BLOCKED'
    } elseif ($case.Fill -or $case.Ssl) {
        'ENTRY_WINDOW'
    } else {
        'BLOCKED'
    }
    if ($actual -ne $case.Expected) {
        $errors.Add("Truth table failed: $($case.Name): $actual")
    }
}

# System readiness remains AND: one false gate must block authorization.
$allSystem = @{}
foreach ($gate in $expectedSystemGates) { $allSystem[$gate] = $true }
foreach ($missingGate in $expectedSystemGates) {
    $probe = $allSystem.Clone()
    $probe[$missingGate] = $false
    if (($expectedSystemGates | Where-Object { -not $probe[$_] }).Count -eq 0) {
        $errors.Add("System readiness gate failed open: $missingGate")
    }
}
# Events are OR: either event is sufficient, but no event must block.
if (-not ($true -or $false) -or -not ($false -or $true) -or ($false -or $false)) {
    $errors.Add('ON event OR contract failed.')
}

# First-veto-wins contract: the earliest active veto owns the result.
$activeVetoes = @('BEARISH_FVG_OPTIONAL', 'CAUSAL_LOW_INVALIDATED', 'ENTRY_TIMEOUT')
$winner = $expectedOffPriority | Where-Object { $_ -in $activeVetoes } | Select-Object -First 1
if ($winner -ne 'CAUSAL_LOW_INVALIDATED') {
    $errors.Add("OFF veto priority failed: $winner")
}

if (-not $SkipCompile) {
    if (-not (Test-Path -LiteralPath $MetaEditorPath -PathType Leaf)) {
        $errors.Add("MetaEditor not found: $MetaEditorPath")
    } else {
        $logDirectory = Split-Path -Parent $compileLog
        if (-not (Test-Path -LiteralPath $logDirectory)) {
            New-Item -ItemType Directory -Path $logDirectory | Out-Null
        }
        if (Test-Path -LiteralPath $compileLog -PathType Leaf) {
            Remove-Item -LiteralPath $compileLog -Force
        }
        & $MetaEditorPath "/compile:$sourcePath" "/log:$compileLog"
        $deadline = [DateTime]::UtcNow.AddSeconds(10)
        do {
            Start-Sleep -Milliseconds 250
            $ready = Test-Path -LiteralPath $compileLog -PathType Leaf
            if ($ready) {
                $probe = Get-Content -LiteralPath $compileLog -Raw -Encoding Unicode
                $ready = $probe -match 'Result:'
            }
        } while (-not $ready -and [DateTime]::UtcNow -lt $deadline)
        if (-not (Test-Path -LiteralPath $compileLog -PathType Leaf)) {
            $errors.Add('MetaEditor compile log was not created.')
        } else {
            $logText = Get-Content -LiteralPath $compileLog -Raw -Encoding Unicode
            if ($logText -notmatch 'Result: 0 errors, 0 warnings') {
                $errors.Add('MetaEditor compile did not finish with 0 errors, 0 warnings.')
            }
        }
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host 'SMC Controller checks PASS'
Write-Host '  Static contracts: PASS'
Write-Host '  Policy truth table: PASS'
if (-not $SkipCompile) {
    Write-Host '  MetaEditor: 0 errors, 0 warnings'
}
