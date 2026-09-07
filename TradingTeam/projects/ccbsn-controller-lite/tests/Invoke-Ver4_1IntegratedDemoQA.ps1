[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $TerminalPath,
    [Parameter(Mandatory)] [string] $DataRoot,
    [string] $ControllerBinary = '',
    [string] $ControllerChartTemplate = '',
    [Parameter(Mandatory)] [string] $ExpectedAccount,
    [string] $ExpectedServer = 'MetaQuotes-Demo',
    [int] $AuditSeconds = 10
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $ControllerBinary) {
    $ControllerBinary = Join-Path $projectRoot `
        'build\CC_Controller_M5_Ver4_1.ex5'
}
if (-not $ControllerChartTemplate) {
    $ControllerChartTemplate = Join-Path $projectRoot `
        'releases\cc-controller-m5-ver4.0-portable\runtime-controller-template.chr'
}

$runId = Get-Date -Format 'yyyyMMdd-HHmmss'
$runRoot = Join-Path $projectRoot `
    "tests\runtime-approval\evidence\controller-ver4.1-integrated-demo\$runId"
$backup = Join-Path $runRoot 'backup'
New-Item -ItemType Directory -Path $backup -Force | Out-Null
$chartRoot = Join-Path $DataRoot 'MQL5\Profiles\Charts\Default'
$chart01 = Join-Path $chartRoot 'chart01.chr'
$chart02 = Join-Path $chartRoot 'chart02.chr'
$commonIni = Join-Path $DataRoot 'config\common.ini'
$controllerTarget = Join-Path $DataRoot `
    'MQL5\Experts\CC_Controller_M5_Ver4_1.ex5'
$controllerExisted = Test-Path -LiteralPath $controllerTarget
$monitorRelative = "CCBSN\integrated_v41_demo_$runId.json"
$terminalBase = Split-Path -Parent $DataRoot
$monitorPath = Join-Path (Join-Path $terminalBase 'Common\Files') `
    $monitorRelative
$expertLog = Join-Path $DataRoot `
    ('MQL5\Logs\{0}.log' -f (Get-Date -Format yyyyMMdd))
