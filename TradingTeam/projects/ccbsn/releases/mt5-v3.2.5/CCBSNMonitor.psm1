Set-StrictMode -Version Latest

$script:GatewayVersion = '0.1.0'
$script:SchemaVersion = 'ccbsn-monitor-status.v1'
$script:RequiredStatusFields = @(
    'schema_version', 'sequence', 'generated_at_utc', 'runtime_state',
    'ea_version', 'policy_version', 'symbol', 'ccbsn_magic',
    'controller_magic', 'terminal_connected', 'last_tick_time_utc',
    'last_m15_decision_server', 'last_m15_decision_age_seconds',
    'visual_state', 'policy_family', 'desired_cycle', 'control_state',
    'pending_command', 'drift', 'session', 'atr', 'ema', 'distance_d',
    'last_event', 'last_reason', 'positions', 'volume', 'floating_profit',
    'margin_level', 'configuration_valid', 'configuration_error',
    'control_error', 'monitor_error', 'monitor_write_failures'
)
$script:Severity = [ordered]@{
    EA_HEARTBEAT_STALE     = 'CRITICAL'
    TERMINAL_DISCONNECTED = 'CRITICAL'
    M15_DECISION_STALE    = 'WARNING'
    CONTROLLER_DATA_ERROR = 'CRITICAL'
    CONTROL_ERROR         = 'CRITICAL'
    CONTROL_DRIFT         = 'CRITICAL'
    STATUS_PARSE_ERROR    = 'WARNING'
    TELEGRAM_DELIVERY_ERROR = 'WARNING'
}

function ConvertTo-UtcText {
    param([Parameter(Mandatory)][DateTimeOffset]$Value)
    return $Value.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
}

function Read-CCBSNStatus {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    try {
        $raw = [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8)
        $data = $raw | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        throw "STATUS_READ_OR_PARSE_ERROR:$($_.Exception.GetType().Name)"
    }
    if ($null -eq $data) { throw 'STATUS_ROOT_INVALID' }
    $names = @($data.PSObject.Properties.Name)
    $missing = @($script:RequiredStatusFields | Where-Object { $_ -notin $names })
    if ($missing.Count -gt 0) {
        throw "STATUS_FIELDS_MISSING:$($missing -join ',')"
    }
    if ([string]$data.schema_version -ne $script:SchemaVersion) {
        throw "STATUS_SCHEMA_UNSUPPORTED:$($data.schema_version)"
    }
    if ([long]$data.sequence -lt 1) { throw 'STATUS_SEQUENCE_INVALID' }
    try {
        $generatedAt = [DateTimeOffset]::Parse(
            [string]$data.generated_at_utc,
            [Globalization.CultureInfo]::InvariantCulture,
            [Globalization.DateTimeStyles]::AssumeUniversal
        ).ToUniversalTime()
    }
    catch { throw 'STATUS_TIMESTAMP_INVALID' }
    return [pscustomobject]@{
        Data = $data
        GeneratedAt = $generatedAt
        SourcePath = $Path
    }
}

function New-CCBSNMonitorState {
    return @{
        last_update_id = [long]0
        last_command_utc = @{}
        incidents = @{}
    }
}

function Read-CCBSNMonitorState {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    $state = New-CCBSNMonitorState
    if (-not [IO.File]::Exists($Path)) { return $state }
    try { $loaded = [IO.File]::ReadAllText($Path) | ConvertFrom-Json -ErrorAction Stop }
    catch { return $state }
    if ($null -ne $loaded.last_update_id) {
        $state.last_update_id = [long]$loaded.last_update_id
    }
    if ($null -ne $loaded.last_command_utc) {
        foreach ($property in $loaded.last_command_utc.PSObject.Properties) {
            $state.last_command_utc[$property.Name] = [string]$property.Value
        }
    }
    if ($null -ne $loaded.incidents) {
        foreach ($property in $loaded.incidents.PSObject.Properties) {
            $incident = @{}
            foreach ($field in $property.Value.PSObject.Properties) {
                $incident[$field.Name] = $field.Value
            }
            $state.incidents[$property.Name] = $incident
        }
    }
    return $state
}

