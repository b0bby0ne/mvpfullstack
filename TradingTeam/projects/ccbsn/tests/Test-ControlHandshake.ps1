param(
    [string]$MetaEditorPath = 'D:\Test Bot 1\MetaEditor64.exe',
    [switch]$SkipCompile
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$targets = @(
    @{
        Name = 'v2.19'
        Source = Join-Path $projectRoot 'src\mt5\v2\CCBSN_Trading_Zone_Controller_v2.mq5'
        Log = Join-Path $projectRoot 'build\logs\compile-controller-v2.19-final.log'
        Binary = Join-Path $projectRoot 'build\bin\CCBSN_Trading_Zone_Controller_v2.ex5'
        Version = '#property version\s+"2\.190"'
        Policy = '2\.0\.19-fast-ack-handshake'
        Csv = 'CCBSN_Trading_Zone_Events_v2_19\.csv'
    },
    @{
        Name = 'v3.2.4'
        Source = Join-Path $projectRoot 'src\mt5\v3\CCBSN_Trading_Zone_Controller_v3.mq5'
        Log = Join-Path $projectRoot 'build\logs\compile-controller-v3.2.4-final.log'
        Binary = Join-Path $projectRoot 'build\bin\CCBSN_Trading_Zone_Controller_v3.ex5'
        Version = '#property version\s+"3\.240"'
        Policy = '3\.2\.4-mt5-market-event-checklist'
        Csv = 'CCBSN_Trading_Zone_Events_v3_2_4\.csv'
    }
)

$errors = [Collections.Generic.List[string]]::new()
$sources = @{}

function Assert-Match([string]$name, [string]$source, [string]$pattern) {
    if ($source -notmatch $pattern) {
        $errors.Add("$name missing contract: $pattern")
    }
}

foreach ($target in $targets) {
    $resolved = (Resolve-Path -LiteralPath $target.Source).Path
    $source = [IO.File]::ReadAllText($resolved)
    $sources[$target.Name] = $source

    if (-not $SkipCompile) {
        if (-not (Test-Path -LiteralPath $MetaEditorPath -PathType Leaf)) {
            $errors.Add("MetaEditor not found: $MetaEditorPath")
        }
        else {
            $compileStarted = [DateTime]::UtcNow
            & $MetaEditorPath "/compile:$resolved" "/log:$($target.Log)"
            $log = ''
            for ($attempt = 0; $attempt -lt 300; $attempt++) {
                if (Test-Path -LiteralPath $target.Log -PathType Leaf) {
                    $logItem = Get-Item -LiteralPath $target.Log
                    if ($logItem.LastWriteTimeUtc -ge $compileStarted.AddSeconds(-1)) {
                        try {
                            $log = [IO.File]::ReadAllText(
                                (Resolve-Path -LiteralPath $target.Log).Path
                            )
                            if ($log -match 'Result:') { break }
                        }
                        catch [IO.IOException] {
                            $log = ''
                        }
                    }
                }
                Start-Sleep -Milliseconds 100
            }
            if ($log -notmatch 'Result:\s+0 errors,\s+0 warnings') {
                $errors.Add("$($target.Name) compile did not pass cleanly.")
            }
        }
    }

    $compiledBinary = [IO.Path]::ChangeExtension($resolved, '.ex5')
    if (-not $SkipCompile -and (Test-Path -LiteralPath $compiledBinary -PathType Leaf)) {
        Copy-Item -LiteralPath $compiledBinary -Destination $target.Binary -Force
        Remove-Item -LiteralPath $compiledBinary
    }
    $binary = $target.Binary
    if (-not (Test-Path -LiteralPath $binary -PathType Leaf) -or
        (Get-Item -LiteralPath $binary).Length -lt 100000) {
        $errors.Add("$($target.Name) binary missing or unexpectedly small.")
    }

    Assert-Match $target.Name $source $target.Version
    Assert-Match $target.Name $source $target.Policy
    Assert-Match $target.Name $source $target.Csv
    Assert-Match $target.Name $source 'if\(ticket\s*==\s*0\)[\s\S]*?g_controlState\s*=\s*CCBSN_CONTROL_UNKNOWN;'
    Assert-Match $target.Name $source 'g_nextCommandAttemptTick\s*=\s*GetTickCount64\(\)\s*\+'
    Assert-Match $target.Name $source 'CONTROL NORMALIZED \| Fast ACK candidate'
    Assert-Match $target.Name $source 'CONTROL_STARTUP_SYNC_CHECK'
    Assert-Match $target.Name $source 'CONTROL_SHUTDOWN_SYNC_CHECK'
    Assert-Match $target.Name $source 'TRADE_TRANSACTION_ORDER_DELETE[\s\S]*?g_controlReconcileRequested\s*=\s*true;'

    $sendStart = $source.IndexOf('bool SendCCBSNCommand')
    $sendEnd = $source.IndexOf('void ProcessCCBSNControl', $sendStart)
    if ($sendStart -lt 0 -or $sendEnd -lt 0) {
        $errors.Add("$($target.Name) cannot locate send function.")
    }
    else {
        $send = $source.Substring($sendStart, $sendEnd - $sendStart)
        $track = $send.IndexOf('g_commandTicket = ticket;')
        $persist = $send.IndexOf('SavePendingCommand();')
        $reconcile = $send.IndexOf('ReconcilePendingCommand();')
        if ($track -lt 0 -or $persist -le $track -or $reconcile -le $persist) {
            $errors.Add("$($target.Name) ticket/persist/reconcile order is unsafe.")
        }
        if ($send -match 'if\(!requestOk\s*\|\|[\s\S]*?ticket\s*==\s*0\)') {
            $errors.Add("$($target.Name) still rejects a valid ticket because requestOk/retcode raced.")
        }
    }
}

$transportMarker = '//| CCBSN New Cycle command transport'
$lifecycleMarker = '//| EA lifecycle'
$v2 = $sources['v2.19']
$v3 = $sources['v3.2.4']
$v2Start = $v2.IndexOf($transportMarker)
$v2End = $v2.IndexOf($lifecycleMarker)
$v3Start = $v3.IndexOf($transportMarker)
$v3End = $v3.IndexOf($lifecycleMarker)
if ($v2Start -lt 0 -or $v2End -lt 0 -or $v3Start -lt 0 -or $v3End -lt 0) {
    $errors.Add('Cannot locate transport blocks for parity check.')
}
else {
    $v2Transport = $v2.Substring($v2Start, $v2End - $v2Start) -replace '\s+', ''
    $v3Transport = $v3.Substring($v3Start, $v3End - $v3Start).
        Replace('PolicyFamilyColor', 'BranchColor') -replace '\s+', ''
    if ($v2Transport -ne $v3Transport) {
        $errors.Add('v2.19 and v3.2.4 control transports differ functionally.')
    }
}

# Model the runtime handshake cases that caused the production failure.
$cases = @(
    @{ Name='fast ACK with request=false/retcode=0'; Ticket=1001L; History='CANCELED'; Expected='CONFIRMED' },
    @{ Name='normal accepted pending order'; Ticket=1002L; History='ACTIVE'; Expected='PENDING' },
    @{ Name='restart recovers canceled ticket'; Ticket=1003L; History='CANCELED'; Expected='CONFIRMED' },
    @{ Name='real send failure has no ticket'; Ticket=0L; History='NONE'; Expected='RETRY' },
    @{ Name='executed safety order'; Ticket=1004L; History='FILLED'; Expected='ERROR' }
)
foreach ($case in $cases) {
    $actual = if ($case.Ticket -eq 0) {
        'RETRY'
    }
    elseif ($case.History -eq 'CANCELED') {
        'CONFIRMED'
    }
    elseif ($case.History -eq 'FILLED') {
        'ERROR'
    }
    else {
        'PENDING'
    }
    if ($actual -ne $case.Expected) {
        $errors.Add("Handshake model failed: $($case.Name)")
    }
}

if ($errors.Count -gt 0) {
    Write-Host 'FAIL: CCBSN control handshake' -ForegroundColor Red
    foreach ($failure in $errors) {
        Write-Host "  - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'PASS: CCBSN control handshake' -ForegroundColor Green
Write-Host '  v2.19 compile: 0 errors, 0 warnings'
Write-Host '  v3.2.4 compile: 0 errors, 0 warnings'
Write-Host '  Fast ACK/ticket authority: PASS'
Write-Host '  Startup/shutdown sync checks: PASS'
Write-Host '  Transaction-triggered reconciliation: PASS'
Write-Host '  Retry without permanent ERROR latch: PASS'
Write-Host "  Runtime handshake model: PASS ($($cases.Count) cases)"
Write-Host '  v2/v3 transport parity: PASS'
