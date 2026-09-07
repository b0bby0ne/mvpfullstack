[CmdletBinding()]
param(
    [ValidateRange(1, 20)] [int] $Iterations = 5,
    [Parameter(Mandatory)] [string] $DemoData,
    [Parameter(Mandatory)] [string] $TerminalPath
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$buildBinary = Join-Path $projectRoot 'build\CCBSN_Controller_Lite_Ver3_M5.ex5'
$expertPath = Join-Path $demoData 'MQL5\Experts\CCBSN_Controller_Lite_Ver3_M5.ex5'
$chartRoot = Join-Path $demoData 'MQL5\Profiles\Charts\Default'
$chart01 = Join-Path $chartRoot 'chart01.chr'
$chart02 = Join-Path $chartRoot 'chart02.chr'
$commonIni = Join-Path $demoData 'config\common.ini'
$generatedRoot = Join-Path $PSScriptRoot 'generated'
$controllerProfile = Join-Path $generatedRoot 'chart02-off.chr'
$ccbsnProfile = Join-Path $generatedRoot 'chart01-ccbsn-no-new-orders.chr'
$evidenceRoot = Join-Path $PSScriptRoot 'evidence\unattended-restart-v1.0.1'
$statusPath = Join-Path $evidenceRoot 'status.log'
$backupRoot = Join-Path $evidenceRoot 'backup'
$expertLog = Join-Path $demoData ('MQL5\Logs\{0}.log' -f (Get-Date -Format yyyyMMdd))
$terminalLog = Join-Path $demoData ('logs\{0}.log' -f (Get-Date -Format yyyyMMdd))
$expectedCCBSNHash = 'F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68'

New-Item -ItemType Directory -Path $evidenceRoot -Force | Out-Null
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
Set-Content -LiteralPath $statusPath -Value "START $(Get-Date -Format o) iterations=$Iterations" -Encoding UTF8

function Add-Status([string] $Message) {
    $line = "$(Get-Date -Format o) $Message"
    Add-Content -LiteralPath $statusPath -Value $line -Encoding UTF8
    Write-Output $line
}

function Get-DemoTerminalProcess {
    @(Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object {
        try { $_.Path -eq $terminalPath } catch { $false }
    })
}

function Stop-DemoTerminal {
    foreach ($process in Get-DemoTerminalProcess) {
        Add-Status "CLOSE_REQUEST pid=$($process.Id)"
        $null = $process.CloseMainWindow()
    }
    $deadline = (Get-Date).AddSeconds(15)
    while ((Get-DemoTerminalProcess).Count -gt 0 -and (Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 250
    }
    foreach ($process in Get-DemoTerminalProcess) {
        Add-Status "CLOSE_FALLBACK pid=$($process.Id)"
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
    $stream = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read,
        [IO.FileShare]::ReadWrite)
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

function Set-AutoTradingEnabled([bool] $Enabled) {
    $content = Get-Content -LiteralPath $commonIni -Raw
    $value = if ($Enabled) { '1' } else { '0' }
    $updated = [regex]::Replace($content, '(?m)^Enabled=\d+\s*$', "Enabled=$value", 1)
    if ($updated -eq $content -and $content -notmatch "(?m)^Enabled=$value\s*$") {
        throw 'Cannot update [Experts] Enabled in demo common.ini.'
    }
    Set-Content -LiteralPath $commonIni -Value $updated -Encoding UTF8
}

function New-DemoCCBSNProfile {
    $profile = Get-Content -LiteralPath $ccbsnProfile -Raw -Encoding Unicode
    $profile = $profile `
        -replace '(?m)^InpTP=.*$', 'InpTP=0.1' `
        -replace '(?m)^InpSL=.*$', 'InpSL=0.1' `
        -replace '(?m)^InpUseDCA=.*$', 'InpUseDCA=false' `
        -replace '(?m)^InpMaxBuyOrders=.*$', 'InpMaxBuyOrders=1'
    return $profile
}

function Wait-RestartHandshake([int] $Iteration, [long] $ExpertOffset,
                               [long] $TerminalOffset) {
    $deadline = (Get-Date).AddSeconds(90)
    $expertText = ''
    $terminalText = ''
    while ((Get-Date) -lt $deadline) {
        $expertText = Get-NewLogText -Path $expertLog -Offset $ExpertOffset
        $terminalText = Get-NewLogText -Path $terminalLog -Offset $TerminalOffset
        if ($expertText -match 'CONTROL ERROR.*(MUTEX|CONTRACT|CONSISTENCY)' -or
            $expertText -match 'CRITICAL.*COMMAND_ORDER_EXECUTED') {
            throw "Iteration $Iteration encountered a fail-closed control error."
        }
        if ($expertText -match 'CONTROL CONFIRMED \| DISABLE NEW CYCLE') {
            break
        }
        Start-Sleep -Milliseconds 250
    }
    if ($expertText -notmatch '1\.0\.1-mt5-autotrading-resync') {
        throw "Iteration $Iteration did not load v1.0.1."
    }
    if ($expertText -notmatch 'STARTUP_AUTOTRADING_ON_FORCE_RESYNC') {
        throw "Iteration $Iteration did not invalidate the startup ACK cache."
    }
    if ($expertText -notmatch 'CONTROL SENT \| DISABLE NEW CYCLE' -or
        $expertText -notmatch 'Can Cu Bu Sieng Nang v3\.0 .*New Cycle' -or
        $expertText -notmatch 'CONTROL CONFIRMED \| DISABLE NEW CYCLE') {
        throw "Iteration $Iteration did not complete the OFF handshake."
    }

    Start-Sleep -Seconds 3
    $expertText = Get-NewLogText -Path $expertLog -Offset $ExpertOffset
    $terminalText = Get-NewLogText -Path $terminalLog -Offset $TerminalOffset
    # Any CCBSN entry attempt before/around the OFF ACK is a startup race,
    # including broker-rejected requests (for example, invalid stops).
    $entryAttempt =
        $expertText -match 'Can Cu Bu Sieng Nang v3\.0 .*CTrade::OrderSend: market buy' -or
        $terminalText -match "Trades\s+'110926003': (failed )?market buy" -or
        $terminalText -match "Trades\s+'110926003': deal #[0-9]+ buy"
    $entryOpened =
        $terminalText -match "Trades\s+'110926003': market buy" -or
        $terminalText -match "Trades\s+'110926003': deal #[0-9]+ buy"
    $expertText | Set-Content -LiteralPath (
        Join-Path $evidenceRoot "restart-$Iteration-expert.log") -Encoding UTF8
    $terminalText | Set-Content -LiteralPath (
        Join-Path $evidenceRoot "restart-$Iteration-terminal.log") -Encoding UTF8
    if ($entryAttempt) {
        Add-Status "ITERATION $Iteration FAIL first-order-race-detected"
        if ($entryOpened) {
            $flatDeadline = (Get-Date).AddSeconds(90)
            while ($terminalText -notmatch
                   "Trades\s+'110926003': market sell .* close #[0-9]+" -and
                   (Get-Date) -lt $flatDeadline) {
                Start-Sleep -Milliseconds 500
                $terminalText = Get-NewLogText -Path $terminalLog -Offset $TerminalOffset
            }
            if ($terminalText -notmatch
                "Trades\s+'110926003': market sell .* close #[0-9]+") {
                $script:keepTerminalRunning = $true
                Add-Status "SAFETY HOLD demo-terminal-left-running-for-open-chain"
            }
        }
        else {
            Add-Status "SAFETY FLAT broker-rejected-entry-attempt"
        }
        throw "Iteration $Iteration attempted a market Buy before/around OFF ACK."
    }
    Add-Status "ITERATION $Iteration PASS startup-resync/off-ack/no-market-buy"
}

$hadExpert = Test-Path -LiteralPath $expertPath
$keepTerminalRunning = $false
try {
    if (-not (Test-Path -LiteralPath $terminalPath -PathType Leaf)) {
        throw 'Demo terminal executable is missing.'
    }
    if (-not (Test-Path -LiteralPath $buildBinary -PathType Leaf)) {
        throw 'Compiled v1.0.1 EX5 is missing.'
    }
    $ccbsnPath = Join-Path $demoData 'MQL5\Experts\Can Cu Bu Sieng Nang v3.0.ex5'
    if ((Get-FileHash -LiteralPath $ccbsnPath -Algorithm SHA256).Hash -ne
        $expectedCCBSNHash) {
        throw 'Demo CCBSN binary does not match the Real20 target binary.'
    }

    Stop-DemoTerminal
    Copy-Item -LiteralPath $chart01 -Destination (Join-Path $backupRoot 'chart01.chr') -Force
    Copy-Item -LiteralPath $chart02 -Destination (Join-Path $backupRoot 'chart02.chr') -Force
    Copy-Item -LiteralPath $commonIni -Destination (Join-Path $backupRoot 'common.ini') -Force
    if ($hadExpert) {
        Copy-Item -LiteralPath $expertPath -Destination (
            Join-Path $backupRoot 'CCBSN_Controller_Lite_Ver3_M5.ex5') -Force
    }

    Copy-Item -LiteralPath $buildBinary -Destination $expertPath -Force
    # Controller is deliberately chart01 so its startup/tick lane is registered
    # before CCBSN chart02. The code must still prove a handshake on every run.
    Copy-Item -LiteralPath $controllerProfile -Destination $chart01 -Force
    Set-Content -LiteralPath $chart02 -Value (New-DemoCCBSNProfile) -Encoding Unicode
    Set-AutoTradingEnabled $true
    Add-Status "DEPLOY demo-controller-hash=$((Get-FileHash $expertPath -Algorithm SHA256).Hash)"

    for ($iteration = 1; $iteration -le $Iterations; $iteration++) {
        $expertOffset = Get-LogOffset $expertLog
        $terminalOffset = Get-LogOffset $terminalLog
        $process = Start-Process -FilePath $terminalPath -WindowStyle Hidden -PassThru
        Add-Status "ITERATION $iteration START pid=$($process.Id)"
        Wait-RestartHandshake -Iteration $iteration -ExpertOffset $expertOffset `
            -TerminalOffset $terminalOffset
        Stop-DemoTerminal
        Start-Sleep -Seconds 2
    }
    Add-Status "APPROVAL PASS iterations=$Iterations"
}
catch {
    Add-Status "APPROVAL FAIL $($_.Exception.Message)"
    throw
}
finally {
    if (-not $keepTerminalRunning) {
        Stop-DemoTerminal
        if (Test-Path -LiteralPath (Join-Path $backupRoot 'chart01.chr')) {
            Copy-Item -LiteralPath (Join-Path $backupRoot 'chart01.chr') -Destination $chart01 -Force
        }
        if (Test-Path -LiteralPath (Join-Path $backupRoot 'chart02.chr')) {
            Copy-Item -LiteralPath (Join-Path $backupRoot 'chart02.chr') -Destination $chart02 -Force
        }
        if (Test-Path -LiteralPath (Join-Path $backupRoot 'common.ini')) {
            Copy-Item -LiteralPath (Join-Path $backupRoot 'common.ini') -Destination $commonIni -Force
        }
        if ($hadExpert -and
            (Test-Path -LiteralPath (Join-Path $backupRoot 'CCBSN_Controller_Lite_Ver3_M5.ex5'))) {
            Copy-Item -LiteralPath (Join-Path $backupRoot 'CCBSN_Controller_Lite_Ver3_M5.ex5') `
                -Destination $expertPath -Force
        }
        elseif (-not $hadExpert -and (Test-Path -LiteralPath $expertPath)) {
            Remove-Item -LiteralPath $expertPath -Force
        }
        Add-Status 'DEMO RESTORED; TERMINAL STOPPED'
    }
}
