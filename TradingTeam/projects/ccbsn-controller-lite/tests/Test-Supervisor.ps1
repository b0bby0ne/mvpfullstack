[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$scriptPath = Join-Path $projectRoot 'tools\Start-CCBSNSupervised.ps1'
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
    @{ Name='Terminal/data-root identity'; Pattern='origin\.txt[\s\S]*?Terminal/data-root identity mismatch' },
    @{ Name='Controller hash pin'; Pattern='Assert-Hash \$ControllerBinary \$ExpectedControllerSha256' },
    @{ Name='CCBSN hash pin'; Pattern='Assert-Hash \$ccbsnTarget \$ExpectedCCBSNSha256' },
    @{ Name='Single supervisor mutex'; Pattern='CCBSN_SUPERVISOR_' },
    @{ Name='Preflight excludes CCBSN'; Pattern='New-BlankChart[\s\S]*?CCBSN loaded before OFF command was pre-seeded' },
    @{ Name='Preflight inherits live market identity'; Pattern='InpExpectedSymbolPrefix''[\s\S]*?''InpXAUQuoteDigits''[\s\S]*?New-MonitoredControllerChart \$PreflightControllerChart[\s\S]*?\$RuntimeControllerChart' },
    @{ Name='Monitor account pin'; Pattern='monitor\.account_login[\s\S]*?ExpectedAccount' },
    @{ Name='Fresh OFF command'; Pattern='pending_age_seconds[\s\S]*?-le 5' },
    @{ Name='Ticket continuity'; Pattern='last_confirmed_ticket -eq \[int64\]\$Ticket' },
    @{ Name='Barrier must release'; Pattern='-not \[bool\]\$monitor\.startup_cycle_barrier' },
    @{ Name='No drift at handoff'; Pattern='-not \[bool\]\$monitor\.drift' },
    @{ Name='Rejected Buy is failure'; Pattern='\(failed \)\?market buy' },
    @{ Name='CCBSN source staged before overwrite'; Pattern='runtimeCCBSNStagedChart[\s\S]*?Copy-Item -LiteralPath \$CCBSNChart' },
    @{ Name='Rollback chart and config'; Pattern='RESTORE PASS terminal-stopped profiles-config-controller-restored' },
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
