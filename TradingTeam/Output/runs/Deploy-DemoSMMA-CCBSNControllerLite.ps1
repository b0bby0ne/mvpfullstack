[CmdletBinding()]
param(
    [string] $TerminalPath = 'D:\Demo SMMA\terminal64.exe',
    [string] $DataRoot = 'C:\Users\PN TECH\AppData\Roaming\MetaQuotes\Terminal\4CF93EA8D9D62629F8449F3D53559542',
    [string] $SetPath = 'C:\Users\PN TECH\Downloads\cc30 buy step 2.set',
    [string] $Symbol = 'XAUUSDm',
    [long] $ExpectedAccount = 434262529,
    [string] $ExpectedServer = 'Exness-MT5Trial7',
    [string] $DeploymentLabel = 'demo_smma_v41',
    [string] $PanelTitle = 'CC CONTROLLER M5 | VER4.1 | DEMO SMMA',
    [int] $AuditSeconds = 10
)

$ErrorActionPreference = 'Stop'
$projectRoot = 'D:\Agent\TradingTeam\projects\ccbsn-controller-lite'
$controllerBinary = Join-Path $projectRoot `
    'releases\cc-controller-m5-ver4.1-integrated-minimal\CC_Controller_M5_Ver4_1.ex5'
$controllerTemplate = Join-Path $projectRoot `
    'packaging\minimal\engine\runtime-controller-template.chr'
$ccbsnTemplate = Join-Path $projectRoot `
    'packaging\minimal\engine\runtime-ccbsn-template.chr'
$controllerExpectedHash = `
    '2F96F8BD24712FC94C512EB690185A547D346E1369CFA96A9A025240E9A789E4'
