[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $TerminalPath,
    [Parameter(Mandatory)] [ValidatePattern('^[0-9]+$')] [string] $AccountLogin,
    [Parameter(Mandatory)] [string] $ExpectedServer,
    [Parameter(Mandatory)] [string] $Symbol,
    [Parameter(Mandatory)] [ValidateSet(2, 3)] [int] $QuoteDigits,
    [string] $ExpectedSymbolPrefix = 'XAUUSD',
    [string] $DataRoot = '',
    [string] $WorkRoot = '',
    [switch] $PrepareOnly,
    [switch] $ReplaceCCBSNBinary
)

$ErrorActionPreference = 'Stop'
$bundleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$controllerHash = 'C33881E6738F80BC003ED2792E27C8807E58066F5C172AACA4F2212C3C017D65'
$ccbsnHash = 'F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68'
$policyVersion = '4.0.0-supervisor'

function Get-FullExistingPath([string] $Path, [string] $Label) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Label does not exist: $Path"
    }
    (Get-Item -LiteralPath $Path).FullName
}

function Assert-Hash([string] $Path, [string] $Expected, [string] $Label) {
    $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    if ($actual -ne $Expected.ToUpperInvariant()) {
        throw "$Label hash mismatch: expected=$Expected actual=$actual path=$Path"
    }
}

function Assert-PackageManifest {
    $manifestPath = Join-Path $bundleRoot 'SHA256.txt'
    $manifest = Get-Content -LiteralPath $manifestPath
    foreach ($line in $manifest) {
        if ($line -notmatch '^([A-Fa-f0-9]{64}) \*(.+)$') {
            throw "Invalid package manifest line: $line"
        }
        $filePath = Join-Path $bundleRoot $matches[2]
        Assert-Hash $filePath $matches[1] "Package file $($matches[2])"
    }
}