function Write-CCBSNMonitorState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$State,
        [Parameter(Mandatory)][string]$Path
    )

    $directory = [IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($Path))
    [IO.Directory]::CreateDirectory($directory) | Out-Null
    $temporary = "$Path.tmp"
    [IO.File]::WriteAllText(
        $temporary,
        (($State | ConvertTo-Json -Depth 8) + [Environment]::NewLine),
        [Text.UTF8Encoding]::new($false)
    )
    if ([IO.File]::Exists($Path)) {
        [IO.File]::Replace($temporary, $Path, $null)
    }
    else {
        [IO.File]::Move($temporary, $Path)
    }
}

function Update-CCBSNIncidents {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$State,
        [AllowNull()][object]$Snapshot,
        [AllowNull()][string]$ReadError,
        [AllowNull()][string]$DeliveryError,
        [DateTimeOffset]$Now = [DateTimeOffset]::UtcNow,
        [int]$HeartbeatStaleSeconds = 30,
        [int]$DecisionStaleSeconds = 1200
    )

    $conditions = @{}
    $conditions.STATUS_PARSE_ERROR = @{
        Active = -not [string]::IsNullOrEmpty($ReadError)
        Context = $(if ($ReadError) { $ReadError } else { 'status valid' })
    }
    $conditions.TELEGRAM_DELIVERY_ERROR = @{
        Active = -not [string]::IsNullOrEmpty($DeliveryError)
        Context = $(if ($DeliveryError) { $DeliveryError } else { 'delivery healthy' })
    }
    if ($null -ne $Snapshot) {
        $status = $Snapshot.Data
        $age = [Math]::Max(0, ($Now - $Snapshot.GeneratedAt).TotalSeconds)
        $decisionAge = [long]$status.last_m15_decision_age_seconds
        $conditions.EA_HEARTBEAT_STALE = @{
            Active = $age -gt $HeartbeatStaleSeconds
            Context = "heartbeat_age=$([Math]::Round($age, 1))s threshold=${HeartbeatStaleSeconds}s"
        }
        $conditions.TERMINAL_DISCONNECTED = @{
            Active = -not [bool]$status.terminal_connected
            Context = "terminal_connected=$($status.terminal_connected)"
        }
        $conditions.M15_DECISION_STALE = @{
            Active = ([string]$status.runtime_state -eq 'RUNNING' -and
                [string]$status.session -ne 'OUTSIDE' -and
                $decisionAge -gt $DecisionStaleSeconds)
            Context = "decision_age=${decisionAge}s session=$($status.session)"
        }
        $conditions.CONTROLLER_DATA_ERROR = @{
            Active = (-not [bool]$status.configuration_valid -or
                [string]$status.visual_state -eq 'DATA_ERROR')
            Context = "configuration=$($status.configuration_error) visual=$($status.visual_state)"
        }
        $conditions.CONTROL_ERROR = @{
            Active = [string]$status.control_state -eq 'ERROR'
            Context = "control_error=$($status.control_error)"
        }
        $conditions.CONTROL_DRIFT = @{
            Active = [bool]$status.drift
            Context = "desired=$($status.desired_cycle) state=$($status.control_state)"
        }
    }

    $transitions = [Collections.Generic.List[object]]::new()
    $nowText = ConvertTo-UtcText $Now
    foreach ($code in $script:Severity.Keys) {
        if (-not $conditions.ContainsKey($code)) { continue }
        $condition = $conditions[$code]
        $wasActive = $State.incidents.ContainsKey($code) -and
            [bool]$State.incidents[$code].active
        if ([bool]$condition.Active) {
            if (-not $wasActive) {
                $incident = @{
                    incident_id = "$code-$($Now.ToUniversalTime().ToString('yyyyMMddTHHmmssZ'))"
                    active = $true
                    severity = $script:Severity[$code]
                    opened_at = $nowText
                    last_seen = $nowText
                    resolved_at = $null
                    context = [string]$condition.Context
                }
                $State.incidents[$code] = $incident
                $transitions.Add([pscustomobject]@{
                    Code = $code; Severity = $script:Severity[$code]
                    State = 'OPEN'; OccurredAt = $nowText
                    Context = [string]$condition.Context
                })
            }
            else {
                $State.incidents[$code].last_seen = $nowText
                $State.incidents[$code].context = [string]$condition.Context
            }
        }
        elseif ($wasActive) {
            $State.incidents[$code].active = $false
            $State.incidents[$code].last_seen = $nowText
            $State.incidents[$code].resolved_at = $nowText
            $transitions.Add([pscustomobject]@{
                Code = $code; Severity = $script:Severity[$code]
                State = 'RESOLVED'; OccurredAt = $nowText
                Context = [string]$condition.Context
            })
        }
    }
    return @($transitions)
}