$ccbsnExpectedHash = `
    'F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68'

$runId = Get-Date -Format 'yyyyMMdd-HHmmss'
$runRoot = Join-Path 'D:\Agent\TradingTeam\output\runs\ccbsn-controller-lite' $runId
$backupRoot = Join-Path $runRoot 'backup'
$chartRoot = Join-Path $DataRoot 'MQL5\Profiles\Charts\Default'
$chart01 = Join-Path $chartRoot 'chart01.chr'
$chart02 = Join-Path $chartRoot 'chart02.chr'
$commonIni = Join-Path $DataRoot 'config\common.ini'
$controllerTarget = Join-Path $DataRoot 'MQL5\Experts\CC_Controller_M5_Ver4_1.ex5'
$ccbsnTarget = Join-Path $DataRoot 'MQL5\Experts\Can Cu Bu Sieng Nang v3.0.ex5'
$terminalBase = Split-Path -Parent $DataRoot
$monitorRelative = "CCBSN\${DeploymentLabel}_$runId.json"
$monitorPath = Join-Path (Join-Path $terminalBase 'Common\Files') $monitorRelative
$runtimeController = Join-Path $runRoot 'chart01-controller-v41.chr'
$runtimeCCBSN = Join-Path $runRoot 'chart02-ccbsn-v30.chr'
$blankChart = Join-Path $runRoot 'chart02-blank.chr'

function Get-TargetProcess {
    @(Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object {
        try { $_.Path -eq $TerminalPath } catch { $false }
    })
}

function Stop-TargetProcess {
    foreach ($process in Get-TargetProcess) {
        $null = $process.CloseMainWindow()
    }
    $deadline = (Get-Date).AddSeconds(20)
    while (@(Get-TargetProcess).Count -gt 0 -and (Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 250
    }
    if (@(Get-TargetProcess).Count -gt 0) {
        throw 'Demo terminal did not close cleanly.'
    }
}

function Start-TargetProcess {
    Start-Process -FilePath $TerminalPath -PassThru
}

function Set-ProfileValue {
    param([string] $Text, [string] $Key, [string] $Value)
    $pattern = '(?m)^' + [regex]::Escape($Key) + '=.*$'
    if ($Text -notmatch $pattern) {
        throw "Missing profile key: $Key"
    }
    $regex = [regex]::new($pattern)
    $regex.Replace($Text, "$Key=$Value", 1)
}

function Get-MonitorJson {
    if (-not (Test-Path -LiteralPath $monitorPath)) { return $null }
    $share = [IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete
    $stream = [IO.File]::Open($monitorPath, [IO.FileMode]::Open,
        [IO.FileAccess]::Read, $share)
    try {
        $reader = [IO.StreamReader]::new($stream, [Text.Encoding]::UTF8,
            $true, 4096, $true)
        try { $json = $reader.ReadToEnd() } finally { $reader.Dispose() }
    }
    finally { $stream.Dispose() }
    if (-not $json) { return $null }
    try { $json | ConvertFrom-Json } catch { $null }
}

function Wait-ForMonitor {
    param([scriptblock] $Condition, [int] $TimeoutSeconds, [string] $Failure)
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        $monitor = Get-MonitorJson
        if ($null -ne $monitor -and
            [string]$monitor.control_error -match
                '(?i)disabled by server|server disables|trade disabled') {
            throw "Broker rejected automated trading: $($monitor.control_error)"
        }
        if ($null -ne $monitor -and (& $Condition $monitor)) {
            return $monitor
        }
        Start-Sleep -Milliseconds 200
    }
    throw $Failure
}

foreach ($required in @($TerminalPath, $DataRoot, $SetPath,
        $controllerBinary, $controllerTemplate, $ccbsnTemplate,
        $chart01, $chart02, $commonIni, $controllerTarget, $ccbsnTarget)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Required path missing: $required"
    }
}
$origin = (Get-Content -LiteralPath (Join-Path $DataRoot 'origin.txt') -Raw).Trim().TrimEnd('\')
if (-not $origin.Equals((Split-Path -Parent $TerminalPath).TrimEnd('\'),
        [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Terminal/data-root identity mismatch.'
}
if ((Get-FileHash -LiteralPath $controllerBinary -Algorithm SHA256).Hash -ne
        $controllerExpectedHash) {
    throw 'Controller release hash mismatch.'
}
if ((Get-FileHash -LiteralPath $controllerTarget -Algorithm SHA256).Hash -ne
        $controllerExpectedHash) {
    throw 'Installed Controller hash mismatch.'
}
if ((Get-FileHash -LiteralPath $ccbsnTarget -Algorithm SHA256).Hash -ne
        $ccbsnExpectedHash) {
    throw 'Installed CCBSN v3.0 hash mismatch.'
}

New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
Copy-Item -LiteralPath $chart01 -Destination (Join-Path $backupRoot 'chart01.chr') -Force
Copy-Item -LiteralPath $chart02 -Destination (Join-Path $backupRoot 'chart02.chr') -Force
Copy-Item -LiteralPath $commonIni -Destination (Join-Path $backupRoot 'common.ini') -Force
Copy-Item -LiteralPath $SetPath -Destination (Join-Path $runRoot 'cc30 buy step 2.set') -Force

$controllerText = Get-Content -LiteralPath $controllerTemplate -Raw -Encoding Unicode
$controllerText = Set-ProfileValue $controllerText 'symbol' $Symbol
$controllerText = Set-ProfileValue $controllerText 'period_size' '5'
$controllerText = Set-ProfileValue $controllerText 'name' 'CC_Controller_M5_Ver4_1'
$controllerText = Set-ProfileValue $controllerText 'path' 'Experts\CC_Controller_M5_Ver4_1.ex5'
$controllerText = Set-ProfileValue $controllerText 'InpExpectedSymbolPrefix' 'XAUUSD'
$controllerText = $controllerText -replace '(?m)^(InpExpectedSymbolPrefix=.*)$',
    "`$1`r`nInpAutoDetectQuoteDigits=true"
