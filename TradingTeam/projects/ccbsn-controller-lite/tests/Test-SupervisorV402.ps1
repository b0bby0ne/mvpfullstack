[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$localReleaseScript = Join-Path $PSScriptRoot 'Start-CCBSNSupervised-Ver4_0_2.ps1'
$scriptPath = if (Test-Path -LiteralPath $localReleaseScript) {
    $localReleaseScript
}
else {
    Join-Path $projectRoot 'tools\Start-CCBSNSupervised-Ver4_0_2.ps1'
}
$source = Get-Content -LiteralPath $scriptPath -Raw
$errors = [Collections.Generic.List[string]]::new()

$parseErrors = $null
$tokens = $null
[Management.Automation.Language.Parser]::ParseFile(
    $scriptPath, [ref]$tokens, [ref]$parseErrors) | Out-Null
foreach ($parseError in $parseErrors) {
    $errors.Add("PowerShell syntax: $($parseError.Message)")
}

$contracts = @(
    @{ Name='Supervisor version 4.0.2'; Pattern="supervisorVersion\s*=\s*'4\.0\.2'" },
    @{ Name='Terminal/data-root identity'; Pattern='origin\.txt[\s\S]*?Terminal/data-root identity mismatch' },
    @{ Name='Controller hash pin'; Pattern='Assert-Hash \$ControllerBinary \$ExpectedControllerSha256' },
    @{ Name='CCBSN hash pin'; Pattern='Assert-Hash \$ccbsnTarget \$ExpectedCCBSNSha256' },
    @{ Name='Single supervisor mutex'; Pattern='CCBSN_SUPERVISOR_' },
    @{ Name='Preflight excludes CCBSN'; Pattern='New-BlankChart[\s\S]*?CCBSN loaded before OFF command was pre-seeded' },
    @{ Name='Preflight preserves complete runtime input layout'; Pattern='function Set-PreflightFailClosedInputs[\s\S]*?New-MonitoredControllerChart \$RuntimeSource \$Destination' },
    @{ Name='Preflight applies approved fail-closed overrides'; Pattern='failClosedKeys[\s\S]*?InpEnableSession1[\s\S]*?InpForceSyncOnInit[\s\S]*?Preflight Controller is not fail-closed' },
    @{ Name='Preflight rejects missing runtime inputs'; Pattern='Runtime Controller profile is missing required input' },
    @{ Name='Dashboard title normalized'; Pattern='InpTextPanelTitle=[\s\S]*?ControllerDashboardTitle[\s\S]*?Cannot normalize the Controller dashboard title' },
    @{ Name='AutoTrading fail-closed setter'; Pattern='function Set-AutoTradingDisabled[\s\S]*?Enabled=0' },
    @{ Name='No-EA fail-closed staging'; Pattern='function Stage-FailClosedNoEA[\s\S]*?experts=none' },
    @{ Name='LiveUpdate process detection'; Pattern='function Get-LiveUpdateTerminalProcess[\s\S]*?liveUpdateRoot' },
    @{ Name='Respawn is stopped and restaged'; Pattern='TERMINAL_RESPAWN_DETECTED[\s\S]*?Stop-TargetTerminal[\s\S]*?Stage-FailClosedNoEA' },
    @{ Name='Minimum 60-second terminal quiescence'; Pattern='ValidateRange\(60, 180\).*TerminalQuiescenceSeconds = 60' },
    @{ Name='Bounded terminal quiescence'; Pattern='TerminalQuiescenceTimeoutSeconds[\s\S]*?QUIESCENT seconds=' },
    @{ Name='Update warmup precedes trading enable'; Pattern='Invoke-UpdateSafeWarmup[\s\S]*?Set-AutoTradingEnabled[\s\S]*?PHASE1' },
    @{ Name='Warmup no-EA evidence and assertion'; Pattern='update-warmup-expert\.log[\s\S]*?UPDATE_WARMUP_FAIL: an EA or entry attempt' },
    @{ Name='Phase1 detects late update'; Pattern='warmedTerminalHash[\s\S]*?PHASE1_FAIL: terminal/update activity changed' },
    @{ Name='Quiescent rollback before restore'; Pattern="Stage-FailClosedNoEA 'RESTORE_GUARD'[\s\S]*?Wait-TerminalQuiescent 'RESTORE_GUARD'[\s\S]*?backupRoot 'chart01\.chr'" },
    @{ Name='Monitor account pin'; Pattern='monitor\.account_login[\s\S]*?ExpectedAccount' },
    @{ Name='Fresh OFF command'; Pattern='pending_age_seconds[\s\S]*?-le 5' },
    @{ Name='Ticket continuity'; Pattern='last_confirmed_ticket -eq \[int64\]\$Ticket' },
    @{ Name='Barrier must release'; Pattern='-not \[bool\]\$monitor\.startup_cycle_barrier' },
    @{ Name='No drift at handoff'; Pattern='-not \[bool\]\$monitor\.drift' },
    @{ Name='Rejected Buy is failure'; Pattern='\(failed \)\?market buy' },
    @{ Name='CCBSN source staged before overwrite'; Pattern='runtimeCCBSNStagedChart[\s\S]*?Copy-Item -LiteralPath \$CCBSNChart' },
    @{ Name='Rollback chart and config'; Pattern='RESTORE PASS quiescent-terminal profiles-config-controller-restored' },
    @{ Name='Open-chain safety hold'; Pattern='monitorHasOpenChain[\s\S]*?SAFETY HOLD terminal left running' }
)

foreach ($contract in $contracts) {
    if ($source -notmatch $contract.Pattern) {
        $errors.Add("Missing supervisor contract: $($contract.Name)")
    }
}

if ($errors.Count -gt 0) {
    Write-Host "FAIL: $scriptPath"
    foreach ($errorMessage in $errors) { Write-Host "  - $errorMessage" }
    exit 1
}

Write-Host "PASS: $scriptPath"
Write-Host "  Syntax: PASS"
Write-Host "  Fail-closed supervisor contracts: PASS ($($contracts.Count))"
