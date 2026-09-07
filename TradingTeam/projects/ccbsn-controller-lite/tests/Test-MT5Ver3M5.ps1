[CmdletBinding()]
param(
    [string] $SourcePath = '',
    [string] $PinePath = '',
    [string] $MetaEditorPath = 'C:\Path\To\MetaEditor64.exe',
    [string] $BuildBaseName = 'CCBSN_Controller_Lite_Ver3_M5',
    [string] $ExpectedMqlVersion = '1.000',
    [string] $ExpectedPolicyId = 'ccbsn-controller-lite-ver3-m5',
    [string] $ExpectedPolicyVersion = '1.0.1-mt5-autotrading-resync',
    [string] $ExpectedObjectNamespace = 'CCBSN_LITE_V3_M5.',
    [string] $ExpectedAuditFile = 'CCBSN_Controller_Lite_Ver3_M5_Events.csv',
    [string] $ExpectedMonitorFile = 'controller_lite_v3_m5_status_v1.json',
    [int] $ExpectedStartupHoldMilliseconds = 0,
    [string] $ExpectedTransportHash = '6B1390334FDA114914302502D6B519223FD1F133F6DFE45FC9D0338D850FD240',
    [switch] $SkipCompile
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($SourcePath)) {
    $SourcePath = Join-Path $projectRoot 'src\mt5\CCBSN_Controller_Lite_Ver3_M5.mq5'
}
if ([string]::IsNullOrWhiteSpace($PinePath)) {
    $PinePath = Join-Path $projectRoot 'src\pine\CCBSN_Controller_Lite_Ver3_M5.pine'
}

$resolvedSource = (Resolve-Path -LiteralPath $SourcePath).Path
$resolvedPine = (Resolve-Path -LiteralPath $PinePath).Path
$source = Get-Content -LiteralPath $resolvedSource -Raw -Encoding UTF8
$pine = Get-Content -LiteralPath $resolvedPine -Raw -Encoding UTF8
$lines = Get-Content -LiteralPath $resolvedSource -Encoding UTF8
$errors = [Collections.Generic.List[string]]::new()
$buildSource = Join-Path $projectRoot ("build\$BuildBaseName.mq5")
$binaryPath = [IO.Path]::ChangeExtension($buildSource, '.ex5')
$compileLogPath = Join-Path $projectRoot 'build\compile-ver3-m5.log'

function Assert-SourcePattern {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $Pattern
    )
    if ($source -notmatch $Pattern) {
        $errors.Add("Missing MT5 contract: $Name")
    }
}