$controllerText = $controllerText -replace '(?m)^(InpControlMode=.*)$',
    "InpExpectedAccountLogin=$ExpectedAccount`r`nInpExpectedAccountServer=$ExpectedServer`r`n`$1"
$controllerText = $controllerText -replace '(?m)^(InpForceSyncOnInit=.*)$',
    "`$1`r`nInpStartupPolicyHoldSeconds=70"
$controllerText = Set-ProfileValue $controllerText 'InpControlMode' '1'
$controllerText = Set-ProfileValue $controllerText 'InpCCBSNMagic' '9199'
$controllerText = Set-ProfileValue $controllerText 'InpControllerMagic' '996970'
$controllerText = Set-ProfileValue $controllerText 'InpForceSyncOnInit' 'true'
$controllerText = Set-ProfileValue $controllerText 'InpEnableExternalMonitor' 'true'
$controllerText = Set-ProfileValue $controllerText 'InpMonitorStatusFile' $monitorRelative
$controllerText = Set-ProfileValue $controllerText 'InpMonitorHeartbeatSeconds' '1'
$controllerText = Set-ProfileValue $controllerText 'InpTextPanelTitle' `
    $PanelTitle
$controllerInputCount = [regex]::Matches(
    [regex]::Match($controllerText, '(?s)<inputs>(.*?)</inputs>').Groups[1].Value,
    '(?m)^[A-Za-z][A-Za-z0-9_]*=').Count
if ($controllerInputCount -ne 142) {
    throw "Unexpected Controller input layout: $controllerInputCount"
}
[IO.File]::WriteAllText($runtimeController, $controllerText,
    [Text.Encoding]::Unicode)

$ccbsnText = Get-Content -LiteralPath $ccbsnTemplate -Raw -Encoding Unicode
$ccbsnText = Set-ProfileValue $ccbsnText 'symbol' $Symbol
$ccbsnText = Set-ProfileValue $ccbsnText 'period_size' '5'
$setValues = [ordered]@{}
foreach ($line in Get-Content -LiteralPath $SetPath -Encoding UTF8) {
    $trimmed = $line.Trim()
    if (-not $trimmed -or $trimmed.StartsWith(';')) { continue }
    $separator = $trimmed.IndexOf('=')
    if ($separator -lt 1) { throw "Invalid SET line: $line" }
    $key = $trimmed.Substring(0, $separator).Trim()
    $value = $trimmed.Substring($separator + 1).Trim()
    if ($setValues.Contains($key)) { throw "Duplicate SET key: $key" }
    $setValues[$key] = $value
}
foreach ($entry in $setValues.GetEnumerator()) {
    $ccbsnText = Set-ProfileValue $ccbsnText $entry.Key $entry.Value
}
if ($setValues['InpMagicID'] -ne '9199') {
    throw 'SET magic must be 9199 for this deployment.'
}
[IO.File]::WriteAllText($runtimeCCBSN, $ccbsnText,
    [Text.Encoding]::Unicode)

$blankText = Get-Content -LiteralPath $chart02 -Raw -Encoding Unicode
$blankText = [regex]::Replace($blankText,
    '(?s)\r?\n<expert>.*?</expert>\r?\n', "`r`n", 1)
[IO.File]::WriteAllText($blankChart, $blankText, [Text.Encoding]::Unicode)

$success = $false
try {
    Stop-TargetProcess
    Copy-Item -LiteralPath $runtimeController -Destination $chart01 -Force
    Copy-Item -LiteralPath $blankChart -Destination $chart02 -Force
    $common = Get-Content -LiteralPath $commonIni -Raw
    $common = [regex]::Replace($common, '(?m)^Enabled=\d+\s*$', 'Enabled=1', 1)
    [IO.File]::WriteAllText($commonIni, $common,
        [Text.UTF8Encoding]::new($false))
    if (Test-Path -LiteralPath $monitorPath) {
        Remove-Item -LiteralPath $monitorPath -Force
    }

    $null = Start-TargetProcess
    $phase1 = Wait-ForMonitor -TimeoutSeconds 120 `
        -Failure 'Controller did not pre-seed a safe OFF command.' `
        -Condition {
            param($m)
            $m.startup_cycle_barrier -and
            $m.pending_command -eq 'DISABLE NEW CYCLE' -and
            [uint64]$m.pending_ticket -gt 0 -and
            $m.identity_valid -and $m.integrated_runtime_guard -and
            [long]$m.ccbsn_magic -eq 9199 -and
            [long]$m.account_login -eq $ExpectedAccount -and
            $m.account_server -eq $ExpectedServer -and
            [int]$m.positions -eq 0
        }
    $pendingTicket = [uint64]$phase1.pending_ticket
    $phase1 | ConvertTo-Json -Depth 5 | Set-Content `
        (Join-Path $runRoot 'phase1-pending-monitor.json') -Encoding UTF8

    Stop-TargetProcess
    Copy-Item -LiteralPath $runtimeController -Destination $chart01 -Force
    Copy-Item -LiteralPath $runtimeCCBSN -Destination $chart02 -Force
    if (Test-Path -LiteralPath $monitorPath) {
        Remove-Item -LiteralPath $monitorPath -Force
    }

    $null = Start-TargetProcess
    $phase2 = Wait-ForMonitor -TimeoutSeconds 120 `
        -Failure 'CCBSN did not ACK the pre-seeded OFF command.' `
        -Condition {
            param($m)
            [uint64]$m.last_confirmed_ticket -eq $pendingTicket -and
            $m.control_state -eq 'NC DISABLED' -and
            $m.cycle_consistency -eq 'ALIGNED' -and
            $m.pending_command -eq 'NONE' -and
            -not $m.startup_cycle_barrier -and -not $m.drift -and
            $m.identity_valid -and $m.integrated_runtime_guard -and
            [long]$m.ccbsn_magic -eq 9199 -and
            [int]$m.positions -eq 0
        }
    Start-Sleep -Seconds $AuditSeconds
    $final = Get-MonitorJson
    if ($null -eq $final -or
        $final.cycle_consistency -ne 'ALIGNED' -or
        $final.pending_command -ne 'NONE' -or
        $final.startup_cycle_barrier -or $final.drift -or
        -not $final.identity_valid -or [int]$final.positions -ne 0) {
        throw 'Runtime drifted during the final audit window.'
    }
    $final | ConvertTo-Json -Depth 5 | Set-Content `
        (Join-Path $runRoot 'final-monitor.json') -Encoding UTF8
    $success = $true
    [pscustomobject]@{
        Status = 'DEPLOY_PASS'
        RunId = $runId
        Symbol = $Symbol
        Period = 'M5'
        Account = $ExpectedAccount
        Server = $ExpectedServer
        CCBSNMagic = 9199
        ControllerMagic = 996970
        Ticket = $pendingTicket
        Cycle = $final.cycle_consistency
        Control = $final.control_state
        Pending = $final.pending_command
        Positions = $final.positions
        SetInputs = $setValues.Count
        ControllerInputs = $controllerInputCount
        Monitor = $monitorPath
        Evidence = $runRoot
        TerminalPid = @(Get-TargetProcess)[0].Id
    } | ConvertTo-Json
}
finally {
    if (-not $success) {
        try { Stop-TargetProcess } catch {}
        Copy-Item -LiteralPath (Join-Path $backupRoot 'chart01.chr') `
            -Destination $chart01 -Force
        Copy-Item -LiteralPath (Join-Path $backupRoot 'chart02.chr') `
            -Destination $chart02 -Force
        Copy-Item -LiteralPath (Join-Path $backupRoot 'common.ini') `
            -Destination $commonIni -Force
        if (Test-Path -LiteralPath $monitorPath) {
            Remove-Item -LiteralPath $monitorPath -Force
        }
        $null = Start-TargetProcess
    }
}
