$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$modulePath = Join-Path $projectRoot 'src\monitor\CCBSNMonitor.psm1'
$startPath = Join-Path $projectRoot 'src\monitor\Start-CCBSNMonitor.ps1'
$chatIdPath = Join-Path $projectRoot 'src\monitor\Get-CCBSNTelegramChatId.ps1'
Import-Module $modulePath -Force

$failures = [Collections.Generic.List[string]]::new()
$passes = 0
function Assert-True([bool]$Condition, [string]$Name) {
    if ($Condition) { $script:passes++; return }
    $script:failures.Add($Name)
}
function Assert-Equal($Actual, $Expected, [string]$Name) {
    Assert-True ($Actual -eq $Expected) "$Name (actual=$Actual expected=$Expected)"
}

$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("ccbsn-monitor-test-" + [guid]::NewGuid())
[IO.Directory]::CreateDirectory($tempRoot) | Out-Null
$statusPath = Join-Path $tempRoot 'status.json'
$statePath = Join-Path $tempRoot 'state.json'

function New-TestStatus {
    param(
        [DateTimeOffset]$Now = [DateTimeOffset]::UtcNow,
        [bool]$TerminalConnected = $true,
        [string]$Session = 'SESSION 1',
        [long]$DecisionAge = 10,
        [bool]$Drift = $false,
        [string]$ControlState = 'NC ENABLED'
    )
    return [ordered]@{
        schema_version = 'ccbsn-monitor-status.v1'
        sequence = 1
        generated_at_utc = $Now.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        runtime_state = 'RUNNING'
        ea_version = '3.2.5'
        policy_version = '3.2.5-mt5-read-only-monitor-status'
        symbol = 'XAUUSD'
        ccbsn_magic = 9696
        controller_magic = 99196
        terminal_connected = $TerminalConnected
        last_tick_time_utc = $Now.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        last_m15_decision_server = '2026-08-18 10:15:00'
        last_m15_decision_age_seconds = $DecisionAge
        visual_state = 'ACTIVE'
        policy_family = 'UpsidePolicy'
        desired_cycle = 'ENABLE NEW CYCLE'
        control_state = $ControlState
        pending_command = 'NONE'
        drift = $Drift
        session = $Session
        atr = 8.5
        ema = 3333.25
        distance_d = 5.75
        last_event = 'POLICY_ALLOW'
        last_reason = 'ALL_CHECKS_PASS'
        positions = 1
        volume = 0.01
        floating_profit = 2.5
        margin_level = 900.0
        configuration_valid = $true
        configuration_error = 'NONE'
        control_error = 'NONE'
        monitor_error = 'NONE'
        monitor_write_failures = 0
    }
}

function Write-TestStatus($Status) {
    [IO.File]::WriteAllText($statusPath, ($Status | ConvertTo-Json -Depth 5))
}

