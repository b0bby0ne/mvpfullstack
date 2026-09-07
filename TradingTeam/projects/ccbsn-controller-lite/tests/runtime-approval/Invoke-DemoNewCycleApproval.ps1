[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $DemoData,
    [Parameter(Mandatory)] [string] $TerminalPath
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$releaseBinary = Join-Path $projectRoot 'releases\mt5-v1.0.0\CCBSN_Controller_Lite_Ver3_M5.ex5'
$expertPath = Join-Path $demoData 'MQL5\Experts\CCBSN_Controller_Lite_Ver3_M5.ex5'
$ccbsnChartPath = Join-Path $demoData 'MQL5\Profiles\Charts\Default\chart01.chr'
$chartPath = Join-Path $demoData 'MQL5\Profiles\Charts\Default\chart02.chr'
$generatedRoot = Join-Path $PSScriptRoot 'generated'
$evidenceRoot = Join-Path $PSScriptRoot 'evidence'
$statusPath = Join-Path $evidenceRoot 'status.log'
$backupChart = Join-Path $evidenceRoot 'chart02.before-lite.chr'
$backupCCBSNChart = Join-Path $evidenceRoot 'chart01.before-lite.chr'
$backupExpert = Join-Path $evidenceRoot 'CCBSN_Controller_Lite_Ver3_M5.before-lite.ex5'
$expertLog = Join-Path $demoData ('MQL5\logs\{0}.log' -f (Get-Date -Format yyyyMMdd))
$expectedReleaseHash = '987FD9C41BE39ACADEAA2BD83B71DEEACA5BA165F22AC700E71CEC8AD66CD814'
$expectedCCBSNHash = 'F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68'

New-Item -ItemType Directory -Path $evidenceRoot -Force | Out-Null
Set-Content -LiteralPath $statusPath -Value "START $(Get-Date -Format o)" -Encoding UTF8

function Add-Status([string] $Message) {
    Add-Content -LiteralPath $statusPath -Value "$(Get-Date -Format o) $Message" -Encoding UTF8
}

Add-Status "RUNNER PID=$PID"

function Get-DemoTerminalProcess {
    @(Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object {
        try { $_.Path -eq $terminalPath } catch { $false }
    })
}

function Stop-DemoTerminal {
    $processes = Get-DemoTerminalProcess
    foreach ($process in $processes) {
        Add-Status "CLOSE_REQUEST PID=$($process.Id)"
        $null = $process.CloseMainWindow()
    }
    $deadline = (Get-Date).AddSeconds(20)
    while ((Get-DemoTerminalProcess).Count -gt 0 -and (Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 250
    }
    foreach ($process in Get-DemoTerminalProcess) {
        Add-Status "CLOSE_FALLBACK PID=$($process.Id)"
        Stop-Process -Id $process.Id -Force
    }
}

function Start-DemoTerminal {
    $process = Start-Process -FilePath $terminalPath -WindowStyle Hidden -PassThru
    Add-Status "TERMINAL_STARTED PID=$($process.Id)"
}

function Get-LogOffset {
    if (Test-Path -LiteralPath $expertLog) {
        return (Get-Item -LiteralPath $expertLog).Length
    }
    return [long]0
}

function Get-NewLogLines([long] $StartOffset) {
    if (-not (Test-Path -LiteralPath $expertLog)) { return @() }
    $stream = [IO.File]::Open($expertLog, [IO.FileMode]::Open, [IO.FileAccess]::Read,
        [IO.FileShare]::ReadWrite)
    try {
        if ($StartOffset -gt $stream.Length) { $StartOffset = 0 }
        $null = $stream.Seek($StartOffset, [IO.SeekOrigin]::Begin)
        $reader = [IO.StreamReader]::new($stream, [Text.Encoding]::Unicode, $false, 4096, $true)
        try { $text = $reader.ReadToEnd() } finally { $reader.Dispose() }
    }
    finally {
        $stream.Dispose()
    }
    $lines = @($text -split "`r?`n")
    @($lines | Where-Object {
        $_ -match 'CCBSN_Controller_Lite_Ver3_M5|Can Cu Bu Sieng Nang v3\.0' -and
        $_ -match 'INIT OK|CONTROL SENT|CONTROL CONFIRMED|New Cycle|CONTROL ERROR|MUTEX|CONTRACT'
    })
}

function Wait-Handshake {
    param(
        [ValidateSet('OFF', 'ON')] [string] $Mode,
        [long] $StartOffset,
        [int] $TimeoutSeconds
    )

    $sentPattern = if ($Mode -eq 'OFF') { 'CONTROL SENT \| DISABLE NEW CYCLE' } else { 'CONTROL SENT \| ENABLE NEW CYCLE' }
    # Keep runtime matching ASCII-only because Windows PowerShell 5 may read a
    # UTF-8-without-BOM script using the active ANSI code page.
    $botPattern = 'Can Cu Bu Sieng Nang v3\.0 .*New Cycle'
    $ackPattern = if ($Mode -eq 'OFF') { 'CONTROL CONFIRMED \| DISABLE NEW CYCLE' } else { 'CONTROL CONFIRMED \| ENABLE NEW CYCLE' }
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        $lines = Get-NewLogLines -StartOffset $StartOffset
        if ($lines -match 'CONTROL ERROR|MUTEX.*(LOST|ERROR)|CONTRACT.*MISMATCH') {
            throw "$Mode handshake encountered a fail-closed control error."
        }
        if ($lines -match $sentPattern -and $lines -match $botPattern -and $lines -match $ackPattern) {
            $lines | Set-Content -LiteralPath (Join-Path $evidenceRoot "handshake-$($Mode.ToLowerInvariant()).log") -Encoding UTF8
            Add-Status "$Mode HANDSHAKE PASS"
            return
        }
        Start-Sleep -Milliseconds 500
    }
    throw "$Mode handshake timed out after $TimeoutSeconds seconds."
}

$hadExistingExpert = Test-Path -LiteralPath $expertPath
try {
    if ((Get-Content -LiteralPath (Join-Path $demoData 'origin.txt') -Raw -Encoding UTF8).Trim() -ne 'D:\Test Bot 1') {
        throw 'Demo data root origin mismatch.'
    }
    if ((Get-FileHash -LiteralPath $releaseBinary -Algorithm SHA256).Hash -ne $expectedReleaseHash) {
        throw 'Release binary hash mismatch.'
    }
    $ccbsnPath = Join-Path $demoData 'MQL5\Experts\Can Cu Bu Sieng Nang v3.0.ex5'
    if ((Get-FileHash -LiteralPath $ccbsnPath -Algorithm SHA256).Hash -ne $expectedCCBSNHash) {
        throw 'Demo CCBSN binary does not match the approved target build.'
    }

    Stop-DemoTerminal
    Copy-Item -LiteralPath $ccbsnChartPath -Destination $backupCCBSNChart -Force
    Copy-Item -LiteralPath $chartPath -Destination $backupChart -Force
    if ($hadExistingExpert) {
        Copy-Item -LiteralPath $expertPath -Destination $backupExpert -Force
    }
    Copy-Item -LiteralPath $releaseBinary -Destination $expertPath -Force
    if ((Get-FileHash -LiteralPath $expertPath -Algorithm SHA256).Hash -ne $expectedReleaseHash) {
        throw 'Deployed demo binary hash mismatch.'
    }
    Add-Status 'DEPLOY PASS'

    Copy-Item -LiteralPath (Join-Path $generatedRoot 'chart01-ccbsn-no-new-orders.chr') -Destination $ccbsnChartPath -Force
    Copy-Item -LiteralPath (Join-Path $generatedRoot 'chart02-off.chr') -Destination $chartPath -Force
    $offStartOffset = Get-LogOffset
    Start-DemoTerminal
    Wait-Handshake -Mode OFF -StartOffset $offStartOffset -TimeoutSeconds 120

    Stop-DemoTerminal
    Copy-Item -LiteralPath (Join-Path $generatedRoot 'chart02-on.chr') -Destination $chartPath -Force
    $onStartOffset = Get-LogOffset
    Start-DemoTerminal
    Wait-Handshake -Mode ON -StartOffset $onStartOffset -TimeoutSeconds 180

    Stop-DemoTerminal
    Copy-Item -LiteralPath (Join-Path $generatedRoot 'chart02-off.chr') -Destination $chartPath -Force
    $cleanupStartOffset = Get-LogOffset
    Start-DemoTerminal
    Wait-Handshake -Mode OFF -StartOffset $cleanupStartOffset -TimeoutSeconds 120
    Add-Status 'CLEANUP OFF PASS'

    Add-Status 'APPROVAL PASS'
}
catch {
    Add-Status "APPROVAL FAIL: $($_.Exception.Message)"
    throw
}
finally {
    Stop-DemoTerminal
    if (Test-Path -LiteralPath $backupChart) {
        Copy-Item -LiteralPath $backupChart -Destination $chartPath -Force
    }
    if (Test-Path -LiteralPath $backupCCBSNChart) {
        Copy-Item -LiteralPath $backupCCBSNChart -Destination $ccbsnChartPath -Force
    }
    if ($hadExistingExpert -and (Test-Path -LiteralPath $backupExpert)) {
        Copy-Item -LiteralPath $backupExpert -Destination $expertPath -Force
    }
    elseif (-not $hadExistingExpert -and (Test-Path -LiteralPath $expertPath)) {
        Remove-Item -LiteralPath $expertPath -Force
    }
    Add-Status 'DEMO PROFILE RESTORED; TERMINAL STOPPED'
}
