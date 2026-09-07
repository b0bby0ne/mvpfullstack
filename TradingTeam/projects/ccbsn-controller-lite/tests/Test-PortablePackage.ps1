[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $PackageRoot
)

$ErrorActionPreference = 'Stop'
$errors = [Collections.Generic.List[string]]::new()
$installer = Join-Path $PackageRoot `
    'Install-And-Start-CCControllerM5Ver4.ps1'
$supervisor = Join-Path $PackageRoot `
    'Start-CCBSNSupervised-Ver4_0_2.ps1'

foreach ($script in @($installer, $supervisor)) {
    $parseErrors = $null
    $tokens = $null
    [Management.Automation.Language.Parser]::ParseFile(
        $script, [ref]$tokens, [ref]$parseErrors) | Out-Null
    foreach ($parseError in $parseErrors) {
        $errors.Add("$script syntax: $($parseError.Message)")
    }
}

$source = Get-Content -LiteralPath $installer -Raw
$contracts = @(
    @{ Name='No Real20 account hard-code'; Pattern="ExpectedAccount[^`r`n]*[=:][^`r`n]*'[0-9]{6,12}'"; MustNotMatch=$true },
    @{ Name='No Real20 terminal hard-code'; Pattern='D:\\ccController'; MustNotMatch=$true },
    @{ Name='Manifest verification'; Pattern='function Assert-PackageManifest' },
    @{ Name='Data-root autodiscovery'; Pattern='function Resolve-MT5DataRoot[\s\S]*?origin\.txt' },
    @{ Name='Terminal must be stopped'; Pattern='Target terminal is running' },
    @{ Name='Explicit account server pin'; Pattern='monitor\.account_server -ne \$ExpectedServer' },
    @{ Name='M5 profile pin'; Pattern="period_size' '5'" },
    @{ Name='Quote digits required'; Pattern='ValidateSet\(2, 3\)' },
    @{ Name='Full Ver4 input layout'; Pattern='inputCount -lt 130' },
    @{ Name='Control enabled'; Pattern="InpControlMode' '1'" },
    @{ Name='Force sync enabled'; Pattern="InpForceSyncOnInit' 'true'" },
    @{ Name='Different CCBSN requires consent'; Pattern='ReplaceCCBSNBinary only after reviewing' },
    @{ Name='Post-handoff fail closed'; Pattern='Stop-TargetFailClosed[\s\S]*?Post-handoff identity/state mismatch' },
    @{ Name='Prepare-only mode'; Pattern='PREPARE_ONLY PASS: no MT5 files or processes were changed' }
)
foreach ($contract in $contracts) {
    $matched = $source -match $contract.Pattern
    if (($contract.MustNotMatch -and $matched) -or
        (-not $contract.MustNotMatch -and -not $matched)) {
        $errors.Add("Portable contract failed: $($contract.Name)")
    }
}

$manifestPath = Join-Path $PackageRoot 'SHA256.txt'
$manifest = Get-Content -LiteralPath $manifestPath
foreach ($line in $manifest) {
    if ($line -notmatch '^([A-F0-9]{64}) \*(.+)$') {
        $errors.Add("Invalid manifest line: $line")
        continue
    }
    $path = Join-Path $PackageRoot $matches[2]
    if (-not (Test-Path -LiteralPath $path)) {
        $errors.Add("Manifest file missing: $($matches[2])")
        continue
    }
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne
        $matches[1]) {
        $errors.Add("Manifest hash mismatch: $($matches[2])")
    }
}

foreach ($chartSpec in @(
    @{ Name='runtime-controller-template.chr'; Expert='CC_Controller_M5_Ver4_0'; Controller=$true },
    @{ Name='runtime-ccbsn-template.chr'; Expert='Can Cu Bu Sieng Nang v3.0'; Controller=$false }
)) {
    $path = Join-Path $PackageRoot $chartSpec.Name
    $text = Get-Content -LiteralPath $path -Raw -Encoding Unicode
    if ($text -notmatch "(?m)^name=$([regex]::Escape($chartSpec.Expert))\s*$" -or
        $text -notmatch '(?m)^period_size=5\s*$') {
        $errors.Add("Chart identity/M5 mismatch: $($chartSpec.Name)")
    }
    if ($chartSpec.Controller) {
        $inputs = [regex]::Match($text,
            '(?s)<inputs>(.*?)</inputs>').Groups[1].Value
        $count = [regex]::Matches($inputs,
            '(?m)^[A-Za-z][A-Za-z0-9_]*=').Count
        if ($count -lt 130) {
            $errors.Add("Controller template input layout incomplete: $count")
        }
    }
}

if ($errors.Count) {
    Write-Host "FAIL: portable package $PackageRoot"
    foreach ($message in $errors) { Write-Host "  - $message" }
    exit 1
}
Write-Host "PASS: portable package $PackageRoot"
Write-Host "  Syntax: PASS (2/2)"
Write-Host "  Safety contracts: PASS ($($contracts.Count)/$($contracts.Count))"
Write-Host "  Manifest: PASS ($($manifest.Count)/$($manifest.Count))"