function Get-CCBSNActiveIncidents {
    param([Parameter(Mandatory)][hashtable]$State)
    return @($State.incidents.Values | Where-Object { [bool]$_.active })
}

function Format-CCBSNCommandResponse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Command,
        [AllowNull()][object]$Snapshot,
        [Parameter(Mandatory)][hashtable]$State,
        [long]$GatewayUptimeSeconds = 0,
        [DateTimeOffset]$Now = [DateTimeOffset]::UtcNow
    )

    if ($null -eq $Snapshot) { return 'STATUS_UNAVAILABLE' }
    $s = $Snapshot.Data
    $normalized = $Command.Split('@')[0].ToLowerInvariant()
    switch ($normalized) {
        '/status' {
            return @(
                "CCBSN $($s.symbol) | $($s.runtime_state)"
                "Cycle: $($s.desired_cycle) | ACK: $($s.control_state)"
                "Policy: $($s.visual_state) / $($s.policy_family)"
                "Session: $($s.session)"
                "Event: $($s.last_event)"
                "Reason: $($s.last_reason)"
                "Positions: $($s.positions) | Volume: $($s.volume) | P/L: $($s.floating_profit)"
            ) -join "`n"
        }
        '/health' {
            $age = [Math]::Max(0, ($Now - $Snapshot.GeneratedAt).TotalSeconds)
            $active = @(Get-CCBSNActiveIncidents $State)
            $activeText = if ($active.Count) {
                ($active | ForEach-Object { $_.incident_id }) -join ', '
            } else { 'NONE' }
            return @(
                "Heartbeat: $([Math]::Round($age, 1))s | sequence $($s.sequence)"
                "Terminal connected: $($s.terminal_connected)"
                "M15 decision age: $($s.last_m15_decision_age_seconds)s"
                "Configuration: $($s.configuration_valid) ($($s.configuration_error))"
                "Control: $($s.control_state) ($($s.control_error))"
                "Drift: $($s.drift)"
                "Active incidents: $activeText"
            ) -join "`n"
        }
        '/market' {
            return @(
                "$($s.symbol) M15 | $($s.session)"
                "ATR: $($s.atr)"
                "EMA: $($s.ema)"
                "D(C-EMA): $($s.distance_d)"
                "Decision: $($s.last_m15_decision_server)"
                "Snapshot UTC: $($s.generated_at_utc)"
            ) -join "`n"
        }
        '/version' {
            return @(
                "EA: $($s.ea_version)"
                "Policy: $($s.policy_version)"
                "Gateway: $script:GatewayVersion"
                "Schema: $($s.schema_version)"
                "Gateway uptime: ${GatewayUptimeSeconds}s"
            ) -join "`n"
        }
        default { return 'READ_ONLY_MONITOR: COMMAND_NOT_ALLOWED' }
    }
}

function Format-CCBSNIncidentTransition {
    param([Parameter(Mandatory)][object]$Transition)
    $prefix = if ($Transition.State -eq 'OPEN') { 'ALERT' } else { 'RESOLVED' }
    return "$prefix [$($Transition.Severity)] $($Transition.Code)`n" +
        "Time: $($Transition.OccurredAt)`nContext: $($Transition.Context)"
}

function Invoke-CCBSNTelegramApi {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Token,
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][hashtable]$Body,
        [int]$TimeoutSeconds = 15
    )
    [Net.ServicePointManager]::SecurityProtocol =
        [Net.ServicePointManager]::SecurityProtocol -bor
        [Net.SecurityProtocolType]::Tls12
    $uri = "https://api.telegram.org/bot$Token/$Method"
    $response = $null
    $previousErrorAction = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Stop'
        $response = Invoke-RestMethod -Uri $uri -Method Post -Body $Body `
            -ContentType 'application/x-www-form-urlencoded' `
            -TimeoutSec $TimeoutSeconds -ErrorAction Stop
    }
    catch {
        throw "TELEGRAM_${Method}_TRANSPORT_ERROR:$($_.Exception.GetType().Name)"
    }
    finally {
        $ErrorActionPreference = $previousErrorAction
    }
    if ($null -eq $response -or -not [bool]$response.ok) {
        throw "TELEGRAM_${Method}_FAILED"
    }
    return $response.result
}

