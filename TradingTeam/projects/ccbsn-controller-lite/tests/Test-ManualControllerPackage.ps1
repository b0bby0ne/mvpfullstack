[CmdletBinding()]
param(
    [string] $PackageRoot = ''
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $PackageRoot) {
    $PackageRoot = Join-Path $projectRoot `
        'releases\cc-controller-m5-ver4.1-integrated-minimal'
}
$PackageRoot = (Get-Item -LiteralPath $PackageRoot).FullName
$errors = [Collections.Generic.List[string]]::new()
$expectedFiles = @('CC_Controller_M5_Ver4_1.ex5', 'README.md')
$actualFiles = @(Get-ChildItem -LiteralPath $PackageRoot -File |
    Select-Object -ExpandProperty Name | Sort-Object)
if (@(Compare-Object ($expectedFiles | Sort-Object) $actualFiles).Count) {
    $errors.Add("Package must contain exactly Controller + README: $($actualFiles -join ', ')")
}

$controller = Join-Path $PackageRoot 'CC_Controller_M5_Ver4_1.ex5'
$expectedHash = '2F96F8BD24712FC94C512EB690185A547D346E1369CFA96A9A025240E9A789E4'
if (-not (Test-Path -LiteralPath $controller)) {
    $errors.Add('Controller EX5 is missing.')
}
elseif ((Get-FileHash -LiteralPath $controller -Algorithm SHA256).Hash -ne
        $expectedHash) {
    $errors.Add('Controller EX5 hash mismatch.')
}

$readmePath = Join-Path $PackageRoot 'README.md'
if (-not (Test-Path -LiteralPath $readmePath)) {
    $errors.Add('README.md is missing.')
}
else {
    $readme = Get-Content -LiteralPath $readmePath -Raw -Encoding UTF8
    foreach ($contract in @(
        'InpExpectedAccountLogin',
        'InpExpectedAccountServer',
        'InpAutoDetectQuoteDigits',
        'InpForceSyncOnInit',
        'DISABLE PENDING',
        'NC DISABLED',
        'ALIGNED',
        'startup barrier: `false`',
        'OFF pre-seed',
        'broker round-trip',
        'launcher/supervisor'
    )) {
        if ($readme -notmatch [regex]::Escape($contract)) {
            $errors.Add("README is missing safety contract: $contract")
        }
    }
}

if ($errors.Count) {
    Write-Host "FAIL: $PackageRoot"
    foreach ($message in $errors) { Write-Host "  - $message" }
    exit 1
}
Write-Host 'PASS: manual Controller-only package'
Write-Host '  Files: Controller + README (2/2)'
Write-Host '  Controller hash: PASS'
Write-Host '  Manual OFF pre-seed checklist: PASS'
