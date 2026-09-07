[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $TerminalPath,
    [Parameter(Mandatory)] [string] $DataRoot,
    [Parameter(Mandatory)] [string] $ControllerBinary,
    [Parameter(Mandatory)] [string] $PreflightControllerChart,
    [Parameter(Mandatory)] [string] $RuntimeControllerChart,
    [Parameter(Mandatory)] [string] $CCBSNChart,
    [Parameter(Mandatory)] [string] $ExpectedControllerSha256,
    [Parameter(Mandatory)] [string] $ExpectedCCBSNSha256,
    [Parameter(Mandatory)] [string] $ExpectedAccount,
    [Parameter(Mandatory)] [string] $EvidenceRoot,
    [string] $ControllerExpertFileName = 'CCBSN_Controller_Lite_Ver3_M5.ex5',
    [string] $ExpectedPolicyVersion = '1.0.1-mt5-autotrading-resync',
    [string] $ControllerDashboardTitle = 'CC CONTROLLER M5 | VER4.0',
    [ValidateRange(15, 120)] [int] $PreflightTimeoutSeconds = 45,
    [ValidateRange(30, 180)] [int] $RuntimeTimeoutSeconds = 90,
    [ValidateRange(3, 120)] [int] $PostAckAuditSeconds = 65,
    [ValidateRange(60, 180)] [int] $UpdateWarmupSeconds = 70,
    [ValidateRange(60, 180)] [int] $TerminalQuiescenceSeconds = 60,
    [ValidateRange(60, 300)] [int] $TerminalQuiescenceTimeoutSeconds = 180,
    [switch] $StopAndRestoreOnPass
)

$ErrorActionPreference = 'Stop'
$supervisorVersion = '4.0.2'
$controllerRelativePath = Join-Path 'MQL5\Experts' $ControllerExpertFileName
$controllerProfileName = [IO.Path]::GetFileNameWithoutExtension(
    $ControllerExpertFileName)
$ccbsnRelativePath = 'MQL5\Experts\Can Cu Bu Sieng Nang v3.0.ex5'
$chartRelativeRoot = 'MQL5\Profiles\Charts\Default'
$commonRelativePath = 'config\common.ini'

function Get-FullLiteralPath([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Required path does not exist: $Path"
    }
    return (Get-Item -LiteralPath $Path).FullName
}