function Send-CCBSNTelegramMessage {
    param(
        [Parameter(Mandatory)][string]$Token,
        [Parameter(Mandatory)][long]$ChatId,
        [Parameter(Mandatory)][string]$Text
    )
    Invoke-CCBSNTelegramApi -Token $Token -Method 'sendMessage' -Body @{
        chat_id = [string]$ChatId
        text = $Text
        disable_web_page_preview = 'true'
    } | Out-Null
}

function Get-CCBSNTelegramUpdates {
    param(
        [Parameter(Mandatory)][string]$Token,
        [long]$Offset = 1,
        [int]$TimeoutSeconds = 10
    )
    return @(Invoke-CCBSNTelegramApi -Token $Token -Method 'getUpdates' -Body @{
        offset = [string]$Offset
        timeout = [string]$TimeoutSeconds
        allowed_updates = '["message"]'
    } -TimeoutSeconds ($TimeoutSeconds + 5))
}

function Invoke-CCBSNTelegramUpdate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$Update,
        [Parameter(Mandatory)][hashtable]$State,
        [Parameter(Mandatory)][long[]]$AllowedChatIds,
        [AllowNull()][object]$Snapshot,
        [Parameter(Mandatory)][scriptblock]$SendMessage,
        [long]$GatewayUptimeSeconds = 0,
        [DateTimeOffset]$Now = [DateTimeOffset]::UtcNow,
        [int]$RateLimitSeconds = 1
    )

    $updateId = [long]$Update.update_id
    if ($updateId -le [long]$State.last_update_id) { return $false }
    $State.last_update_id = $updateId
    if ($null -eq $Update.message -or $null -eq $Update.message.chat) { return $false }
    $chatId = [long]$Update.message.chat.id
    if ($chatId -notin $AllowedChatIds) {
        Write-Warning "Rejected unauthorized Telegram chat_id=$chatId"
        return $false
    }
    $chatKey = [string]$chatId
    if ($State.last_command_utc.ContainsKey($chatKey)) {
        $previous = [DateTimeOffset]::Parse([string]$State.last_command_utc[$chatKey])
        if (($Now - $previous).TotalSeconds -lt $RateLimitSeconds) { return $false }
    }
    $State.last_command_utc[$chatKey] = $Now.ToUniversalTime().ToString('o')
    $text = [string]$Update.message.text
    $command = if ($text) { $text.Trim().Split(' ')[0] } else { '' }
    $response = Format-CCBSNCommandResponse -Command $command -Snapshot $Snapshot `
        -State $State -GatewayUptimeSeconds $GatewayUptimeSeconds -Now $Now
    & $SendMessage $chatId $response
    return $true
}

function Import-CCBSNEnvFile {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)
    if (-not [IO.File]::Exists($Path)) { return }
    foreach ($rawLine in [IO.File]::ReadAllLines($Path)) {
        $line = $rawLine.Trim()
        if (-not $line -or $line.StartsWith('#') -or -not $line.Contains('=')) { continue }
        $separatorIndex = $line.IndexOf('=')
        $name = $line.Substring(0, $separatorIndex).Trim()
        $value = $line.Substring($separatorIndex + 1).Trim()
        if (-not [Environment]::GetEnvironmentVariable($name, 'Process')) {
            [Environment]::SetEnvironmentVariable($name, $value, 'Process')
        }
    }
}

Export-ModuleMember -Function @(
    'Read-CCBSNStatus', 'New-CCBSNMonitorState', 'Read-CCBSNMonitorState',
    'Write-CCBSNMonitorState', 'Update-CCBSNIncidents',
    'Get-CCBSNActiveIncidents', 'Format-CCBSNCommandResponse',
    'Format-CCBSNIncidentTransition', 'Invoke-CCBSNTelegramApi',
    'Send-CCBSNTelegramMessage', 'Get-CCBSNTelegramUpdates',
    'Invoke-CCBSNTelegramUpdate', 'Import-CCBSNEnvFile'
)
