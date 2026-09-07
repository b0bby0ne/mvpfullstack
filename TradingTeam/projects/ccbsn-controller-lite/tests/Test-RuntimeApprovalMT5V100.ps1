[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$evidenceRoot = Join-Path $PSScriptRoot 'runtime-approval\evidence'
$status = Get-Content -LiteralPath (Join-Path $evidenceRoot 'status.log') -Raw -Encoding UTF8
$on = Get-Content -LiteralPath (Join-Path $evidenceRoot 'handshake-on.log') -Raw -Encoding UTF8
$off = Get-Content -LiteralPath (Join-Path $evidenceRoot 'handshake-off.log') -Raw -Encoding UTF8
$report = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'reports\MT5_V1_NEW_CYCLE_RUNTIME_APPROVAL.md') -Raw -Encoding UTF8
$source = Get-Content -LiteralPath (Join-Path $projectRoot 'src\mt5\CCBSN_Controller_Lite_Ver3_M5.mq5') -Raw -Encoding UTF8
$manifest = Get-Content -LiteralPath (Join-Path $evidenceRoot 'SHA256.txt') -Encoding UTF8

function Assert-Match([string] $Name, [string] $Text, [string] $Pattern) {
    if ($Text -notmatch $Pattern) { throw "Runtime approval contract missing: $Name" }
}

Assert-Match 'deployment pass' $status 'DEPLOY PASS'
if ([regex]::Matches($status, 'OFF HANDSHAKE PASS').Count -lt 2) {
    throw 'Runtime approval requires bootstrap and cleanup OFF handshakes.'
}
Assert-Match 'ON pass' $status 'ON HANDSHAKE PASS'
Assert-Match 'cleanup pass' $status 'CLEANUP OFF PASS'
Assert-Match 'approval pass' $status 'APPROVAL PASS'
Assert-Match 'profile restore' $status 'DEMO PROFILE RESTORED; TERMINAL STOPPED'

Assert-Match 'ON command sent' $on 'CONTROL SENT \| ENABLE NEW CYCLE'
Assert-Match 'ON consumed by CCBSN' $on 'Can Cu Bu Sieng Nang v3\.0 .*New Cycle'
Assert-Match 'ON ACK' $on 'CONTROL CONFIRMED \| ENABLE NEW CYCLE'
Assert-Match 'OFF command sent' $off 'CONTROL SENT \| DISABLE NEW CYCLE'
Assert-Match 'OFF consumed by CCBSN' $off 'Can Cu Bu Sieng Nang v3\.0 .*New Cycle'
Assert-Match 'OFF ACK' $off 'CONTROL CONFIRMED \| DISABLE NEW CYCLE'

foreach ($text in @($on, $off)) {
    if ($text -match 'CONTROL ERROR|MUTEX.*(LOST|ERROR)|CONTRACT.*MISMATCH') {
        throw 'Runtime approval evidence contains a fail-closed control error.'
    }
}

Assert-Match 'release hash' $report '987FD9C41BE39ACADEAA2BD83B71DEEACA5BA165F22AC700E71CEC8AD66CD814'
Assert-Match 'target CCBSN hash' $report 'F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68'
Assert-Match 'boot-race disclosure' $report 'first Buy(?s:.*)Buy Stop'
Assert-Match 'manual OFF bootstrap gate' $report 'bootstrap OFF'
Assert-Match 'safe default retained' $source 'InpControlMode\s*=\s*CCBSN_CONTROL_VISUAL_ONLY;'

$evidenceFiles = @{
    'status.log' = Join-Path $evidenceRoot 'status.log'
    'handshake-on.log' = Join-Path $evidenceRoot 'handshake-on.log'
    'handshake-off.log' = Join-Path $evidenceRoot 'handshake-off.log'
    'MT5_V1_NEW_CYCLE_RUNTIME_APPROVAL.md' = Join-Path $PSScriptRoot 'reports\MT5_V1_NEW_CYCLE_RUNTIME_APPROVAL.md'
}
foreach ($line in $manifest) {
    if ($line -notmatch '^([0-9A-F]{64}) \*(.+)$') { throw "Invalid evidence hash line: $line" }
    $name = $Matches[2]
    if (-not $evidenceFiles.ContainsKey($name)) { throw "Unknown evidence hash entry: $name" }
    if ((Get-FileHash -LiteralPath $evidenceFiles[$name] -Algorithm SHA256).Hash -ne $Matches[1]) {
        throw "Runtime evidence hash mismatch: $name"
    }
}

Write-Output 'PASS: MT5 v1.0.0 New Cycle runtime approval evidence'
Write-Output '  OFF -> ON -> OFF cleanup: PASS'
Write-Output '  Exact release/CCBSN hashes: PASS'
Write-Output '  Error/mutex/contract scan: PASS'
Write-Output '  Manual OFF bootstrap disclosure: PASS'
Write-Output '  Evidence SHA256 manifest: PASS'
