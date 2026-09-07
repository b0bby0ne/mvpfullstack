param(
    [string]$EnvFile = (Join-Path $PSScriptRoot '..\..\..\..\.env'),
    [switch]$Once
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'CCBSNMonitor.psm1') -Force
Import-CCBSNEnvFile -Path $EnvFile

function Get-RequiredEnvironment([string]$Name) {
    $value = [Environment]::GetEnvironmentVariable($Name, 'Process')
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Missing required environment variable: $Name"
    }
    return $value.Trim()
}

function Get-EnvironmentOrDefault([string]$Name, [string]$DefaultValue) {
    $value = [Environment]::GetEnvironmentVariable($Name, 'Process')
    if ([string]::IsNullOrWhiteSpace($value)) { return $DefaultValue }
    return $value.Trim()
}

if ((Get-EnvironmentOrDefault 'CCBSN_TELEGRAM_MODE' 'polling') -ne 'polling') {
    throw 'Sprint 001 supports CCBSN_TELEGRAM_MODE=polling only.'
}
$token = Get-RequiredEnvironment 'CCBSN_TELEGRAM_BOT_TOKEN'
$allowedChatIds = @((Get-RequiredEnvironment 'CCBSN_TELEGRAM_ALLOWED_CHAT_IDS').Split(',') |
    ForEach-Object { [long]$_.Trim() })
$statusPath = Get-RequiredEnvironment 'CCBSN_STATUS_FILE'
$eventLogDirectory = Get-EnvironmentOrDefault 'CCBSN_EVENT_LOG_DIRECTORY' ''
$expectedAccountLogin = Get-RequiredEnvironment 'CCBSN_EXPECTED_ACCOUNT_LOGIN'
$eventAccountConfig = Get-EnvironmentOrDefault 'CCBSN_EVENT_ACCOUNT_CONFIG' ''
$statePath = [Environment]::GetEnvironmentVariable('CCBSN_GATEWAY_STATE_FILE', 'Process')
if (-not $statePath) {
    $statePath = Join-Path $PSScriptRoot '..\..\runtime\telegram_monitor_state.json'
}
$statePath = [IO.Path]::GetFullPath($statePath)
$pollSeconds = [Math]::Max(1, [int](Get-EnvironmentOrDefault 'CCBSN_MONITOR_POLL_SECONDS' '5'))
$heartbeatSeconds = [Math]::Max(5, [int](Get-EnvironmentOrDefault 'CCBSN_HEARTBEAT_STALE_SECONDS' '30'))
$decisionSeconds = [Math]::Max(900, [int](Get-EnvironmentOrDefault 'CCBSN_M15_DECISION_STALE_SECONDS' '1200'))

$state = Read-CCBSNMonitorState -Path $statePath
$snapshot = $null
$readError = $null
$deliveryError = $null
$started = [Diagnostics.Stopwatch]::StartNew()

Write-Host 'CCBSN Telegram Monitor v0.1.0 started in READ-ONLY mode.'
while ($true) {
    try {
        $snapshot = Read-CCBSNStatus -Path $statusPath
        $readError = $null
    }
    catch {
        $readError = $_.Exception.Message
    }

    $identityError = $null
    if ($snapshot -and
        $snapshot.Data.PSObject.Properties['account_login_masked']) {
        $expectedSuffix = if ($expectedAccountLogin.Length -gt 4) {
            $expectedAccountLogin.Substring($expectedAccountLogin.Length - 4)
        } else { $expectedAccountLogin }
        if ([string]$snapshot.Data.account_login_masked -ne "****$expectedSuffix") {
            $identityError = 'STATUS_SOURCE_ACCOUNT_MISMATCH'
        }
    }
    if (-not [string]::IsNullOrWhiteSpace($eventLogDirectory)) {
        try {
            $eventIdentity = Get-CCBSNTerminalAccountIdentity -CommonIniPath $eventAccountConfig
            if ([string]$eventIdentity.Login -ne $expectedAccountLogin) {
                $identityError = 'EVENT_SOURCE_ACCOUNT_MISMATCH'
            }
        }
        catch { $identityError = $_.Exception.Message }
    }

    $transitions = @(Update-CCBSNIncidents -State $state -Snapshot $snapshot `
        -ReadError $readError -DeliveryError $deliveryError `
        -IdentityError $identityError `
        -HeartbeatStaleSeconds $heartbeatSeconds -DecisionStaleSeconds $decisionSeconds)
    Write-CCBSNMonitorState -State $state -Path $statePath
    $deliveryError = $null

    foreach ($transition in $transitions) {
        $message = Format-CCBSNIncidentTransition -Transition $transition
        foreach ($chatId in $allowedChatIds) {
            try { Send-CCBSNTelegramMessage -Token $token -ChatId $chatId -Text $message }
            catch { $deliveryError = "SEND_FAILED:$($_.Exception.GetType().Name)" }
        }
    }

    $events = if ($identityError) { @() } else {
        @(Read-CCBSNNewLogEvents -State $state -Directory $eventLogDirectory)
    }
    Write-CCBSNMonitorState -State $state -Path $statePath
    foreach ($event in $events) {
        $message = Format-CCBSNEventNotification -Event $event
        foreach ($chatId in $allowedChatIds) {
            try { Send-CCBSNTelegramMessage -Token $token -ChatId $chatId -Text $message }
            catch { $deliveryError = "SEND_FAILED:$($_.Exception.GetType().Name)" }
        }
    }

    try {
        $updates = @(Get-CCBSNTelegramUpdates -Token $token `
            -Offset ([long]$state.last_update_id + 1) `
            -TimeoutSeconds ([Math]::Min(10, $pollSeconds)))
        $sender = {
            param($ChatId, $Text)
            Send-CCBSNTelegramMessage -Token $token -ChatId $ChatId -Text $Text
        }
        foreach ($update in $updates) {
            Invoke-CCBSNTelegramUpdate -Update $update -State $state `
                -AllowedChatIds $allowedChatIds -Snapshot $snapshot `
                -SendMessage $sender -GatewayUptimeSeconds ([long]$started.Elapsed.TotalSeconds) | Out-Null
            Write-CCBSNMonitorState -State $state -Path $statePath
        }
    }
    catch {
        $deliveryError = "POLL_FAILED:$($_.Exception.GetType().Name)"
        Write-Warning 'Telegram polling failed; watchdog remains active.'
    }

    if ($Once) { break }
    Start-Sleep -Seconds $pollSeconds
}