try {
    $now = [DateTimeOffset]::UtcNow
    Write-TestStatus (New-TestStatus -Now $now)
    $snapshot = Read-CCBSNStatus -Path $statusPath
    Assert-Equal $snapshot.Data.symbol 'XAUUSD' 'Complete status parses'
    Assert-Equal $snapshot.Data.schema_version 'ccbsn-monitor-status.v1' 'Schema v1 accepted'

    [IO.File]::WriteAllText($statusPath, '{"sequence":')
    $partialRejected = $false
    try { Read-CCBSNStatus -Path $statusPath | Out-Null } catch { $partialRejected = $true }
    Assert-True $partialRejected 'Partial JSON rejected'

    $missing = New-TestStatus -Now $now
    $missing.Remove('control_state')
    Write-TestStatus $missing
    $missingRejected = $false
    try { Read-CCBSNStatus -Path $statusPath | Out-Null } catch { $missingRejected = $_.Exception.Message -match 'control_state' }
    Assert-True $missingRejected 'Missing required field rejected'

    $state = New-CCBSNMonitorState
    Write-TestStatus (New-TestStatus -Now $now -TerminalConnected $false)
    $disconnected = Read-CCBSNStatus -Path $statusPath
    $opened = @(Update-CCBSNIncidents -State $state -Snapshot $disconnected -Now $now)
    Assert-Equal $opened.Count 1 'Disconnect opens one incident'
    Assert-Equal $opened[0].Code 'TERMINAL_DISCONNECTED' 'Disconnect incident code'
    Assert-Equal $opened[0].Severity 'CRITICAL' 'Disconnect incident severity'
    $duplicate = @(Update-CCBSNIncidents -State $state -Snapshot $disconnected -Now $now)
    Assert-Equal $duplicate.Count 0 'Active incident deduplicated'

    Write-TestStatus (New-TestStatus -Now $now.AddSeconds(1))
    $healthy = Read-CCBSNStatus -Path $statusPath
    $resolved = @(Update-CCBSNIncidents -State $state -Snapshot $healthy -Now $now.AddSeconds(1))
    Assert-Equal $resolved.Count 1 'Recovered condition resolves once'
    Assert-Equal $resolved[0].State 'RESOLVED' 'Resolved lifecycle state'

    Write-CCBSNMonitorState -State $state -Path $statePath
    $reloaded = Read-CCBSNMonitorState -Path $statePath
    Assert-Equal (Get-CCBSNActiveIncidents -State $reloaded).Count 0 'Resolved state persists across restart'
    $legacyStatePath = Join-Path $tempRoot 'legacy-state.json'
    [IO.File]::WriteAllText($legacyStatePath,
        '{"last_update_id":7,"last_command_utc":{},"incidents":{}}')
    $legacyState = Read-CCBSNMonitorState -Path $legacyStatePath
    Assert-Equal $legacyState.last_update_id 7 'Legacy gateway state migrates'
    Assert-Equal $legacyState.event_log_path '' 'Legacy state initializes event baseline fields'

    $eventLogRoot = Join-Path $tempRoot 'event-logs'
    [IO.Directory]::CreateDirectory($eventLogRoot) | Out-Null
    $eventLogPath = Join-Path $eventLogRoot '20260818.log'
    $baselineLine = "AA`t0`t00:00:00.000`tController`tstartup`r`n"
    [IO.File]::WriteAllText($eventLogPath, $baselineLine, [Text.Encoding]::Unicode)
    $eventState = New-CCBSNMonitorState
    $baselineEvents = @(Read-CCBSNNewLogEvents -State $eventState -Directory $eventLogRoot)
    Assert-Equal $baselineEvents.Count 0 'Event log startup establishes baseline without history flood'
    $eventLine1 = "AA`t0`t11:15:00.000`tController`tCCBSN_V3 | 2026.08.18 07:15 | ENABLE_CANDIDATE_STARTED | state=ARMING session=SESSION 1 | close=4392.28 atr=7.06 ema=4406.87 d=-14.59 | bear=OK source=NONE | M15_DOWNSIDE_NEAR_ENTRY_PASS`r`n"
    $eventLine2 = "AA`t0`t11:30:00.000`tController`tCCBSN_V3 | 2026.08.18 07:30 | TRADING_ZONE_STARTED | state=ACTIVE session=SESSION 1 | close=4394.00 atr=7.50 ema=4405.00 d=-11.00 | bear=OK source=NONE | CONFIRM_PASS`r`n"
    [IO.File]::WriteAllText($eventLogPath, $baselineLine + $eventLine1 + $eventLine2,
        [Text.Encoding]::Unicode)
    $newEvents = @(Read-CCBSNNewLogEvents -State $eventState -Directory $eventLogRoot)
    Assert-Equal $newEvents.Count 2 'All newly appended controller events detected'
    Assert-Equal $newEvents[0].EventName 'ENABLE_CANDIDATE_STARTED' 'Event name parsed'
    Assert-Equal $newEvents[1].Reason 'CONFIRM_PASS' 'Event reason parsed'
    Assert-True ((Format-CCBSNEventNotification -Event $newEvents[1]) -match
        'EVENT \[TRADING_ZONE_STARTED\]') 'Event notification formatted'
    Write-CCBSNMonitorState -State $eventState -Path $statePath
    $eventReloaded = Read-CCBSNMonitorState -Path $statePath
    Assert-Equal $eventReloaded.event_log_offset $eventState.event_log_offset 'Event log offset persists'

    $staleState = New-CCBSNMonitorState
    Write-TestStatus (New-TestStatus -Now $now.AddSeconds(-31))
    $staleSnapshot = Read-CCBSNStatus -Path $statusPath
    $stale = @(Update-CCBSNIncidents -State $staleState -Snapshot $staleSnapshot -Now $now -HeartbeatStaleSeconds 30)
    Assert-True ($stale.Code -contains 'EA_HEARTBEAT_STALE') 'Heartbeat stale detected within threshold contract'

    $decisionState = New-CCBSNMonitorState
    Write-TestStatus (New-TestStatus -Now $now -DecisionAge 1201)
    $decisionSnapshot = Read-CCBSNStatus -Path $statusPath
    $decisionOpen = @(Update-CCBSNIncidents -State $decisionState -Snapshot $decisionSnapshot -Now $now -DecisionStaleSeconds 1200)
    Assert-True ($decisionOpen.Code -contains 'M15_DECISION_STALE') 'M15 decision stale detected in session'
    Write-TestStatus (New-TestStatus -Now $now -DecisionAge 9999 -Session 'OUTSIDE')
    $outside = Read-CCBSNStatus -Path $statusPath
    $decisionResolved = @(Update-CCBSNIncidents -State $decisionState -Snapshot $outside -Now $now -DecisionStaleSeconds 1200)
    Assert-Equal $decisionResolved[0].State 'RESOLVED' 'M15 stale suppressed outside sessions'

    $preserveState = New-CCBSNMonitorState
    Update-CCBSNIncidents -State $preserveState -Snapshot $disconnected -Now $now | Out-Null
    $parseTransition = @(Update-CCBSNIncidents -State $preserveState -Snapshot $null -ReadError 'invalid JSON' -Now $now)
    Assert-True ($parseTransition.Code -contains 'STATUS_PARSE_ERROR') 'Parse error incident opens'
    Assert-True $preserveState.incidents.TERMINAL_DISCONNECTED.active 'Unobservable incident is not falsely resolved'

    $deliveryState = New-CCBSNMonitorState
    $deliveryOpen = @(Update-CCBSNIncidents -State $deliveryState -Snapshot $healthy -DeliveryError 'POLL_FAILED' -Now $now)
    Assert-True ($deliveryOpen.Code -contains 'TELEGRAM_DELIVERY_ERROR') 'Telegram delivery incident opens'
    $deliveryResolved = @(Update-CCBSNIncidents -State $deliveryState -Snapshot $healthy -Now $now.AddSeconds(1))
    Assert-True ($deliveryResolved.Code -contains 'TELEGRAM_DELIVERY_ERROR' -and $deliveryResolved.State -contains 'RESOLVED') 'Telegram delivery incident resolves'

    $identityState = New-CCBSNMonitorState
    $identityOpen = @(Update-CCBSNIncidents -State $identityState -Snapshot $healthy `
        -IdentityError 'EVENT_SOURCE_ACCOUNT_MISMATCH' -Now $now)
    Assert-True ($identityOpen.Code -contains 'ACCOUNT_IDENTITY_MISMATCH') 'Wrong account opens critical incident'
    Assert-Equal ($identityOpen | Where-Object Code -eq 'ACCOUNT_IDENTITY_MISMATCH').Severity 'CRITICAL' 'Account mismatch severity'
    $identityResolved = @(Update-CCBSNIncidents -State $identityState -Snapshot $healthy -Now $now.AddSeconds(1))
    Assert-True ($identityResolved.Code -contains 'ACCOUNT_IDENTITY_MISMATCH') 'Account mismatch resolves after correction'

    $terminalConfig = Join-Path $tempRoot 'common.ini'
    [IO.File]::WriteAllText($terminalConfig,
        "[Common]`r`nLogin=123456789`r`nServer=Example-MT5Real`r`n[Charts]`r`nMaxBars=5000`r`n",
        [Text.Encoding]::Unicode)
    $terminalIdentity = Get-CCBSNTerminalAccountIdentity -CommonIniPath $terminalConfig
    Assert-Equal $terminalIdentity.Login '123456789' 'Terminal account identity parsed'
    Assert-Equal $terminalIdentity.Server 'Example-MT5Real' 'Terminal server identity parsed'

    Write-TestStatus (New-TestStatus -Now $now)
    $snapshot = Read-CCBSNStatus -Path $statusPath
    $commandState = New-CCBSNMonitorState
    foreach ($case in @(
        @('/status', 'Cycle:'), @('/health', 'Heartbeat:'),
        @('/market', 'ATR:'), @('/version', 'Gateway:'),
        @('/pause', 'READ_ONLY_MONITOR: COMMAND_NOT_ALLOWED')
    )) {
        $response = Format-CCBSNCommandResponse -Command $case[0] -Snapshot $snapshot -State $commandState -Now $now
        Assert-True ($response -match [regex]::Escape($case[1])) "Command $($case[0]) response"
    }

    $sent = [Collections.Generic.List[object]]::new()
    $sender = { param($ChatId, $Text) $sent.Add(@($ChatId, $Text)) }
    $allowedState = New-CCBSNMonitorState
    $allowedUpdate = [pscustomobject]@{
        update_id = 10
        message = [pscustomobject]@{ chat = [pscustomobject]@{ id = 1001 }; text = '/status' }
    }
    $handled = Invoke-CCBSNTelegramUpdate -Update $allowedUpdate -State $allowedState `
        -AllowedChatIds @(1001) -Snapshot $snapshot -SendMessage $sender -Now $now
    Assert-True $handled 'Authorized update handled'
    Assert-Equal $sent.Count 1 'Authorized chat receives one response'
    $duplicateHandled = Invoke-CCBSNTelegramUpdate -Update $allowedUpdate -State $allowedState `
        -AllowedChatIds @(1001) -Snapshot $snapshot -SendMessage $sender -Now $now.AddSeconds(2)
    Assert-True (-not $duplicateHandled) 'Duplicate update rejected'
    Assert-Equal $sent.Count 1 'Duplicate produces no second response'
    $rateUpdate = [pscustomobject]@{
        update_id = 11
        message = [pscustomobject]@{ chat = [pscustomobject]@{ id = 1001 }; text = '/health' }
    }
    $rateHandled = Invoke-CCBSNTelegramUpdate -Update $rateUpdate -State $allowedState `
        -AllowedChatIds @(1001) -Snapshot $snapshot -SendMessage $sender -Now $now.AddMilliseconds(500)
    Assert-True (-not $rateHandled) 'Per-chat rate limit rejects rapid command'
    Assert-Equal $sent.Count 1 'Rate-limited command produces no response flood'

    $unauthorizedState = New-CCBSNMonitorState
    $unauthorizedUpdate = [pscustomobject]@{
        update_id = 12
        message = [pscustomobject]@{ chat = [pscustomobject]@{ id = 9999 }; text = '/status' }
    }
    $unauthorized = Invoke-CCBSNTelegramUpdate -Update $unauthorizedUpdate -State $unauthorizedState `
        -AllowedChatIds @(1001) -Snapshot $snapshot -SendMessage $sender -Now $now
    Assert-True (-not $unauthorized) 'Unauthorized chat rejected'
    Assert-Equal $sent.Count 1 'Unauthorized chat receives no data'

    $tokens = $null; $parseErrors = $null
    [Management.Automation.Language.Parser]::ParseFile($startPath, [ref]$tokens, [ref]$parseErrors) | Out-Null
    Assert-Equal $parseErrors.Count 0 'PowerShell 5.1 start script syntax'
    $chatTokens = $null; $chatParseErrors = $null
    [Management.Automation.Language.Parser]::ParseFile($chatIdPath, [ref]$chatTokens, [ref]$chatParseErrors) | Out-Null
    Assert-Equal $chatParseErrors.Count 0 'PowerShell 5.1 Chat ID helper syntax'
    $moduleSource = [IO.File]::ReadAllText($modulePath)
    $startSource = [IO.File]::ReadAllText($startPath)
    $chatIdSource = [IO.File]::ReadAllText($chatIdPath)
    $combined = $moduleSource + "`n" + $startSource + "`n" + $chatIdSource
    Assert-True ($combined -notmatch 'ServerCertificateValidationCallback|TrustAllCert|CertificatePolicy') 'TLS verification is not disabled'
    Assert-True ($combined -match 'Invoke-RestMethod') 'HTTPS client uses platform-verified transport'
    Assert-True ($combined -match 'SecurityProtocolType\]::Tls12') 'PowerShell 5.1 transport enables TLS 1.2'
    Assert-True ($combined -match 'Invoke-RestMethod[\s\S]{0,500}-ErrorAction Stop') 'Telegram HTTP failures are terminating'
    Assert-True ($combined -notmatch 'CCBSN_CTRL:|SellLimit|BuyStop|command_queue|command_status') 'No trading/control command writer'
    Assert-True ($startSource -notmatch '(?m)^\s*\[string\]\$(Token|ChatId|Password)') 'No secret/identity CLI parameter'
    Assert-True ($chatIdSource -notmatch '(?m)^\s*\[string\]\$(Token|ChatId|Password)') 'Chat ID helper has no secret CLI parameter'
    Assert-True ($combined -notmatch 'Write-(Host|Verbose|Debug)[^\r\n]*\$token') 'Token is not logged'

    $envTestPath = Join-Path $tempRoot 'test.env'
    [IO.File]::WriteAllLines($envTestPath, @(
        '# parser regression fixture',
        'CCBSN_TEST_SIMPLE=value',
        'CCBSN_TEST_EQUALS=left=right'
    ))
    [Environment]::SetEnvironmentVariable('CCBSN_TEST_SIMPLE', $null, 'Process')
    [Environment]::SetEnvironmentVariable('CCBSN_TEST_EQUALS', $null, 'Process')
    Import-CCBSNEnvFile -Path $envTestPath
    Assert-Equal ([Environment]::GetEnvironmentVariable('CCBSN_TEST_SIMPLE', 'Process')) 'value' 'PowerShell 5.1 env parser simple value'
    Assert-Equal ([Environment]::GetEnvironmentVariable('CCBSN_TEST_EQUALS', 'Process')) 'left=right' 'Env parser preserves equals in value'
    [Environment]::SetEnvironmentVariable('CCBSN_TEST_SIMPLE', $null, 'Process')
    [Environment]::SetEnvironmentVariable('CCBSN_TEST_EQUALS', $null, 'Process')
}
finally {
    if ([IO.Directory]::Exists($tempRoot)) { [IO.Directory]::Delete($tempRoot, $true) }
}

if ($failures.Count -gt 0) {
    Write-Host 'FAIL: CCBSN Telegram Monitor' -ForegroundColor Red
    foreach ($failure in $failures) { Write-Host "  - $failure" -ForegroundColor Red }
    exit 1
}

Write-Host 'PASS: CCBSN Telegram Monitor' -ForegroundColor Green
Write-Host "  Assertions: $passes"
Write-Host '  Read-only commands: /status /health /market /version'
Write-Host '  Incident lifecycle/persistence: PASS'
Write-Host '  Unauthorized/dedup/rate boundary: PASS'
Write-Host '  TLS verification: ENABLED'
Write-Host '  Trading/control writer: NONE'
