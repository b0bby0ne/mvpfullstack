param(
    [Parameter(Mandatory)] [string]$TerminalPath,
    [string]$ObserverScriptName = 'CCBSN_Account_Observer_Script',
    [string]$Symbol = 'XAUUSDc',
    [switch]$Visible
)

$ErrorActionPreference = 'Stop'
$credentialRoot = Join-Path $env:LOCALAPPDATA 'CCBSNMonitor'
$credentialPath = Join-Path $credentialRoot 'mt5-investor.credential.xml'
$metadataPath = Join-Path $credentialRoot 'mt5-investor.json'
$runtimeRoot = Join-Path $credentialRoot 'runtime'
$configPath = Join-Path $runtimeRoot 'investor-startup.ini'

if (-not [IO.File]::Exists($TerminalPath)) { throw 'Isolated MT5 terminal was not found.' }
if (-not [IO.File]::Exists($credentialPath) -or
    -not [IO.File]::Exists($metadataPath)) {
    throw 'DPAPI investor credential is not initialized.'
}
$sameTerminal = @(Get-Process terminal64 -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -eq $TerminalPath })
if ($sameTerminal.Count -gt 0) {
    throw 'The isolated investor terminal is already running.'
}

$credential = Import-Clixml -LiteralPath $credentialPath
$metadata = [IO.File]::ReadAllText($metadataPath) | ConvertFrom-Json
if ($credential -isnot [Management.Automation.PSCredential] -or
    [string]::IsNullOrWhiteSpace([string]$metadata.server)) {
    throw 'Investor credential or server metadata is invalid.'
}
$server = [string]$metadata.server
if ($server.Equals('exness-mt5-real20', [StringComparison]::OrdinalIgnoreCase)) {
    $server = 'Exness-MT5Real20'
}

[IO.Directory]::CreateDirectory($runtimeRoot) | Out-Null
$plainPassword = $credential.GetNetworkCredential().Password
$configuration = @"
[Common]
Login=$($credential.UserName)
Server=$server
Password=$plainPassword
KeepPrivate=0
NewsEnable=0
CertInstall=0

[Charts]
ProfileLast=Default
MaxBars=5000
SaveDeleted=0

[Experts]
AllowLiveTrading=0
AllowDllImport=0
Enabled=1
Account=1
Profile=1
Chart=0

[StartUp]
Script=$ObserverScriptName
Symbol=$Symbol
Period=M15
"@
[IO.File]::WriteAllText(
    $configPath,
    $configuration,
    [Text.UTF8Encoding]::new($false)
)
$configuration = $null
$plainPassword = $null
$credential = $null
$server = $null

try {
    $windowStyle = if ($Visible) { 'Normal' } else { 'Hidden' }
    $process = Start-Process -FilePath $TerminalPath `
        -ArgumentList "/config:$configPath" `
        -WorkingDirectory ([IO.Path]::GetDirectoryName($TerminalPath)) `
        -WindowStyle $windowStyle -PassThru
    Start-Sleep -Seconds 20
    if ($process.HasExited) { throw 'Isolated MT5 terminal exited during startup.' }
    Write-Host "Investor terminal started. PID=$($process.Id)"
}
finally {
    if ([IO.File]::Exists($configPath)) {
        [IO.File]::Delete($configPath)
    }
    [GC]::Collect()
}