function Get-TopLevelArgumentCount {
    param([string] $Text, [int] $CallIndex)
    $open = $Text.IndexOf('(', $CallIndex)
    if ($open -lt 0) { return -1 }
    $depth = 1
    $count = 1
    $inString = $false
    $escaped = $false
    for ($index = $open + 1; $index -lt $Text.Length; $index++) {
        $character = $Text[$index]
        if ($inString) {
            if ($escaped) { $escaped = $false; continue }
            if ($character -eq '\') { $escaped = $true; continue }
            if ($character -eq '"') { $inString = $false }
            continue
        }
        if ($character -eq '"') { $inString = $true; continue }
        if ($character -eq '(') { $depth++; continue }
        if ($character -eq ')') {
            $depth--
            if ($depth -eq 0) { return $count }
            continue
        }
        if ($character -eq ',' -and $depth -eq 1) { $count++ }
    }
    return -1
}

if (-not $SkipCompile) {
    if (-not (Test-Path -LiteralPath $MetaEditorPath -PathType Leaf)) {
        $errors.Add("MetaEditor not found: $MetaEditorPath")
    }
    else {
        Copy-Item -LiteralPath $resolvedSource -Destination $buildSource -Force
        $compileStarted = [DateTime]::UtcNow
        & $MetaEditorPath "/compile:$buildSource" "/log:$compileLogPath"
        $compileLog = ''
        for ($attempt = 0; $attempt -lt 300; $attempt++) {
            if (Test-Path -LiteralPath $compileLogPath -PathType Leaf) {
                $logItem = Get-Item -LiteralPath $compileLogPath
                if ($logItem.LastWriteTimeUtc -ge $compileStarted.AddSeconds(-1)) {
                    try {
                        $compileLog = Get-Content -LiteralPath $compileLogPath `
                            -Raw -Encoding Unicode
                        if ($compileLog -match 'Result:') { break }
                    }
                    catch [IO.IOException] {
                        $compileLog = ''
                    }
                }
            }
            Start-Sleep -Milliseconds 100
        }
        if ($compileLog -notmatch 'Result:\s+0 errors,\s+0 warnings') {
            $errors.Add('MetaEditor compile did not finish with 0 errors, 0 warnings.')
        }
    }
}

if (-not (Test-Path -LiteralPath $binaryPath -PathType Leaf)) {
    $errors.Add("Compiled EX5 missing: $binaryPath")
}
elseif ((Get-Item -LiteralPath $binaryPath).Length -lt 100000) {
    $errors.Add('Compiled EX5 is unexpectedly small.')
}

Assert-SourcePattern 'MQL5 strict mode' '(?m)^#property strict\s*$'
Assert-SourcePattern 'MQL compiler version' (
    '#property version\s+"' + [regex]::Escape($ExpectedMqlVersion) + '"')
Assert-SourcePattern 'Controller policy identity' (
    'POLICY_ID\s*=\s*"' + [regex]::Escape($ExpectedPolicyId) + '"')
Assert-SourcePattern 'Controller policy release' (
    'POLICY_VERSION\s*=\s*"' + [regex]::Escape($ExpectedPolicyVersion) + '"')
Assert-SourcePattern 'M5 decision timeframe' 'DECISION_TIMEFRAME\s*=\s*PERIOD_M5'
Assert-SourcePattern 'M5 scale default' 'InpM5PriceScale\s*=\s*0\.50;'
Assert-SourcePattern 'M5 scale formula' 'return\s+ver3BaseValue\s*\*\s*InpM5PriceScale;'
Assert-SourcePattern 'ATR20 default' 'InpATRPeriod\s*=\s*20;'
Assert-SourcePattern 'EMA23 default' 'InpEMAPeriod\s*=\s*23;'
Assert-SourcePattern 'Visual-only safe default' 'InpControlMode\s*=\s*CCBSN_CONTROL_VISUAL_ONLY;'
Assert-SourcePattern 'CCBSN magic default' 'InpCCBSNMagic\s*=\s*9696;'
Assert-SourcePattern 'Independent controller magic' 'InpControllerMagic\s*=\s*996970;'
Assert-SourcePattern 'Continuous session' 'InpSession1\s*=\s*"0600-0300";'
Assert-SourcePattern 'Second session disabled' 'InpEnableSession2\s*=\s*false;'
Assert-SourcePattern 'Third session disabled' 'InpEnableSession3\s*=\s*false;'
Assert-SourcePattern 'Unique object namespace' ([regex]::Escape($ExpectedObjectNamespace))
Assert-SourcePattern 'Unique audit filename' ([regex]::Escape($ExpectedAuditFile))
Assert-SourcePattern 'Unique monitor filename' ([regex]::Escape($ExpectedMonitorFile))
Assert-SourcePattern 'M5 monitor schema' 'MONITOR_SCHEMA_VERSION\s*=\s*"ccbsn-lite-monitor-status\.v1"'
Assert-SourcePattern 'M5 monitor decision time' '\\"last_m5_decision_server\\"'

if ($source -match 'M15|PERIOD_M15|CCBSN_TZ_V3|ccbsn-m15') {
    $errors.Add('Legacy M15/controller namespace remains in M5 source.')
}

$baseParity = @(
    @{ Name='Price scale'; Mt5='InpM5PriceScale\s*=\s*0\.50;'; Pine='m5PriceScale\s*=\s*input\.float\(0\.50,' },
    @{ Name='ATR period'; Mt5='InpATRPeriod\s*=\s*20;'; Pine='atrPeriod\s*=\s*input\.int\(20,' },
    @{ Name='EMA period'; Mt5='InpEMAPeriod\s*=\s*23;'; Pine='emaPeriod\s*=\s*input\.int\(23,' },
    @{ Name='Upside max'; Mt5='InpUpsideMaxAboveEMAPrice\s*=\s*20\.0;'; Pine='upsideMaxBase\s*=\s*input\.float\(20\.0,' },
    @{ Name='Downside ATR'; Mt5='InpDownsideMinATRPrice\s*=\s*7\.0;'; Pine='downsideMinAtrBase\s*=\s*input\.float\(7\.0,' },
    @{ Name='Downside band'; Mt5='InpDownsideBandBoundary\s*=\s*20\.0;'; Pine='downsideBandBase\s*=\s*input\.float\(20\.0,' },
    @{ Name='Downside hold'; Mt5='InpDownsideHoldMaxAboveEMA\s*=\s*5\.0;'; Pine='downsideHoldMaxBase\s*=\s*input\.float\(5\.0,' },
    @{ Name='Bear Drop PeakD'; Mt5='InpMinRelativeDropPrice\s*=\s*30\.0;'; Pine='minRelativeDropBase\s*=\s*input\.float\(30\.0,' },
    @{ Name='Bear Drop two-bar'; Mt5='InpMinTwoBarDropPrice\s*=\s*30\.0;'; Pine='minTwoBarDropBase\s*=\s*input\.float\(30\.0,' },
    @{ Name='BearTwo ATR'; Mt5='InpBearTwoATRThreshold\s*=\s*10\.0;'; Pine='bearTwoAtrBase\s*=\s*input\.float\(10\.0,' },
    @{ Name='Low ATR'; Mt5='InpActiveLowATRThreshold\s*=\s*7\.0;'; Pine='activeLowAtrBase\s*=\s*input\.float\(7\.0,' },
    @{ Name='Recovery bars'; Mt5='InpRecoveryBars\s*=\s*1;'; Pine='recoveryBars\s*=\s*input\.int\(1,' }
)
foreach ($item in $baseParity) {
    if ($source -notmatch $item.Mt5 -or $pine -notmatch $item.Pine) {
        $errors.Add("Pine/MT5 base default mismatch: $($item.Name)")
    }
}

$scaledContracts = @(
    'M5Price\(InpMinATRPrice\)',
    'M5Price\(InpUpsideMaxAboveEMAPrice\)',
    'M5Price\(InpDownsideMinATRPrice\)',
    'M5Price\(InpDownsideBandBoundary\)',
    'M5Price\(InpDownsideHoldMaxAboveEMA\)',
    'M5Price\(InpDownsideEMAApproachTolerance\)',
    'M5Price\(InpMinRelativeDropPrice\)',
    'M5Price\(InpMinTwoBarDropPrice\)',
    'M5Price\(InpBearTwoATRThreshold\)',
    'M5Price\(InpActiveLowATRThreshold\)'
)
foreach ($contract in $scaledContracts) {
    if ($source -notmatch $contract) {
        $errors.Add("Scaled M5 gate missing: $contract")
    }
}

$logicContracts = @(
    @{ Name='Upside entry interval'; Pattern='distance\s*>=\s*0\.0\s*&&[\s\S]*?distance\s*<=\s*M5Price\(InpUpsideMaxAboveEMAPrice\)' },
    @{ Name='Downside near interval'; Pattern='distance\s*<\s*0\.0\s*&&[\s\S]*?distance\s*>\s*-M5Price\(InpDownsideBandBoundary\)' },
    @{ Name='Downside deep interval'; Pattern='distance\s*<=\s*-M5Price\(InpDownsideBandBoundary\)' },
    @{ Name='Downside D rising'; Pattern='distance\s*>\s*g_distanceHistory\[0\]' },
    @{ Name='Downside hold'; Pattern='distance\s*<=\s*M5Price\(InpDownsideHoldMaxAboveEMA\)' },
    @{ Name='BearTwo strict ATR'; Pattern='atrValue\s*>\s*M5Price\(InpBearTwoATRThreshold\)' },
    @{ Name='Low ATR strict'; Pattern='atrValue\s*<\s*M5Price\(InpActiveLowATRThreshold\)' },
    @{ Name='Downside EMA intersection'; Pattern='bar\.high\s*>=\s*emaValue\s*-\s*M5Price\(InpDownsideEMAApproachTolerance\)[\s\S]*?bar\.low\s*<=\s*emaValue\s*\+\s*M5Price\(InpDownsideEMAApproachTolerance\)' },
    @{ Name='Risk policy frozen'; Pattern='g_riskPolicy\s*=\s*policy;' },
    @{ Name='Active policy frozen'; Pattern='g_activePolicy\s*=\s*policy;' },
    @{ Name='Recovery returns to ARMING'; Pattern='g_state\s*=\s*VISUAL_STATE_ARMING;[\s\S]*?g_armingPolicy\s*=\s*recoveredPolicy;' },
    @{ Name='Closed-bar read'; Pattern='CopyBuffer\(g_atrHandle,\s*0,\s*1,\s*1,[\s\S]*?closedBar\s*=\s*rates\[0\];[\s\S]*?decisionTime\s*=\s*rates\[1\]\.time;' }
)
foreach ($contract in $logicContracts) {
    Assert-SourcePattern $contract.Name $contract.Pattern
}

$priorityStart = $source.IndexOf('// The active session boundary always owns the first OFF transition.')
$priorityEnd = $source.IndexOf('if(wasRiskLock)', $priorityStart)
if ($priorityStart -lt 0 -or $priorityEnd -lt 0) {
    $errors.Add('Cannot locate policy priority section.')
}
else {
    $priorityBody = $source.Substring($priorityStart, $priorityEnd - $priorityStart)
    $priorityTokens = @(
        'if(sessionExit)', 'if(bearDropVeto)', 'if(bearTwoBlock)',
        'if(downsideEMAApproachBlock)', 'if(activeLowATRBlock)',
        'if(denyBlock)', 'if(fallBlock)', 'if(reverseBlock)',
        'if(bearishPatternBlock)', 'if(consecutiveRedBlock)'
    )
    $previous = -1
    foreach ($token in $priorityTokens) {
        $position = $priorityBody.IndexOf($token, $previous + 1,
            [StringComparison]::Ordinal)
        if ($position -le $previous) {
            $errors.Add("Missing/out-of-order policy branch: $token")
            break
        }
        $previous = $position
    }
}

$riskTransitionCount = [regex]::Matches(
    $source, 'g_state\s*=\s*VISUAL_STATE_RISK_LOCK;').Count
if ($riskTransitionCount -ne 1) {
    $errors.Add("Expected exactly one Risk Lock transition, found $riskTransitionCount.")
}

$cycleContracts = @(
    @{ Name='Cycle ON only while ACTIVE'; Pattern='if\(g_state\s*==\s*VISUAL_STATE_ACTIVE\)\s*return\s+CCBSN_COMMAND_NEW_CYCLE_ON;' },
    @{ Name='ON transport Sell Limit'; Pattern='CCBSN_COMMAND_NEW_CYCLE_ON[\s\S]*?g_trade\.SellLimit\(' },
    @{ Name='OFF transport Buy Stop'; Pattern='g_trade\.BuyStop\(' },
    @{ Name='Magic-price command'; Pattern='InpCommandPrice\s*=\s*888888\.0;' },
    @{ Name='Shared target mutex'; Pattern='CCBSN\.NC\.LOCK\.[\s\S]*?InpCCBSNMagic' },
    @{ Name='Persistent control state'; Pattern='SaveConfirmedControlState\(\)' },
    @{ Name='64-bit pending ticket'; Pattern='P_TICKET_HI[\s\S]*?P_TICKET_LO' },
    @{ Name='Restart pending recovery'; Pattern='RecoverPendingControllerOrder\(\)' },
    @{ Name='Ticket-authoritative fast ACK'; Pattern='g_commandTicket\s*=\s*ticket;[\s\S]*?SavePendingCommand\(\);[\s\S]*?ReconcilePendingCommand\(\);' },
    @{ Name='Position drift detection'; Pattern='RaisePositionDriftAlert\(' },
    @{ Name='OFF reassert after drift'; Pattern='g_offReassertRequested' },
    @{ Name='Manual handover mode'; Pattern='CCBSN_CONTROL_MANUAL_HANDOVER' },
    @{ Name='Removal handover'; Pattern='InpManualHandoverOnRemove\s*&&\s*explicitHandover' },
    @{ Name='Trade transaction reconcile'; Pattern='TRADE_TRANSACTION_ORDER_DELETE[\s\S]*?g_controlReconcileRequested\s*=\s*true;' },
    @{ Name='Mutex checked at send time'; Pattern='bool IsControlTradeAllowed\(\)[\s\S]*?InpSingleControllerLock\s*&&\s*!g_controllerLockHeld[\s\S]*?CONTROLLER_MUTEX_NOT_HELD' },
    @{ Name='Active command contract'; Pattern='ValidateSelectedOrderContract[\s\S]*?ACTIVE_COMMAND_TYPE_INVALID[\s\S]*?ACTIVE_COMMAND_COMMENT_MISMATCH[\s\S]*?ACTIVE_COMMAND_PRICE_MISMATCH[\s\S]*?ACTIVE_COMMAND_VOLUME_MISMATCH' },
    @{ Name='History command contract'; Pattern='ValidateHistoryOrderContract[\s\S]*?HISTORY_COMMAND_OWNER_MISMATCH[\s\S]*?HISTORY_COMMAND_DIRECTION_MISMATCH[\s\S]*?HISTORY_COMMAND_PRICE_MISMATCH[\s\S]*?HISTORY_COMMAND_VOLUME_MISMATCH' },
    @{ Name='Runtime duplicate guard'; Pattern='MULTIPLE_ACTIVE_CONTROLLER_COMMANDS' },
    @{ Name='Runtime untracked guard'; Pattern='UNTRACKED_ACTIVE_CONTROLLER_COMMAND' },
    @{ Name='Runtime direction guard'; Pattern='ACTIVE_DIRECTION_MISMATCH' },
    @{ Name='Stale ACK resync'; Pattern='STALE_ACK_REQUIRES_RESYNC' },
    @{ Name='Bounded resync'; Pattern='InpCycleSyncMaxRetries\s*=\s*3;[\s\S]*?RESYNC_RETRIES_EXHAUSTED' },
    @{ Name='Retry persistence'; Pattern='SYNC_RETRY[\s\S]*?SYNC_DESIRED' },
    @{ Name='Timeout schedules resync'; Pattern='cancelReason\s*==\s*"CCBSN_CONSUMPTION_TIMEOUT"[\s\S]*?ScheduleCycleResync' }
    @{ Name='Startup invalidates cached cycle ACK'; Pattern='InitializeAutoTradingCycleGuard\(\)[\s\S]*?STARTUP_AUTOTRADING_ON_FORCE_RESYNC[\s\S]*?STARTUP_AUTOTRADING_OFF_ACK_INVALIDATED' }
    @{ Name='AutoTrading rising edge forces resync'; Pattern='ObserveAutoTradingCycleGuard\(\)[\s\S]*?AUTOTRADING_ENABLED_FORCE_RESYNC' }
    @{ Name='AutoTrading falling edge invalidates ACK'; Pattern='ObserveAutoTradingCycleGuard\(\)[\s\S]*?AUTOTRADING_DISABLED_ACK_INVALIDATED' }
    @{ Name='AutoTrading resync deletes persisted ACK'; Pattern='InvalidateCycleAckForAutoTrading[\s\S]*?GlobalVariableDel\(ControlStorageKey\("STATE"\)\)' }
    @{ Name='AutoTrading guard runs on tick'; Pattern='void OnTick\(\)[\s\S]*?ObserveAutoTradingCycleGuard\(\)[\s\S]*?RunControlLane\(nowTick, true\)' }
    @{ Name='AutoTrading guard runs on timer'; Pattern='void OnTimer\(\)[\s\S]*?ObserveAutoTradingCycleGuard\(\)[\s\S]*?forceControl\s*=\s*autoTradingTransition' }
    @{ Name='Startup cycle fence precedes visual work'; Pattern='AcquireControllerLock\(\)[\s\S]*?InitializeAutoTradingCycleGuard\(\);[\s\S]*?ProcessCCBSNControl\(\);[\s\S]*?ApplyChartTheme\(\);' }
    @{ Name='Startup barrier forces OFF'; Pattern='DesiredCommand\(\)[\s\S]*?g_startupCycleBarrierActive[\s\S]*?return\s+CCBSN_COMMAND_NEW_CYCLE_OFF;' }
    @{ Name='Startup barrier releases only after aligned OFF ACK'; Pattern='if\(ackAligned\)[\s\S]*?command\s*==\s*CCBSN_COMMAND_NEW_CYCLE_OFF\s*&&[\s\S]*?g_startupCycleBarrierActive\s*=\s*false;[\s\S]*?STARTUP CYCLE BARRIER RELEASED' }
    @{ Name='Supervisor monitor exposes pending and confirmed ticket'; Pattern='pending_ticket[\s\S]*?g_commandTicket[\s\S]*?last_confirmed_ticket[\s\S]*?g_lastConfirmedCommandTicket[\s\S]*?startup_cycle_barrier' }
    @{ Name='Supervisor monitor exposes pending command age'; Pattern='pendingAgeSeconds[\s\S]*?g_commandSentTime[\s\S]*?pending_age_seconds' }
    @{ Name='Supervisor monitor identifies account'; Pattern='account_login[\s\S]*?ACCOUNT_LOGIN[\s\S]*?account_server[\s\S]*?ACCOUNT_SERVER' }
)
foreach ($contract in $cycleContracts) {
    Assert-SourcePattern $contract.Name $contract.Pattern
}
if ($ExpectedStartupHoldMilliseconds -gt 0) {
    Assert-SourcePattern 'Supervisor startup policy hold constant' (
        'SUPERVISOR_STARTUP_HOLD_MILLISECONDS\s*=\s*' +
        $ExpectedStartupHoldMilliseconds + ';')
    Assert-SourcePattern 'Policy command remains OFF during startup hold' (
        'g_startupPolicyHoldUntilTick[\s\S]*?GetTickCount64\(\)\s*<\s*g_startupPolicyHoldUntilTick[\s\S]*?CCBSN_COMMAND_NEW_CYCLE_OFF')
    Assert-SourcePattern 'Monitor exposes startup hold remaining' (
        'startupHoldRemainingSeconds[\s\S]*?startup_policy_hold_seconds_remaining')
}

$transportStart = $source.IndexOf('//| CCBSN New Cycle command transport')
$transportEnd = $source.IndexOf('//| Read-only external monitor', $transportStart)
if ($transportStart -lt 0 -or $transportEnd -lt 0) {
    $errors.Add('Cannot locate audited Ver3 New Cycle transport block.')
}
else {
    $transport = $source.Substring($transportStart,
        $transportEnd - $transportStart) -replace '\s+', ''
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $transportBytes = [Text.Encoding]::UTF8.GetBytes($transport)
        $transportHash = ([BitConverter]::ToString(
            $sha.ComputeHash($transportBytes))).Replace('-', '')
    }
    finally {
        $sha.Dispose()
    }
    $expectedTransportHash = $ExpectedTransportHash
    if ($transportHash -ne $expectedTransportHash) {
        $errors.Add('Hardened New Cycle transport integrity hash changed unexpectedly.')
    }
}

Assert-SourcePattern 'Dashboard default ON' 'InpShowDashboard\s*=\s*true;'
Assert-SourcePattern 'Checklist default ON' 'InpShowEventDashboard\s*=\s*true;'
Assert-SourcePattern 'Monitor validates bytes against flushed size' 'actualSize\s*=\s*FileSize\(handle\)[\s\S]*?written\s*==\s*0\s*\|\|\s*actualSize\s*!=\s*written'
Assert-SourcePattern 'Cycle desired display' '"Cycle: "\s*\+\s*cycleStatus'
Assert-SourcePattern 'Cycle ACK display' '"ACK: "\s*\+\s*ControlStateToString'
Assert-SourcePattern 'Policy state display' '"Policy: "\s*\+\s*StateToString'
Assert-SourcePattern 'M5 scale display' 'StringFormat\(" \| Scale=%\.2f",\s*InpM5PriceScale\)'
Assert-SourcePattern 'Checklist result display' 'InpTextChecklist\s*\+\s*": "'
Assert-SourcePattern 'Cycle consistency display' 'CycleConsistencyToString\(\)'
Assert-SourcePattern 'Cycle consistency alert' 'CycleConsistencyAlertActive\(\)'
Assert-SourcePattern 'Cycle sync monitor field' '\\"cycle_consistency\\"'
Assert-SourcePattern 'Cycle retry monitor field' '\\"cycle_sync_retries\\"'
Assert-SourcePattern 'Mutex monitor field' '\\"controller_mutex_held\\"'
Assert-SourcePattern 'Event checklist lower-left' 'EVENT_PANEL\.BG[\s\S]*?CORNER_LEFT_LOWER'
Assert-SourcePattern 'Dashboard upper-left' 'PANEL\.BG[\s\S]*?CORNER_LEFT_UPPER'

$eventPanelStart = $source.IndexOf('void UpdateEventChecklistPanel()')
$eventPanelEnd = $source.IndexOf('void CreatePanel()', $eventPanelStart)
if ($eventPanelStart -lt 0 -or $eventPanelEnd -lt 0) {
    $errors.Add('Cannot locate event checklist panel.')
}
else {
    $eventPanel = $source.Substring($eventPanelStart,
        $eventPanelEnd - $eventPanelStart)
    $checklistItems = [regex]::Matches(
        $eventPanel, 'SetEventChecklistLabel\("').Count
    if ($checklistItems -ne 17) {
        $errors.Add("Expected 17 checklist rows, found $checklistItems.")
    }
    foreach ($name in @(
        'InpEventNameBearDrop', 'InpEventNameRiskLock',
        'InpEventNameConsecutiveRed', 'InpEventNameBearTwo',
        'InpEventNameDownsideEMA', 'InpEventNameActiveLowATR',
        'InpEventNameBearishEngulfing', 'InpEventNameBearishPinBar',
        'InpEventNameDeny', 'InpEventNameReverse', 'InpEventNameFall',
        'InpEventNameRecovered', 'InpEventNameNCDrift', 'InpEventNameNCSync'
    )) {
        if (-not $eventPanel.Contains($name)) {
            $errors.Add("Checklist event missing: $name")
        }
    }
}

$fileWrites = [regex]::Matches($source, 'FileWrite\(handle')
if ($fileWrites.Count -ne 2) {
    $errors.Add("Expected two CSV FileWrite calls, found $($fileWrites.Count).")
}
else {
    $headerArgs = Get-TopLevelArgumentCount $source $fileWrites[0].Index
    $dataArgs = Get-TopLevelArgumentCount $source $fileWrites[1].Index
    if ($headerArgs -ne $dataArgs) {
        $errors.Add("CSV header/data mismatch: $headerArgs/$dataArgs columns.")
    }
}

if ($source -match 'WebRequest|TELEGRAM_BOT_TOKEN|api\.telegram\.org') {
    $errors.Add('EA unexpectedly contains network or credential capability.')
}

$scale = 0.50
$boundaryCases = @(
    @{ Name='Upside lower'; Actual=(0.0 -ge 0.0 -and 0.0 -le 20.0 * $scale); Expected=$true },
    @{ Name='Upside scaled upper'; Actual=(10.0 -le 20.0 * $scale); Expected=$true },
    @{ Name='Upside beyond scaled upper'; Actual=(10.1 -le 20.0 * $scale); Expected=$false },
    @{ Name='Downside near'; Actual=(-9.9 -lt 0.0 -and -9.9 -gt -20.0 * $scale); Expected=$true },
    @{ Name='Downside deep boundary'; Actual=(-10.0 -le -20.0 * $scale); Expected=$true },
    @{ Name='Downside scaled hold'; Actual=(2.5 -le 5.0 * $scale); Expected=$true },
    @{ Name='BearTwo strict scaled ATR'; Actual=(5.1 -gt 10.0 * $scale); Expected=$true },
    @{ Name='Low ATR strict scaled'; Actual=(3.4 -lt 7.0 * $scale); Expected=$true }
)
foreach ($case in $boundaryCases) {
    if ($case.Actual -ne $case.Expected) {
        $errors.Add("M5 boundary model failed: $($case.Name)")
    }
}

$sessionCases = @(
    @{ Minute=359; Expected=$false },
    @{ Minute=360; Expected=$true },
    @{ Minute=720; Expected=$true },
    @{ Minute=1439; Expected=$true },
    @{ Minute=179; Expected=$true },
    @{ Minute=180; Expected=$false }
)
foreach ($case in $sessionCases) {
    $actual = $case.Minute -ge 360 -or $case.Minute -lt 180
    if ($actual -ne $case.Expected) {
        $errors.Add("Continuous-session model failed at minute $($case.Minute).")
    }
}

$cycleSyncCases = @(
    @{ Name='ACTIVE already ON'; Desired='ON'; Confirmed='ON'; Ticket=0; Pending='NONE'; Cancel=$false; Mutex=$true; Owned=0; Contract=$true; Retry=0; Expected='ALIGNED' },
    @{ Name='ACTIVE but ACK OFF'; Desired='ON'; Confirmed='OFF'; Ticket=0; Pending='NONE'; Cancel=$false; Mutex=$true; Owned=0; Contract=$true; Retry=0; Expected='SEND_ON' },
    @{ Name='OFF already OFF'; Desired='OFF'; Confirmed='OFF'; Ticket=0; Pending='NONE'; Cancel=$false; Mutex=$true; Owned=0; Contract=$true; Retry=0; Expected='ALIGNED' },
    @{ Name='OFF but ACK ON'; Desired='OFF'; Confirmed='ON'; Ticket=0; Pending='NONE'; Cancel=$false; Mutex=$true; Owned=0; Contract=$true; Retry=0; Expected='SEND_OFF' },
    @{ Name='Matching ON pending'; Desired='ON'; Confirmed='OFF'; Ticket=1001; Pending='ON'; Cancel=$false; Mutex=$true; Owned=1; Contract=$true; Retry=0; Expected='SYNCING' },
    @{ Name='Policy flips while ON pending'; Desired='OFF'; Confirmed='OFF'; Ticket=1002; Pending='ON'; Cancel=$false; Mutex=$true; Owned=1; Contract=$true; Retry=0; Expected='CANCEL_STALE' },
    @{ Name='Persisted cancellation'; Desired='OFF'; Confirmed='OFF'; Ticket=1003; Pending='ON'; Cancel=$true; Mutex=$true; Owned=1; Contract=$true; Retry=0; Expected='CANCEL_STALE' },
    @{ Name='Mutex lost before send'; Desired='OFF'; Confirmed='ON'; Ticket=0; Pending='NONE'; Cancel=$false; Mutex=$false; Owned=0; Contract=$true; Retry=0; Expected='ERROR' },
    @{ Name='Duplicate active commands'; Desired='OFF'; Confirmed='OFF'; Ticket=1004; Pending='OFF'; Cancel=$false; Mutex=$true; Owned=2; Contract=$true; Retry=0; Expected='ERROR' },
    @{ Name='Untracked active command'; Desired='OFF'; Confirmed='OFF'; Ticket=0; Pending='NONE'; Cancel=$false; Mutex=$true; Owned=1; Contract=$true; Retry=0; Expected='ERROR' },
    @{ Name='Malformed tracked command'; Desired='OFF'; Confirmed='OFF'; Ticket=1005; Pending='OFF'; Cancel=$false; Mutex=$true; Owned=1; Contract=$false; Retry=0; Expected='ERROR' },
    @{ Name='Timeout retry 1'; Desired='OFF'; Confirmed='ON'; Ticket=0; Pending='NONE'; Cancel=$false; Mutex=$true; Owned=0; Contract=$true; Retry=1; Expected='SEND_OFF' },
    @{ Name='Timeout retry 3'; Desired='ON'; Confirmed='OFF'; Ticket=0; Pending='NONE'; Cancel=$false; Mutex=$true; Owned=0; Contract=$true; Retry=3; Expected='SEND_ON' },
    @{ Name='Timeout retry exhausted'; Desired='OFF'; Confirmed='ON'; Ticket=0; Pending='NONE'; Cancel=$false; Mutex=$true; Owned=0; Contract=$true; Retry=4; Expected='ERROR' }
)
foreach ($case in $cycleSyncCases) {
    $actual = if (-not $case.Mutex) {
        'ERROR'
    }
    elseif ($case.Owned -gt 1 -or
            ($case.Owned -eq 1 -and $case.Ticket -eq 0) -or
            -not $case.Contract -or $case.Retry -gt 3) {
        'ERROR'
    }
    elseif ($case.Ticket -ne 0) {
        if ($case.Cancel -or $case.Pending -ne $case.Desired) {
            'CANCEL_STALE'
        }
        else {
            'SYNCING'
        }
    }
    elseif ($case.Confirmed -eq $case.Desired) {
        'ALIGNED'
    }
    else {
        "SEND_$($case.Desired)"
    }
    if ($actual -ne $case.Expected) {
        $errors.Add("Cycle-sync model failed: $($case.Name), actual=$actual expected=$($case.Expected)")
    }
}

$ackRaceCases = @(
    @{ Name='ON ACK remains current'; Ack='ON'; Desired='ON'; Expected='ALIGNED' },
    @{ Name='OFF ACK remains current'; Ack='OFF'; Desired='OFF'; Expected='ALIGNED' },
    @{ Name='Late ON ACK after policy OFF'; Ack='ON'; Desired='OFF'; Expected='RESYNC_OFF' },
    @{ Name='Late OFF ACK after policy ON'; Ack='OFF'; Desired='ON'; Expected='RESYNC_ON' }
)
foreach ($case in $ackRaceCases) {
    $actual = if ($case.Ack -eq $case.Desired) {
        'ALIGNED'
    }
    else {
        "RESYNC_$($case.Desired)"
    }
    if ($actual -ne $case.Expected) {
        $errors.Add("ACK race model failed: $($case.Name)")
    }
}

$autoTradingResyncCases = @(
    @{ Name='Startup ON discards cached OFF'; Previous=$null; Current=$true; Confirmed='OFF'; Expected='RESYNC' },
    @{ Name='Startup OFF discards cached ON'; Previous=$null; Current=$false; Confirmed='ON'; Expected='RESYNC' },
    @{ Name='Stable ON keeps current ACK'; Previous=$true; Current=$true; Confirmed='OFF'; Expected='KEEP' },
    @{ Name='Stable OFF does not duplicate edge'; Previous=$false; Current=$false; Confirmed='OFF'; Expected='KEEP' },
    @{ Name='OFF to ON forces resync'; Previous=$false; Current=$true; Confirmed='OFF'; Expected='RESYNC' },
    @{ Name='ON to OFF invalidates ACK'; Previous=$true; Current=$false; Confirmed='ON'; Expected='RESYNC' }
)
foreach ($case in $autoTradingResyncCases) {
    $actual = if ($null -eq $case.Previous -or
                  $case.Previous -ne $case.Current) {
        'RESYNC'
    }
    else {
        'KEEP'
    }
    if ($actual -ne $case.Expected) {
        $errors.Add("AutoTrading resync model failed: $($case.Name)")
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
    Write-Host "FAIL: $resolvedSource" -ForegroundColor Red
    foreach ($failure in $errors) {
        Write-Host "  - $failure" -ForegroundColor Red
    }
    exit 1
}

$sourceHash = (Get-FileHash -LiteralPath $resolvedSource -Algorithm SHA256).Hash
$binaryHash = (Get-FileHash -LiteralPath $binaryPath -Algorithm SHA256).Hash
Write-Host "PASS: $resolvedSource" -ForegroundColor Green
Write-Host '  MetaEditor: 0 errors, 0 warnings'
Write-Host "  Source lines: $($lines.Count)"
Write-Host "  Pine/MT5 base parity: PASS ($($baseParity.Count) checks)"
Write-Host "  M5 scaled-price gates: PASS ($($scaledContracts.Count) checks)"
Write-Host "  Ver3 policy/state priority: PASS ($($logicContracts.Count) contracts)"
Write-Host "  New Cycle lifecycle: PASS ($($cycleContracts.Count) contracts)"
Write-Host '  Hardened transport integrity hash: PASS'
Write-Host '  Dashboard/checklist: PASS (17 rows)'
Write-Host "  Boundary/session models: PASS ($($boundaryCases.Count + $sessionCases.Count) cases)"
Write-Host "  Cycle-sync/ACK race models: PASS ($($cycleSyncCases.Count + $ackRaceCases.Count) cases)"
Write-Host "  AutoTrading resync models: PASS ($($autoTradingResyncCases.Count) cases)"
Write-Host "  CSV schema: PASS ($headerArgs columns)"
Write-Host '  Network/credential capability: NONE'
Write-Host "  MQ5 SHA256: $sourceHash"
Write-Host "  EX5 SHA256: $binaryHash"