$terminalLog = Join-Path $DataRoot `
    ('logs\{0}.log' -f (Get-Date -Format yyyyMMdd))

function Get-TargetProcess {
    @(Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object {
        try { $_.Path -eq $TerminalPath } catch { $false }
    })
}

function Stop-TargetProcess {
    foreach ($process in Get-TargetProcess) {
        $null = $process.CloseMainWindow()
    }
    $deadline = (Get-Date).AddSeconds(15)
    while (@(Get-TargetProcess).Count -gt 0 -and (Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 250
    }
    foreach ($process in Get-TargetProcess) {
        Stop-Process -Id $process.Id -Force
    }
}

function Get-Offset([string] $Path) {
    if (Test-Path -LiteralPath $Path) {
        return (Get-Item -LiteralPath $Path).Length
    }
    return [long]0
}

function Read-NewUnicode([string] $Path, [long] $Offset) {
    if (-not (Test-Path -LiteralPath $Path)) { return '' }
    $stream = [IO.File]::Open($Path, [IO.FileMode]::Open,
        [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
    try {
        $null = $stream.Seek($Offset, [IO.SeekOrigin]::Begin)
        $reader = [IO.StreamReader]::new($stream, [Text.Encoding]::Unicode,
            $true, 4096, $true)
        try { return $reader.ReadToEnd() } finally { $reader.Dispose() }
    }
    finally { $stream.Dispose() }
}

function Get-MonitorJson([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $share = [IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete
    $stream = [IO.File]::Open($Path, [IO.FileMode]::Open,
        [IO.FileAccess]::Read, $share)
    try {
        $reader = [IO.StreamReader]::new($stream, [Text.Encoding]::UTF8,
            $true, 4096, $true)
        try {
            $json = $reader.ReadToEnd()
        }
        finally { $reader.Dispose() }
    }
    finally { $stream.Dispose() }
    if (-not $json) { return $null }
    try { return $json | ConvertFrom-Json } catch { return $null }
}

function Set-ProfileValue([string] $Text, [string] $Key, [string] $Value) {
    if ($Text -notmatch "(?m)^$Key=") { throw "Missing profile key: $Key" }
    [regex]::Replace($Text, "(?m)^$Key=.*$", "$Key=$Value", 1)
}

function New-BlankChart([string] $Source, [string] $Destination) {
    $text = Get-Content -LiteralPath $Source -Raw -Encoding Unicode
    $text = [regex]::Replace($text,
        '(?s)\r?\n<expert>.*?</expert>\r?\n', "`r`n", 1)
    [IO.File]::WriteAllText($Destination, $text, [Text.Encoding]::Unicode)
}

if (@(Get-TargetProcess).Count -gt 0) {
    throw 'Demo terminal must be stopped before integrated startup QA.'
}
foreach ($required in @($TerminalPath, $DataRoot, $ControllerBinary,
                         $ControllerChartTemplate, $chart01, $chart02,
                         $commonIni)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Required path missing: $required"
    }
}
$origin = (Get-Content -LiteralPath (Join-Path $DataRoot 'origin.txt') `
    -Raw).Trim().TrimEnd('\')
if (-not $origin.Equals((Split-Path -Parent $TerminalPath).TrimEnd('\'),
        [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Terminal/data-root identity mismatch.'
}

Copy-Item -LiteralPath $chart01 -Destination $backup -Force
Copy-Item -LiteralPath $chart02 -Destination $backup -Force
Copy-Item -LiteralPath $commonIni -Destination $backup -Force
if ($controllerExisted) {
    Copy-Item -LiteralPath $controllerTarget -Destination `
        (Join-Path $backup 'controller.ex5') -Force
}

$blank01 = Join-Path $runRoot 'blank01.chr'
$blank02 = Join-Path $runRoot 'blank02.chr'
$runtimeController = Join-Path $runRoot 'runtime-controller.chr'
$runtimeCCBSN = Join-Path $runRoot 'runtime-ccbsn.chr'
New-BlankChart $chart01 $blank01
New-BlankChart $chart02 $blank02
Copy-Item -LiteralPath $chart01 -Destination $runtimeCCBSN -Force
$controllerText = Get-Content -LiteralPath $ControllerChartTemplate `
    -Raw -Encoding Unicode
$controllerText = Set-ProfileValue $controllerText 'symbol' 'XAUUSD'
$controllerText = Set-ProfileValue $controllerText 'name' `
    'CC_Controller_M5_Ver4_1'
$controllerText = Set-ProfileValue $controllerText 'path' `
    'Experts\CC_Controller_M5_Ver4_1.ex5'
$controllerText = Set-ProfileValue $controllerText `
    'InpExpectedSymbolPrefix' 'XAUUSD'
$controllerText = $controllerText -replace `
    '(?m)^(InpExpectedSymbolPrefix=.*)$', `
    "`$1`r`nInpAutoDetectQuoteDigits=true"
$controllerText = $controllerText -replace `
    '(?m)^(InpControlMode=.*)$', `
    "InpExpectedAccountLogin=$ExpectedAccount`r`nInpExpectedAccountServer=$ExpectedServer`r`n`$1"
$controllerText = $controllerText -replace `
    '(?m)^(InpForceSyncOnInit=.*)$', `
    "`$1`r`nInpStartupPolicyHoldSeconds=70"
$controllerText = Set-ProfileValue $controllerText 'InpControlMode' '1'
$controllerText = Set-ProfileValue $controllerText 'InpForceSyncOnInit' 'true'
$controllerText = Set-ProfileValue $controllerText `
    'InpEnableExternalMonitor' 'true'
$controllerText = Set-ProfileValue $controllerText `
    'InpMonitorStatusFile' $monitorRelative
$controllerText = Set-ProfileValue $controllerText `
    'InpMonitorHeartbeatSeconds' '1'
$controllerText = Set-ProfileValue $controllerText `
    'InpTextPanelTitle' 'CC CONTROLLER M5 | VER4.1 INTEGRATED'
foreach ($key in 'InpEnableSession1','InpEnableSession2','InpEnableSession3') {
    $controllerText = Set-ProfileValue $controllerText $key 'false'
}
$inputCount = [regex]::Matches(
    [regex]::Match($controllerText,
        '(?s)<inputs>(.*?)</inputs>').Groups[1].Value,
    '(?m)^[A-Za-z][A-Za-z0-9_]*=').Count
if ($inputCount -ne 142) {
    throw "Unexpected Ver4.1 input layout: $inputCount"
}
[IO.File]::WriteAllText($runtimeController, $controllerText,
    [Text.Encoding]::Unicode)

$expertOffset = Get-Offset $expertLog
$terminalOffset = Get-Offset $terminalLog
$pendingTicket = [uint64]0
$ackMonitor = $null
try {
    Copy-Item -LiteralPath $ControllerBinary -Destination $controllerTarget -Force
    Copy-Item -LiteralPath $runtimeController -Destination $chart01 -Force
    Copy-Item -LiteralPath $blank02 -Destination $chart02 -Force
    $common = Get-Content -LiteralPath $commonIni -Raw
    $common = [regex]::Replace($common, '(?m)^Enabled=\d+\s*$',
        'Enabled=1', 1)
    [IO.File]::WriteAllText($commonIni, $common,
        [Text.UTF8Encoding]::new($false))
    # Phase 1: only the Controller is allowed to start. It places the fail-closed
    # OFF command on the broker before CCBSN exists in the terminal profile.
    $process = Start-Process -FilePath $TerminalPath -WindowStyle Hidden -PassThru
    $deadline = (Get-Date).AddSeconds(120)
    while ((Get-Date) -lt $deadline) {
        $monitor = Get-MonitorJson $monitorPath
        if ($null -ne $monitor -and
            $monitor.startup_cycle_barrier -and
            $monitor.pending_command -eq 'DISABLE NEW CYCLE' -and
            [uint64]$monitor.pending_ticket -gt 0 -and
            $monitor.identity_valid -and
            $monitor.integrated_runtime_guard -and
            [int]$monitor.effective_quote_digits -eq 2) {
            $pendingTicket = [uint64]$monitor.pending_ticket
            $monitor | ConvertTo-Json -Depth 4 | Set-Content `
                (Join-Path $runRoot 'phase1-pending-monitor.json') -Encoding UTF8
            break
        }
        Start-Sleep -Milliseconds 100
    }
    if ($pendingTicket -eq 0) {
        throw 'Phase 1 did not pre-seed an OFF command.'
    }

    Stop-TargetProcess
    Copy-Item -LiteralPath $runtimeController -Destination $chart01 -Force
    Copy-Item -LiteralPath $runtimeCCBSN -Destination $chart02 -Force
    if (Test-Path -LiteralPath $monitorPath) {
        Remove-Item -LiteralPath $monitorPath -Force
    }

    # Phase 2: the already-active OFF command is present at account sync time;
    # CCBSN can consume it before its strategy is allowed to create a new cycle.
    $process = Start-Process -FilePath $TerminalPath -WindowStyle Hidden -PassThru
    $deadline = (Get-Date).AddSeconds(120)
    while ((Get-Date) -lt $deadline) {
        $monitor = Get-MonitorJson $monitorPath
        if ($null -ne $monitor -and
            [uint64]$monitor.last_confirmed_ticket -eq $pendingTicket -and
            $monitor.control_state -eq 'NC DISABLED' -and
            $monitor.cycle_consistency -eq 'ALIGNED' -and
            $monitor.pending_command -eq 'NONE' -and
            -not $monitor.startup_cycle_barrier -and
            -not $monitor.drift -and
            $monitor.identity_valid -and
            $monitor.integrated_runtime_guard -and
            [int]$monitor.effective_quote_digits -eq 2) {
            $ackMonitor = $monitor
            break
        }
        Start-Sleep -Milliseconds 100
    }
    if ($null -eq $ackMonitor) {
        throw 'Phase 2 did not reach an aligned OFF ACK for the pre-seeded ticket.'
    }
    Start-Sleep -Seconds $AuditSeconds
    $finalMonitor = Get-MonitorJson $monitorPath
    if ($null -eq $finalMonitor) {
        throw 'Final monitor snapshot is unavailable.'
    }
    if ($finalMonitor.desired_cycle -ne 'DISABLE NEW CYCLE' -or
        $finalMonitor.cycle_consistency -ne 'ALIGNED' -or
        $finalMonitor.pending_command -ne 'NONE' -or
        $finalMonitor.startup_cycle_barrier -or
        $finalMonitor.drift -or
        -not $finalMonitor.identity_valid) {
        throw 'Integrated startup drifted during the audit window.'
    }
    $expertText = Read-NewUnicode $expertLog $expertOffset
    $terminalText = Read-NewUnicode $terminalLog $terminalOffset
    ($expertText + $terminalText) | Set-Content `
        (Join-Path $runRoot 'combined-runtime.log') -Encoding UTF8
    if (($expertText + $terminalText) -match
        'CONFIG ERROR|INIT SAFE MODE|IDENTITY FAIL-CLOSED|market buy|deal #[0-9]+ buy') {
        throw 'Forbidden config/identity/Buy event found in integrated runtime.'
    }
    $finalMonitor | ConvertTo-Json -Depth 4 | Set-Content `
        (Join-Path $runRoot 'final-monitor.json') -Encoding UTF8
    "INTEGRATED_DEMO_QA=PASS mode=two-phase-minimal ticket=$pendingTicket audit=${AuditSeconds}s inputs=$inputCount run=$runId"
}
finally {
    Stop-TargetProcess
    Copy-Item -LiteralPath $blank01 -Destination $chart01 -Force
    Copy-Item -LiteralPath $blank02 -Destination $chart02 -Force
    $quietUntil = (Get-Date).AddSeconds(10)
    while ((Get-Date) -lt $quietUntil) {
        if (@(Get-TargetProcess).Count) {
            Stop-TargetProcess
            Copy-Item -LiteralPath $blank01 -Destination $chart01 -Force
            Copy-Item -LiteralPath $blank02 -Destination $chart02 -Force
            $quietUntil = (Get-Date).AddSeconds(10)
        }
        Start-Sleep -Milliseconds 250
    }
    Copy-Item -LiteralPath (Join-Path $backup 'chart01.chr') `
        -Destination $chart01 -Force
    Copy-Item -LiteralPath (Join-Path $backup 'chart02.chr') `
        -Destination $chart02 -Force
    Copy-Item -LiteralPath (Join-Path $backup 'common.ini') `
        -Destination $commonIni -Force
    if ($controllerExisted) {
        Copy-Item -LiteralPath (Join-Path $backup 'controller.ex5') `
            -Destination $controllerTarget -Force
    }
    elseif (Test-Path -LiteralPath $controllerTarget) {
        $resolvedTarget = (Get-Item -LiteralPath $controllerTarget).FullName
        $resolvedRoot = (Get-Item -LiteralPath $DataRoot).FullName.TrimEnd('\') + '\'
        if (-not $resolvedTarget.StartsWith($resolvedRoot,
                [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Refusing to remove Controller outside the demo data root.'
        }
        Remove-Item -LiteralPath $controllerTarget -Force
    }
    if (Test-Path -LiteralPath $monitorPath) {
        Remove-Item -LiteralPath $monitorPath -Force
    }
}