function Resolve-MT5DataRoot([string] $RequestedRoot,
                             [string] $TerminalDirectory) {
    if ($RequestedRoot) {
        $resolved = Get-FullExistingPath $RequestedRoot 'MT5 data root'
        $originPath = Join-Path $resolved 'origin.txt'
        $null = Get-FullExistingPath $originPath 'MT5 origin.txt'
        $origin = (Get-Content -LiteralPath $originPath -Raw).Trim().TrimEnd('\')
        if (-not $origin.Equals($TerminalDirectory.TrimEnd('\'),
                [StringComparison]::OrdinalIgnoreCase)) {
            throw "Terminal/data-root identity mismatch: origin=$origin terminal=$TerminalDirectory"
        }
        return $resolved
    }

    $terminalStore = Join-Path $env:APPDATA 'MetaQuotes\Terminal'
    $matchesFound = @()
    foreach ($candidate in Get-ChildItem -LiteralPath $terminalStore -Directory) {
        $originPath = Join-Path $candidate.FullName 'origin.txt'
        if (-not (Test-Path -LiteralPath $originPath)) { continue }
        $origin = (Get-Content -LiteralPath $originPath -Raw).Trim().TrimEnd('\')
        if ($origin.Equals($TerminalDirectory.TrimEnd('\'),
                [StringComparison]::OrdinalIgnoreCase)) {
            $matchesFound += $candidate.FullName
        }
    }
    if ($matchesFound.Count -ne 1) {
        throw "Cannot uniquely discover MT5 data root for $TerminalDirectory. Pass -DataRoot explicitly. Matches=$($matchesFound.Count)"
    }
    return $matchesFound[0]
}

function Set-RequiredChartValue([string] $Text, [string] $Key,
                                [string] $Value) {
    if ($Text -notmatch "(?m)^$([regex]::Escape($Key))=") {
        throw "Portable chart is missing required field: $Key"
    }
    [regex]::Replace($Text, "(?m)^$([regex]::Escape($Key))=.*$",
        "$Key=$Value", 1)
}

function New-PortableChart([string] $Source, [string] $Destination,
                           [bool] $IsController) {
    $text = Get-Content -LiteralPath $Source -Raw -Encoding Unicode
    $text = Set-RequiredChartValue $text 'symbol' $Symbol
    $text = Set-RequiredChartValue $text 'period_type' '0'
    $text = Set-RequiredChartValue $text 'period_size' '5'
    if ($IsController) {
        $text = Set-RequiredChartValue $text 'InpExpectedSymbolPrefix' `
            $ExpectedSymbolPrefix
        $text = Set-RequiredChartValue $text 'InpXAUQuoteDigits' `
            ([string]$QuoteDigits)
        $text = Set-RequiredChartValue $text 'InpControlMode' '1'
        $text = Set-RequiredChartValue $text 'InpForceSyncOnInit' 'true'
        $text = Set-RequiredChartValue $text 'InpTextPanelTitle' `
            'CC CONTROLLER M5 | VER4.0'
        $inputBlock = [regex]::Match($text,
            '(?s)<inputs>(.*?)</inputs>').Groups[1].Value
        $inputCount = [regex]::Matches($inputBlock,
            '(?m)^[A-Za-z][A-Za-z0-9_]*=').Count
        if ($inputCount -lt 130) {
            throw "Controller profile is incomplete: inputs=$inputCount expected>=130"
        }
    }
    [IO.File]::WriteAllText($Destination, $text, [Text.Encoding]::Unicode)
}

function Get-TargetTerminalProcess([string] $TargetPath) {
    @(Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object {
        try { $_.Path -eq $TargetPath } catch { $false }
    })
}

function Stop-TargetFailClosed([string] $TargetPath, [string] $CommonIni) {
    foreach ($process in Get-TargetTerminalProcess $TargetPath) {
        $null = $process.CloseMainWindow()
    }
    $deadline = (Get-Date).AddSeconds(15)
    while (@(Get-TargetTerminalProcess $TargetPath).Count -gt 0 -and
           (Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 250
    }
    foreach ($process in Get-TargetTerminalProcess $TargetPath) {
        Stop-Process -Id $process.Id -Force
    }
    $commonText = Get-Content -LiteralPath $CommonIni -Raw
    $commonText = [regex]::Replace($commonText,
        '(?m)^Enabled=\d+\s*$', 'Enabled=0', 1)
    [IO.File]::WriteAllText($CommonIni, $commonText,
        [Text.UTF8Encoding]::new($false))
}

Assert-PackageManifest
$TerminalPath = Get-FullExistingPath $TerminalPath 'MT5 terminal executable'
if ([IO.Path]::GetFileName($TerminalPath) -ne 'terminal64.exe') {
    throw 'TerminalPath must point to terminal64.exe.'
}
$terminalDirectory = Split-Path -Parent $TerminalPath
$DataRoot = Resolve-MT5DataRoot $DataRoot $terminalDirectory

if (-not $WorkRoot) {
    $WorkRoot = Join-Path $env:LOCALAPPDATA `
        "CCBSN\ControllerM5Ver4\$AccountLogin"
}
New-Item -ItemType Directory -Path $WorkRoot -Force | Out-Null
$WorkRoot = (Get-Item -LiteralPath $WorkRoot).FullName
$runtimeController = Join-Path $WorkRoot 'runtime-controller-ver4.chr'
$runtimeCCBSN = Join-Path $WorkRoot 'runtime-ccbsn-v3.chr'
New-PortableChart (Join-Path $bundleRoot 'runtime-controller-template.chr') `
    $runtimeController $true
New-PortableChart (Join-Path $bundleRoot 'runtime-ccbsn-template.chr') `
    $runtimeCCBSN $false

$summary = [pscustomobject]@{
    TerminalPath = $TerminalPath
    DataRoot = $DataRoot
    AccountLogin = $AccountLogin
    ExpectedServer = $ExpectedServer
    Symbol = $Symbol
    QuoteDigits = $QuoteDigits
    RuntimeControllerChart = $runtimeController
    RuntimeCCBSNChart = $runtimeCCBSN
    PrepareOnly = [bool]$PrepareOnly
}
$summary | Format-List | Out-String | Write-Host
if ($PrepareOnly) {
    Write-Host 'PREPARE_ONLY PASS: no MT5 files or processes were changed.'
    return
}

if (@(Get-TargetTerminalProcess $TerminalPath).Count -gt 0) {
    throw 'Target terminal is running. Close it cleanly before installation.'
}

$chartRoot = Join-Path $DataRoot 'MQL5\Profiles\Charts\Default'
$commonIni = Join-Path $DataRoot 'config\common.ini'
foreach ($required in @($chartRoot, (Join-Path $chartRoot 'chart01.chr'),
                         (Join-Path $chartRoot 'chart02.chr'), $commonIni)) {
    $null = Get-FullExistingPath $required 'Required MT5 runtime path'
}

$ccbsnSource = Join-Path $bundleRoot 'Can Cu Bu Sieng Nang v3.0.ex5'
Assert-Hash $ccbsnSource $ccbsnHash 'Packaged CCBSN'
$ccbsnTarget = Join-Path $DataRoot 'MQL5\Experts\Can Cu Bu Sieng Nang v3.0.ex5'
if (Test-Path -LiteralPath $ccbsnTarget) {
    $currentHash = (Get-FileHash -LiteralPath $ccbsnTarget -Algorithm SHA256).Hash
    if ($currentHash -ne $ccbsnHash) {
        if (-not $ReplaceCCBSNBinary) {
            throw "A different CCBSN binary already exists. Re-run with -ReplaceCCBSNBinary only after reviewing it. Existing hash=$currentHash"
        }
        $backup = Join-Path $WorkRoot (
            'Can Cu Bu Sieng Nang v3.0.{0}.backup.ex5' -f
            (Get-Date -Format 'yyyyMMdd-HHmmss'))
        Copy-Item -LiteralPath $ccbsnTarget -Destination $backup -Force
    }
}
Copy-Item -LiteralPath $ccbsnSource -Destination $ccbsnTarget -Force
Assert-Hash $ccbsnTarget $ccbsnHash 'Installed CCBSN'

$supervisor = Join-Path $bundleRoot `
    'Start-CCBSNSupervised-Ver4_0_2.ps1'
& $supervisor `
    -TerminalPath $TerminalPath `
    -DataRoot $DataRoot `
    -ControllerBinary (Join-Path $bundleRoot 'CC_Controller_M5_Ver4_0.ex5') `
    -PreflightControllerChart (Join-Path $bundleRoot 'supervisor-preflight-off.chr') `
    -RuntimeControllerChart $runtimeController `
    -CCBSNChart $runtimeCCBSN `
    -ExpectedControllerSha256 $controllerHash `
    -ExpectedCCBSNSha256 $ccbsnHash `
    -ExpectedAccount $AccountLogin `
    -EvidenceRoot (Join-Path $WorkRoot 'evidence') `
    -ControllerExpertFileName 'CC_Controller_M5_Ver4_0.ex5' `
    -ExpectedPolicyVersion $policyVersion `
    -PreflightTimeoutSeconds 120 `
    -RuntimeTimeoutSeconds 120 `
    -PostAckAuditSeconds 65 `
    -UpdateWarmupSeconds 70 `
    -TerminalQuiescenceSeconds 60 `
    -TerminalQuiescenceTimeoutSeconds 180

$mutexBytes = [Text.Encoding]::UTF8.GetBytes($DataRoot.ToUpperInvariant())
$sha = [Security.Cryptography.SHA256]::Create()
try {
    $suffix = ([BitConverter]::ToString(
        $sha.ComputeHash($mutexBytes))).Replace('-', '').Substring(0, 16)
}
finally { $sha.Dispose() }
$terminalBase = Split-Path -Parent $DataRoot
$monitorPath = Join-Path (Join-Path $terminalBase 'Common\Files') `
    "CCBSN\supervisor_$suffix.json"
$monitor = Get-Content -LiteralPath $monitorPath -Raw | ConvertFrom-Json
if ([string]$monitor.account_login -ne $AccountLogin -or
    [string]$monitor.account_server -ne $ExpectedServer -or
    -not [bool]$monitor.terminal_connected -or
    -not [bool]$monitor.configuration_valid -or
    [string]$monitor.cycle_consistency -ne 'ALIGNED' -or
    [string]$monitor.pending_command -ne 'NONE' -or
    [bool]$monitor.startup_cycle_barrier -or
    [bool]$monitor.drift) {
    Stop-TargetFailClosed $TerminalPath $commonIni
    throw "Post-handoff identity/state mismatch. Terminal stopped fail-closed. Monitor=$monitorPath"
}

Write-Host "PORTABLE DEPLOY PASS: account=$AccountLogin server=$ExpectedServer symbol=$Symbol cycle=ALIGNED"
Write-Host "Monitor: $monitorPath"
Write-Host "Evidence: $(Join-Path $WorkRoot 'evidence')"