function Get-Sha256([string] $Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Assert-Hash([string] $Path, [string] $Expected, [string] $Label) {
    $actual = Get-Sha256 $Path
    if ($actual -ne $Expected.ToUpperInvariant()) {
        throw "$Label hash mismatch: expected=$Expected actual=$actual path=$Path"
    }
}

$TerminalPath = Get-FullLiteralPath $TerminalPath
$DataRoot = Get-FullLiteralPath $DataRoot
$ControllerBinary = Get-FullLiteralPath $ControllerBinary
$PreflightControllerChart = Get-FullLiteralPath $PreflightControllerChart
$RuntimeControllerChart = Get-FullLiteralPath $RuntimeControllerChart
$CCBSNChart = Get-FullLiteralPath $CCBSNChart
if ($TerminalQuiescenceTimeoutSeconds -le $TerminalQuiescenceSeconds) {
    throw 'TerminalQuiescenceTimeoutSeconds must exceed TerminalQuiescenceSeconds.'
}

$originPath = Join-Path $DataRoot 'origin.txt'
$origin = (Get-Content -LiteralPath $originPath -Raw).Trim().TrimEnd('\')
$terminalDirectory = (Split-Path -Parent $TerminalPath).TrimEnd('\')
if (-not $origin.Equals($terminalDirectory, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Terminal/data-root identity mismatch: origin=$origin terminal=$terminalDirectory"
}

$controllerTarget = Join-Path $DataRoot $controllerRelativePath
$ccbsnTarget = Join-Path $DataRoot $ccbsnRelativePath
$chartRoot = Join-Path $DataRoot $chartRelativeRoot
$chart01 = Join-Path $chartRoot 'chart01.chr'
$chart02 = Join-Path $chartRoot 'chart02.chr'
$commonIni = Join-Path $DataRoot $commonRelativePath
$liveUpdateRoot = Join-Path $DataRoot 'liveupdate'
foreach ($required in @($ccbsnTarget, $chartRoot, $chart01, $chart02, $commonIni)) {
    $null = Get-FullLiteralPath $required
}

Assert-Hash $ControllerBinary $ExpectedControllerSha256 'Controller candidate'
Assert-Hash $ccbsnTarget $ExpectedCCBSNSha256 'CCBSN target'

$runId = Get-Date -Format 'yyyyMMdd-HHmmss'
$runRoot = Join-Path $EvidenceRoot $runId
$backupRoot = Join-Path $runRoot 'backup'
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
$statusPath = Join-Path $runRoot 'status.log'

function Add-Status([string] $Message) {
    $line = "$(Get-Date -Format o) $Message"
    Add-Content -LiteralPath $statusPath -Value $line -Encoding UTF8
    Write-Output $line
}

$mutexBytes = [Text.Encoding]::UTF8.GetBytes($DataRoot.ToUpperInvariant())
$mutexSha = [Security.Cryptography.SHA256]::Create()
try {
    $mutexSuffix = ([BitConverter]::ToString(
        $mutexSha.ComputeHash($mutexBytes))).Replace('-', '').Substring(0, 16)
}
finally {
    $mutexSha.Dispose()
}
$mutex = [Threading.Mutex]::new($false, "CCBSN_SUPERVISOR_$mutexSuffix")
if (-not $mutex.WaitOne(0)) {
    $mutex.Dispose()
    throw "Another supervisor owns this MT5 data root: $DataRoot"
}

function Get-TargetTerminalProcess {
    @(Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object {
        try { $_.Path -eq $TerminalPath } catch { $false }
    })
}

function Get-LiveUpdateTerminalProcess {
    @(Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object {
        try {
            $_.Path.StartsWith($liveUpdateRoot,
                [StringComparison]::OrdinalIgnoreCase)
        }
        catch { $false }
    })
}

function Stop-TargetTerminal {
    foreach ($process in Get-TargetTerminalProcess) {
        Add-Status "TERMINAL_CLOSE_REQUEST pid=$($process.Id)"
        $null = $process.CloseMainWindow()
    }
    $deadline = (Get-Date).AddSeconds(15)
    while (@(Get-TargetTerminalProcess).Count -gt 0 -and (Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 250
    }
    foreach ($process in Get-TargetTerminalProcess) {
        Add-Status "TERMINAL_CLOSE_FALLBACK pid=$($process.Id)"
        Stop-Process -Id $process.Id -Force
    }
}

function Get-LogOffset([string] $Path) {
    if (Test-Path -LiteralPath $Path) {
        return (Get-Item -LiteralPath $Path).Length
    }
    return [long]0
}

function Get-NewLogText([string] $Path, [long] $Offset) {
    if (-not (Test-Path -LiteralPath $Path)) { return '' }
    $stream = [IO.File]::Open($Path, [IO.FileMode]::Open,
        [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
    try {
        if ($Offset -gt $stream.Length) { $Offset = 0 }
        $null = $stream.Seek($Offset, [IO.SeekOrigin]::Begin)
        $reader = [IO.StreamReader]::new($stream, [Text.Encoding]::Unicode,
            $false, 4096, $true)
        try { return $reader.ReadToEnd() } finally { $reader.Dispose() }
    }
    finally {
        $stream.Dispose()
    }
}

function Set-AutoTradingEnabled {
    $content = Get-Content -LiteralPath $commonIni -Raw
    $updated = [regex]::Replace($content, '(?m)^Enabled=\d+\s*$', 'Enabled=1', 1)
    if ($updated -eq $content -and $content -notmatch '(?m)^Enabled=1\s*$') {
        throw 'Cannot enable AutoTrading in terminal common.ini.'
    }
    Set-Content -LiteralPath $commonIni -Value $updated -Encoding UTF8
}

function Set-AutoTradingDisabled {
    $content = Get-Content -LiteralPath $commonIni -Raw
    $updated = [regex]::Replace($content, '(?m)^Enabled=\d+\s*$', 'Enabled=0', 1)
    if ($updated -eq $content -and $content -notmatch '(?m)^Enabled=0\s*$') {
        throw 'Cannot disable AutoTrading in terminal common.ini.'
    }
    Set-Content -LiteralPath $commonIni -Value $updated -Encoding UTF8
}

function New-BlankChart([string] $Source, [string] $Destination) {
    $text = Get-Content -LiteralPath $Source -Raw -Encoding Unicode
    $blank = [regex]::Replace($text, '(?s)\r?\n<expert>.*?</expert>\r?\n', "`r`n", 1)
    if ($blank -eq $text -or $blank -match '<expert>') {
        throw 'Cannot create a verified expert-free preflight chart.'
    }
    [IO.File]::WriteAllText($Destination, $blank, [Text.Encoding]::Unicode)
}

function Stage-FailClosedNoEA([string] $Context) {
    if (-not $script:safeBlankReady -or
        -not (Test-Path -LiteralPath $blankChart)) {
        throw "Fail-closed blank chart is unavailable: $Context"
    }
    Copy-Item -LiteralPath $updateBlankControllerChart `
        -Destination $chart01 -Force
    Copy-Item -LiteralPath $blankChart -Destination $chart02 -Force
    Set-AutoTradingDisabled
    foreach ($chart in @($chart01, $chart02)) {
        $chartText = Get-Content -LiteralPath $chart -Raw -Encoding Unicode
        if ($chartText -match '<expert>') {
            throw "Fail-closed staging still contains an EA: $chart"
        }
    }
    if ((Get-Content -LiteralPath $commonIni -Raw) -notmatch
        '(?m)^Enabled=0\s*$') {
        throw "Fail-closed staging did not disable AutoTrading: $Context"
    }
    Add-Status "FAIL_CLOSED_STAGED context=$Context autotrading=off experts=none"
}

function Wait-TerminalQuiescent([string] $Context) {
    $deadline = (Get-Date).AddSeconds($TerminalQuiescenceTimeoutSeconds)
    $quietSince = $null
    $seenTargetPids = [Collections.Generic.HashSet[int]]::new()
    $seenUpdatePids = [Collections.Generic.HashSet[int]]::new()
    while ((Get-Date) -lt $deadline) {
        $targets = @(Get-TargetTerminalProcess)
        $updaters = @(Get-LiveUpdateTerminalProcess)
        foreach ($process in $updaters) {
            if ($seenUpdatePids.Add([int]$process.Id)) {
                Add-Status "$Context LIVEUPDATE_ACTIVE pid=$($process.Id) path=$($process.Path)"
            }
        }
        if ($targets.Count -gt 0) {
            foreach ($process in $targets) {
                if ($seenTargetPids.Add([int]$process.Id)) {
                    Add-Status "$Context TERMINAL_RESPAWN_DETECTED pid=$($process.Id)"
                }
            }
            Stop-TargetTerminal
            Stage-FailClosedNoEA "$Context-RESPAWN"
            $quietSince = $null
        }
        elseif ($updaters.Count -gt 0) {
            $quietSince = $null
        }
        else {
            if ($null -eq $quietSince) {
                $quietSince = Get-Date
                Add-Status "$Context QUIESCENCE_TIMER_STARTED"
            }
            if (((Get-Date) - $quietSince).TotalSeconds -ge
                $TerminalQuiescenceSeconds) {
                Add-Status "$Context QUIESCENT seconds=$TerminalQuiescenceSeconds respawns=$($seenTargetPids.Count) updaters=$($seenUpdatePids.Count)"
                return [pscustomobject]@{
                    Respawns = $seenTargetPids.Count
                    Updaters = $seenUpdatePids.Count
                }
            }
        }
        Start-Sleep -Milliseconds 250
    }
    throw "$Context quiescence timeout after $TerminalQuiescenceTimeoutSeconds seconds. Fail-closed profile remains staged."
}

function Invoke-UpdateSafeWarmup {
    $beforeHash = Get-Sha256 $TerminalPath
    $beforeVersion = (Get-Item -LiteralPath $TerminalPath).VersionInfo.FileVersion
    Stage-FailClosedNoEA 'UPDATE_WARMUP'
    $null = Start-TargetTerminal 'UPDATE_WARMUP'
    $deadline = (Get-Date).AddSeconds($UpdateWarmupSeconds)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 250
    }
    Stop-TargetTerminal
    Stage-FailClosedNoEA 'UPDATE_WARMUP_STOPPED'
    $quiescence = Wait-TerminalQuiescent 'UPDATE_WARMUP'
    Stage-FailClosedNoEA 'UPDATE_WARMUP_QUIESCENT'
    $afterHash = Get-Sha256 $TerminalPath
    $afterVersion = (Get-Item -LiteralPath $TerminalPath).VersionInfo.FileVersion
    $changed = $beforeHash -ne $afterHash -or $beforeVersion -ne $afterVersion
    Add-Status "UPDATE_WARMUP PASS changed=$($changed.ToString().ToLowerInvariant()) before=$beforeVersion after=$afterVersion respawns=$($quiescence.Respawns) updaters=$($quiescence.Updaters)"
}

function New-MonitoredControllerChart([string] $Source, [string] $Destination,
                                      [string] $MonitorRelativePath,
                                      [string] $MarketIdentitySource = '') {
    $text = Get-Content -LiteralPath $Source -Raw -Encoding Unicode
    if ($MarketIdentitySource) {
        $identityText = Get-Content -LiteralPath $MarketIdentitySource `
            -Raw -Encoding Unicode
        foreach ($key in @('symbol', 'period_type', 'period_size')) {
            $identityMatch = [regex]::Match($identityText,
                "(?m)^$key=(.+?)\s*$")
            if (-not $identityMatch.Success) {
                throw "Cannot read $key from market identity chart: $MarketIdentitySource"
            }
            $value = $identityMatch.Groups[1].Value.Trim()
            $updated = [regex]::Replace($text, "(?m)^$key=.*$",
                "$key=$value", 1)
            if ($updated -eq $text -and $text -notmatch
                "(?m)^$key=$([regex]::Escape($value))\s*$") {
                throw "Cannot apply $key to Controller chart: $Source"
            }
            $text = $updated
        }
        foreach ($key in @('InpExpectedSymbolPrefix', 'InpXAUQuoteDigits')) {
            $identityMatch = [regex]::Match($identityText,
                "(?m)^$key=(.+?)\s*$")
            if (-not $identityMatch.Success) {
                # Older approved profiles rely on the EA defaults and do not
                # serialize these newer inputs. Preserve that behavior; when
                # present, broker-specific values still override the template.
                continue
            }
            $value = $identityMatch.Groups[1].Value.Trim()
            if ($text -match "(?m)^$key=") {
                $text = [regex]::Replace($text, "(?m)^$key=.*$",
                    "$key=$value", 1)
            }
            else {
                $text = [regex]::Replace($text, '(?m)^<inputs>\s*$',
                    "<inputs>`r`n$key=$value", 1)
            }
            if ($text -notmatch "(?m)^$key=$([regex]::Escape($value))\s*$") {
                throw "Cannot apply $key to Controller chart: $Source"
            }
        }
    }
    $text = [regex]::Replace($text,
        '(?m)^name=(CCBSN_Controller_Lite_Ver3_M5|CC_Controller_M5_Ver4_0|CC_Controller_M5_Ver4_1)\s*$',
        "name=$controllerProfileName", 1)
    $text = [regex]::Replace($text,
        '(?m)^path=Experts\\(CCBSN_Controller_Lite_Ver3_M5|CC_Controller_M5_Ver4_0|CC_Controller_M5_Ver4_1)\.ex5\s*$',
        "path=Experts\$ControllerExpertFileName", 1)
    $text = [regex]::Replace($text,
        '(?m)^InpEnableExternalMonitor=.*$', 'InpEnableExternalMonitor=true', 1)
    if ($text -notmatch '(?m)^InpEnableExternalMonitor=true\s*$') {
        throw 'Cannot enable the Controller status monitor in chart profile.'
    }
    if ($text -match '(?m)^InpMonitorStatusFile=') {
        $text = [regex]::Replace($text, '(?m)^InpMonitorStatusFile=.*$',
            "InpMonitorStatusFile=$MonitorRelativePath", 1)
    }
    else {
        $text = $text -replace '(?m)^(InpEnableExternalMonitor=true\s*)$',
            "`$1`r`nInpMonitorStatusFile=$MonitorRelativePath"
    }
    if ($text -match '(?m)^InpMonitorHeartbeatSeconds=') {
        $text = [regex]::Replace($text,
            '(?m)^InpMonitorHeartbeatSeconds=.*$',
            'InpMonitorHeartbeatSeconds=1', 1)
    }
    else {
        $text = $text -replace '(?m)^(InpMonitorStatusFile=.*\s*)$',
             "`$1`r`nInpMonitorHeartbeatSeconds=1"
    }
    if ($text -match '(?m)^InpTextPanelTitle=') {
        $text = [regex]::Replace($text, '(?m)^InpTextPanelTitle=.*$',
            "InpTextPanelTitle=$ControllerDashboardTitle", 1)
    }
    else {
        $text = $text -replace '(?m)^(<inputs>\s*)$',
            "`$1`r`nInpTextPanelTitle=$ControllerDashboardTitle"
    }
    if ($text -notmatch
        ("(?m)^InpTextPanelTitle=" +
         [regex]::Escape($ControllerDashboardTitle) + "\s*$")) {
        throw 'Cannot normalize the Controller dashboard title.'
    }
    [IO.File]::WriteAllText($Destination, $text, [Text.Encoding]::Unicode)
}

function Set-PreflightFailClosedInputs([string] $RuntimeSource,
                                        [string] $FailClosedSource,
                                        [string] $Destination,
                                        [string] $MonitorRelativePath) {
    # MT5 restores EA inputs positionally. A shortened Ver3 template renamed to
    # the Ver4 EA can therefore display the right key/value text while loading
    # shifted or default values. Start from the complete live Ver4 profile so
    # its serialized input layout remains intact, then replace only approved
    # fail-closed values that already exist in both profiles.
    New-MonitoredControllerChart $RuntimeSource $Destination `
        $MonitorRelativePath
    $text = Get-Content -LiteralPath $Destination -Raw -Encoding Unicode
    $safeText = Get-Content -LiteralPath $FailClosedSource -Raw -Encoding Unicode
    $failClosedKeys = @(
        'InpEnableSession1', 'InpSession1',
        'InpEnableSession2', 'InpSession2',
        'InpEnableSession3', 'InpSession3',
        'InpControlMode', 'InpCCBSNMagic', 'InpControllerMagic',
        'InpForceSyncOnInit'
    )
    foreach ($key in $failClosedKeys) {
        $safeMatch = [regex]::Match($safeText, "(?m)^$key=(.+?)\s*$")
        if (-not $safeMatch.Success) {
            throw "Fail-closed template is missing required input: $key"
        }
        if ($text -notmatch "(?m)^$key=") {
            throw "Runtime Controller profile is missing required input: $key"
        }
        $value = $safeMatch.Groups[1].Value.Trim()
        $text = [regex]::Replace($text, "(?m)^$key=.*$", "$key=$value", 1)
    }
    foreach ($key in @('InpEnableSession1', 'InpEnableSession2',
                        'InpEnableSession3')) {
        if ($text -notmatch "(?m)^$key=false\s*$") {
            throw "Preflight Controller is not fail-closed: $key"
        }
    }
    if ($text -notmatch '(?m)^InpControlMode=1\s*$' -or
        $text -notmatch '(?m)^InpForceSyncOnInit=true\s*$') {
        throw 'Preflight Controller control/sync inputs are not safe.'
    }
    [IO.File]::WriteAllText($Destination, $text, [Text.Encoding]::Unicode)
}

function Get-MonitorState([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $share = [IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete
    try {
        $stream = [IO.File]::Open($Path, [IO.FileMode]::Open,
            [IO.FileAccess]::Read, $share)
        try {
            $reader = [IO.StreamReader]::new($stream, [Text.Encoding]::UTF8,
                $true, 4096, $true)
            try { $json = $reader.ReadToEnd() }
            finally { $reader.Dispose() }
        }
        finally { $stream.Dispose() }
        if (-not $json) { return $null }
        return $json | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        return $null
    }
}

function Start-TargetTerminal([string] $Phase) {
    $process = Start-Process -FilePath $TerminalPath -WindowStyle Hidden -PassThru
    $script:terminalEverStarted = $true
    Add-Status "$Phase TERMINAL_START pid=$($process.Id)"
    return $process
}

function Test-EntryAttempt([string] $ExpertText, [string] $TerminalText) {
    return $ExpertText -match
        'Can Cu Bu Sieng Nang v3\.0 .*CTrade::OrderSend: market buy' -or
        $TerminalText -match
        ("Trades\s+'" + [regex]::Escape($ExpectedAccount) +
         "': (failed )?market buy") -or
        $TerminalText -match
        ("Trades\s+'" + [regex]::Escape($ExpectedAccount) +
         "': deal #[0-9]+ buy")
}

function Test-EntryOpened([string] $TerminalText) {
    return $TerminalText -match
        ("Trades\s+'" + [regex]::Escape($ExpectedAccount) +
         "': market buy") -or
        $TerminalText -match
        ("Trades\s+'" + [regex]::Escape($ExpectedAccount) +
         "': deal #[0-9]+ buy")
}

function Wait-PreflightCommand([string] $MonitorPath,
                               [string] $ExpertLog, [long] $ExpertOffset,
                               [string] $TerminalLog, [long] $TerminalOffset) {
    $deadline = (Get-Date).AddSeconds($PreflightTimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        $expertText = Get-NewLogText $ExpertLog $ExpertOffset
        $terminalText = Get-NewLogText $TerminalLog $TerminalOffset
        if ($expertText -match 'Can Cu Bu Sieng Nang v3\.0' -or
            $terminalText -match 'expert Can Cu Bu Sieng Nang v3\.0 .*loaded') {
            throw 'PREFLIGHT_FAIL: CCBSN loaded before OFF command was pre-seeded.'
        }
        if (Test-EntryAttempt $expertText $terminalText) {
            throw 'PREFLIGHT_FAIL: entry attempt detected.'
        }
        $monitor = Get-MonitorState $MonitorPath
        if ($null -ne $monitor -and
            [string]$monitor.policy_version -eq $ExpectedPolicyVersion -and
            [string]$monitor.account_login -eq $ExpectedAccount -and
            [bool]$monitor.terminal_connected -and
            [string]$monitor.desired_cycle -eq 'DISABLE NEW CYCLE' -and
            [string]$monitor.control_state -eq 'DISABLE PENDING' -and
            [string]$monitor.pending_command -eq 'DISABLE NEW CYCLE' -and
            [int64]$monitor.pending_ticket -gt 0 -and
            [int]$monitor.pending_age_seconds -ge 0 -and
            [int]$monitor.pending_age_seconds -le 5 -and
            [bool]$monitor.startup_cycle_barrier) {
            $ticket = [string][int64]$monitor.pending_ticket
            $expertText | Set-Content -LiteralPath (
                Join-Path $runRoot 'phase1-expert.log') -Encoding UTF8
            $terminalText | Set-Content -LiteralPath (
                Join-Path $runRoot 'phase1-terminal.log') -Encoding UTF8
            Copy-Item -LiteralPath $MonitorPath -Destination (
                Join-Path $runRoot 'phase1-monitor.json') -Force
            return $ticket
        }
        Start-Sleep -Milliseconds 100
    }
    $expertText | Set-Content -LiteralPath (
        Join-Path $runRoot 'phase1-expert.log') -Encoding UTF8
    $terminalText | Set-Content -LiteralPath (
        Join-Path $runRoot 'phase1-terminal.log') -Encoding UTF8
    throw 'PREFLIGHT_FAIL: OFF command was not accepted before timeout.'
}

function Wait-RuntimeAck([string] $Ticket, [string] $MonitorPath,
                         [string] $ExpertLog,
                         [long] $ExpertOffset, [string] $TerminalLog,
                         [long] $TerminalOffset) {
    $deadline = (Get-Date).AddSeconds($RuntimeTimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        $expertText = Get-NewLogText $ExpertLog $ExpertOffset
        $terminalText = Get-NewLogText $TerminalLog $TerminalOffset
        if (Test-EntryAttempt $expertText $terminalText) {
            $expertText | Set-Content -LiteralPath (
                Join-Path $runRoot 'phase2-expert.log') -Encoding UTF8
            $terminalText | Set-Content -LiteralPath (
                Join-Path $runRoot 'phase2-terminal.log') -Encoding UTF8
            throw 'RUNTIME_FAIL: CCBSN entry attempt occurred before/around OFF ACK.'
        }
        $monitor = Get-MonitorState $MonitorPath
        $monitorAck = $null -ne $monitor -and
            [string]$monitor.policy_version -eq $ExpectedPolicyVersion -and
            [string]$monitor.account_login -eq $ExpectedAccount -and
            [bool]$monitor.terminal_connected -and
            [string]$monitor.desired_cycle -eq 'DISABLE NEW CYCLE' -and
            [string]$monitor.control_state -eq 'NC DISABLED' -and
            [string]$monitor.cycle_consistency -eq 'ALIGNED' -and
            [int64]$monitor.pending_ticket -eq 0 -and
            [int64]$monitor.last_confirmed_ticket -eq [int64]$Ticket -and
            -not [bool]$monitor.startup_cycle_barrier -and
            [int]$monitor.startup_policy_hold_seconds_remaining -ge
                $PostAckAuditSeconds -and
            -not [bool]$monitor.drift
        if ($monitorAck) {
            Copy-Item -LiteralPath $MonitorPath -Destination (
                Join-Path $runRoot 'phase2-monitor.json') -Force
            Start-Sleep -Seconds $PostAckAuditSeconds
            $expertText = Get-NewLogText $ExpertLog $ExpertOffset
            $terminalText = Get-NewLogText $TerminalLog $TerminalOffset
            $expertText | Set-Content -LiteralPath (
                Join-Path $runRoot 'phase2-expert.log') -Encoding UTF8
            $terminalText | Set-Content -LiteralPath (
                Join-Path $runRoot 'phase2-terminal.log') -Encoding UTF8
            if (Test-EntryAttempt $expertText $terminalText) {
                throw 'RUNTIME_FAIL: CCBSN entry attempt occurred after the initial ACK window.'
            }
            return
        }
        Start-Sleep -Milliseconds 100
    }
    throw 'RUNTIME_FAIL: pre-seeded OFF command did not produce a reconciled ACK.'
}

$expertLog = Join-Path $DataRoot ('MQL5\Logs\{0}.log' -f (Get-Date -Format yyyyMMdd))
$terminalLog = Join-Path $DataRoot ('logs\{0}.log' -f (Get-Date -Format yyyyMMdd))
$blankChart = Join-Path $runRoot 'preflight-blank.chr'
$updateBlankControllerChart = Join-Path $runRoot 'update-blank-controller.chr'
$preflightStagedChart = Join-Path $runRoot 'preflight-controller.chr'
$runtimeStagedChart = Join-Path $runRoot 'runtime-controller.chr'
$runtimeCCBSNStagedChart = Join-Path $runRoot 'runtime-ccbsn.chr'
$hadController = Test-Path -LiteralPath $controllerTarget
$restoreRequired = $true
$keepTerminalRunning = $false
$terminalEverStarted = $false
$safeBlankReady = $false
$phase2TerminalOffset = [long]0
$currentTerminalOffset = [long]0
$terminalBase = Split-Path -Parent $DataRoot
$monitorRelativePath = "CCBSN\supervisor_$mutexSuffix.json"
$monitorStatusPath = Join-Path (Join-Path $terminalBase 'Common\Files') `
    $monitorRelativePath
$monitorDirectory = Split-Path -Parent $monitorStatusPath

try {
    Set-Content -LiteralPath $statusPath -Value (
        "START $(Get-Date -Format o) supervisor=$supervisorVersion account=$ExpectedAccount") -Encoding UTF8
    if (@(Get-TargetTerminalProcess).Count -gt 0) {
        throw 'Target terminal must be stopped before supervised startup.'
    }

    Copy-Item -LiteralPath $chart01 -Destination (
        Join-Path $backupRoot 'chart01.chr') -Force
    Copy-Item -LiteralPath $chart02 -Destination (
        Join-Path $backupRoot 'chart02.chr') -Force
    Copy-Item -LiteralPath $commonIni -Destination (
        Join-Path $backupRoot 'common.ini') -Force
    if ($hadController) {
        Copy-Item -LiteralPath $controllerTarget -Destination (
            Join-Path $backupRoot 'controller.ex5') -Force
    }

    Copy-Item -LiteralPath $ControllerBinary -Destination $controllerTarget -Force
    Assert-Hash $controllerTarget $ExpectedControllerSha256 'Installed Controller'
    $preflightText = Get-Content -LiteralPath $PreflightControllerChart -Raw -Encoding Unicode
    $runtimeControllerText = Get-Content -LiteralPath $RuntimeControllerChart -Raw -Encoding Unicode
    $ccbsnChartText = Get-Content -LiteralPath $CCBSNChart -Raw -Encoding Unicode
    if ($preflightText -notmatch 'name=(CCBSN_Controller_Lite_Ver3_M5|CC_Controller_M5_Ver4_0|CC_Controller_M5_Ver4_1)' -or
        $preflightText -notmatch '(?m)^InpControlMode=1\s*$' -or
        $preflightText -notmatch '(?m)^InpEnableSession1=false\s*$') {
        throw 'Preflight chart is not a verified fail-closed Controller profile.'
    }
    if ($runtimeControllerText -notmatch 'name=(CCBSN_Controller_Lite_Ver3_M5|CC_Controller_M5_Ver4_0|CC_Controller_M5_Ver4_1)' -or
        $runtimeControllerText -notmatch '(?m)^InpControlMode=1\s*$') {
        throw 'Runtime Controller chart is not in CONTROL ENABLED mode.'
    }
    if ($ccbsnChartText -notmatch 'name=Can Cu Bu Sieng Nang v3\.0') {
        throw 'Runtime CCBSN chart does not load the expected EA.'
    }
    Copy-Item -LiteralPath $CCBSNChart -Destination $runtimeCCBSNStagedChart -Force
    New-BlankChart $runtimeCCBSNStagedChart $blankChart
    New-BlankChart $RuntimeControllerChart $updateBlankControllerChart
    $safeBlankReady = $true
    # Preserve the complete runtime input layout and apply only the approved
    # fail-closed overrides. This is required because MT5 restores EA inputs
    # positionally; renaming a shortened legacy chart can shift Ver4 values.
    Set-PreflightFailClosedInputs $RuntimeControllerChart `
        $PreflightControllerChart $preflightStagedChart $monitorRelativePath
    New-MonitoredControllerChart $RuntimeControllerChart `
        $runtimeStagedChart $monitorRelativePath
    foreach ($stagedControllerChart in @($preflightStagedChart,
                                         $runtimeStagedChart)) {
        $stagedText = Get-Content -LiteralPath $stagedControllerChart `
            -Raw -Encoding Unicode
        if ($stagedText -notmatch
            ("(?m)^name=" + [regex]::Escape($controllerProfileName) + "\s*$") -or
            $stagedText -notmatch
            ("(?m)^path=Experts\\" +
             [regex]::Escape($ControllerExpertFileName) + "\s*$") -or
            $stagedText -notmatch
            ("(?m)^InpTextPanelTitle=" +
             [regex]::Escape($ControllerDashboardTitle) + "\s*$")) {
            throw "Staged Controller chart identity mismatch: $stagedControllerChart"
        }
    }
    New-Item -ItemType Directory -Path $monitorDirectory -Force | Out-Null
    if (Test-Path -LiteralPath $monitorStatusPath) {
        Remove-Item -LiteralPath $monitorStatusPath -Force
    }
    # Phase 0 gives MT5 enough time to discover/apply LiveUpdate while no EA is
    # attached and AutoTrading is OFF. Any updater-driven terminal respawn is
    # stopped, restaged fail-closed and observed through a full quiet window.
    $updateExpertOffset = Get-LogOffset $expertLog
    $updateTerminalOffset = Get-LogOffset $terminalLog
    Invoke-UpdateSafeWarmup
    $updateExpertText = Get-NewLogText $expertLog $updateExpertOffset
    $updateTerminalText = Get-NewLogText $terminalLog $updateTerminalOffset
    $updateExpertText | Set-Content -LiteralPath (
        Join-Path $runRoot 'update-warmup-expert.log') -Encoding UTF8
    $updateTerminalText | Set-Content -LiteralPath (
        Join-Path $runRoot 'update-warmup-terminal.log') -Encoding UTF8
    if ($updateExpertText -match '(?m)\texpert .* loaded successfully' -or
        $updateTerminalText -match '(?m)\tExperts\texpert .* loaded successfully' -or
        (Test-EntryAttempt $updateExpertText $updateTerminalText)) {
        throw 'UPDATE_WARMUP_FAIL: an EA or entry attempt appeared in the no-EA window.'
    }
    $warmedTerminalHash = Get-Sha256 $TerminalPath
    Set-AutoTradingEnabled

    # Phase 1: only the fail-closed controller may run. It places OFF on the
    # server while CCBSN is absent, eliminating the broker round-trip race.
    Copy-Item -LiteralPath $preflightStagedChart -Destination $chart01 -Force
    Copy-Item -LiteralPath $blankChart -Destination $chart02 -Force
    $phase1ExpertOffset = Get-LogOffset $expertLog
    $phase1TerminalOffset = Get-LogOffset $terminalLog
    $currentTerminalOffset = $phase1TerminalOffset
    $null = Start-TargetTerminal 'PHASE1'
    $ticket = Wait-PreflightCommand $monitorStatusPath `
        $expertLog $phase1ExpertOffset `
        $terminalLog $phase1TerminalOffset
    Add-Status "PHASE1 PASS preseed-off-ticket=$ticket"
    Stop-TargetTerminal
    Start-Sleep -Seconds 2
    if (@(Get-TargetTerminalProcess).Count -gt 0 -or
        @(Get-LiveUpdateTerminalProcess).Count -gt 0 -or
        (Get-Sha256 $TerminalPath) -ne $warmedTerminalHash) {
        throw 'PHASE1_FAIL: terminal/update activity changed after OFF pre-seed; a fresh supervised run is required.'
    }

    # Phase 2: the server already holds OFF. Now CCBSN can load and consume it
    # before its entry lane is considered safe.
    Copy-Item -LiteralPath $runtimeStagedChart -Destination $chart01 -Force
    Copy-Item -LiteralPath $runtimeCCBSNStagedChart -Destination $chart02 -Force
    if (Test-Path -LiteralPath $monitorStatusPath) {
        Remove-Item -LiteralPath $monitorStatusPath -Force
    }
    $phase2ExpertOffset = Get-LogOffset $expertLog
    $phase2TerminalOffset = Get-LogOffset $terminalLog
    $currentTerminalOffset = $phase2TerminalOffset
    $null = Start-TargetTerminal 'PHASE2'
    Wait-RuntimeAck $ticket $monitorStatusPath `
        $expertLog $phase2ExpertOffset `
        $terminalLog $phase2TerminalOffset
    Add-Status "SUPERVISOR PASS ticket=$ticket off-ack-reconciled no-entry-attempt"

    if ($StopAndRestoreOnPass) {
        Add-Status 'PASS cleanup requested; fail-closed quiescent restore pending'
    }
    else {
        $restoreRequired = $false
        Add-Status 'RUNTIME ACTIVE supervised terminal left running'
    }
}
catch {
    Add-Status "SUPERVISOR FAIL $($_.Exception.Message)"
    $runtimeText = Get-NewLogText $terminalLog $currentTerminalOffset
    $failureMonitor = Get-MonitorState $monitorStatusPath
    $monitorHasOpenChain = $null -ne $failureMonitor -and
        [int]$failureMonitor.positions -gt 0
    if ($terminalEverStarted -and
        ((Test-EntryOpened $runtimeText) -or $monitorHasOpenChain)) {
        $keepTerminalRunning = $true
        $restoreRequired = $false
        Add-Status 'SAFETY HOLD terminal left running to manage an opened chain'
    }
    throw
}
finally {
    try {
        if ($restoreRequired -and -not $keepTerminalRunning) {
            Stop-TargetTerminal
            if ($safeBlankReady) {
                Stage-FailClosedNoEA 'RESTORE_GUARD'
                if ($terminalEverStarted) {
                    $null = Wait-TerminalQuiescent 'RESTORE_GUARD'
                    Stage-FailClosedNoEA 'RESTORE_FINAL_GUARD'
                }
            }
            Copy-Item -LiteralPath (Join-Path $backupRoot 'chart01.chr') `
                -Destination $chart01 -Force
            Copy-Item -LiteralPath (Join-Path $backupRoot 'chart02.chr') `
                -Destination $chart02 -Force
            Copy-Item -LiteralPath (Join-Path $backupRoot 'common.ini') `
                -Destination $commonIni -Force
            if ($hadController) {
                Copy-Item -LiteralPath (Join-Path $backupRoot 'controller.ex5') `
                    -Destination $controllerTarget -Force
            }
            elseif (Test-Path -LiteralPath $controllerTarget) {
                Remove-Item -LiteralPath $controllerTarget -Force
            }
            if (Test-Path -LiteralPath $monitorStatusPath) {
                Remove-Item -LiteralPath $monitorStatusPath -Force
            }
            Add-Status 'RESTORE PASS quiescent-terminal profiles-config-controller-restored'
        }
    }
    finally {
        $mutex.ReleaseMutex()
        $mutex.Dispose()
    }
}
