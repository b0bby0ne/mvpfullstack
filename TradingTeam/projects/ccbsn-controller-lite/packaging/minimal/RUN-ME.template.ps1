[CmdletBinding()]
param(
    [string] $TerminalPath = '',
    [string] $AccountLogin = '',
    [string] $ExpectedServer = '',
    [string] $Symbol = '',
    [ValidateSet(0, 2, 3)] [int] $QuoteDigits = 0,
    [string] $ExpectedSymbolPrefix = 'XAUUSD',
    [string] $DataRoot = '',
    [string] $WorkRoot = '',
    [switch] $PrepareOnly,
    [switch] $ReplaceCCBSNBinary
)

$ErrorActionPreference = 'Stop'
$controllerHash = 'C33881E6738F80BC003ED2792E27C8807E58066F5C172AACA4F2212C3C017D65'
$ccbsnHash = 'F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68'
$engineZipHash = '__ENGINE_ZIP_SHA256__'
$engineZipBase64 = @'
__ENGINE_ZIP_BASE64__
'@

function Read-Required([string] $Current, [string] $Prompt) {
    if ($Current) { return $Current }
    $value = Read-Host $Prompt
    if (-not $value) { throw "$Prompt is required." }
    return $value
}

function Assert-Hash([string] $Path, [string] $Expected, [string] $Label) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Label is missing: $Path"
    }
    $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    if ($actual -ne $Expected) {
        throw "$Label hash mismatch: expected=$Expected actual=$actual"
    }
}

Write-Host 'CC Controller M5 Ver4.0 - Minimal portable package'
Write-Host 'Đăng nhập MT5 trước, sau đó đóng terminal hoàn toàn để deploy.'
$TerminalPath = Read-Required $TerminalPath 'Đường dẫn đầy đủ tới terminal64.exe'
$AccountLogin = Read-Required $AccountLogin 'MT5 account login'
if ($AccountLogin -notmatch '^[0-9]+$') { throw 'Account login must contain digits only.' }
$ExpectedServer = Read-Required $ExpectedServer 'Tên server chính xác'
$Symbol = Read-Required $Symbol 'Tên symbol vàng chính xác'
if ($QuoteDigits -eq 0) {
    $quoteText = Read-Host 'Số chữ số quote của symbol (2 hoặc 3)'
    if ($quoteText -notin @('2', '3')) { throw 'Quote digits must be 2 or 3.' }
    $QuoteDigits = [int]$quoteText
}

$bundleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$controller = Join-Path $bundleRoot 'CC_Controller_M5_Ver4_0.ex5'
$ccbsn = Join-Path $bundleRoot 'Can Cu Bu Sieng Nang v3.0.ex5'
Assert-Hash $controller $controllerHash 'Controller EX5'
Assert-Hash $ccbsn $ccbsnHash 'CCBSN EX5'

if (-not $WorkRoot) {
    $WorkRoot = Join-Path $env:LOCALAPPDATA "CCBSN\ControllerM5Ver4\$AccountLogin"
}
New-Item -ItemType Directory -Path $WorkRoot -Force | Out-Null
$WorkRoot = (Get-Item -LiteralPath $WorkRoot).FullName
$engineRoot = Join-Path $WorkRoot 'engine-ver4.0.2'
New-Item -ItemType Directory -Path $engineRoot -Force | Out-Null
$engineZip = Join-Path $WorkRoot 'engine-ver4.0.2.zip'
$engineBytes = [Convert]::FromBase64String(
    ($engineZipBase64 -replace '\s', ''))
[IO.File]::WriteAllBytes($engineZip, $engineBytes)
Assert-Hash $engineZip $engineZipHash 'Embedded supervisor engine'
Expand-Archive -LiteralPath $engineZip -DestinationPath $engineRoot -Force
Copy-Item -LiteralPath $controller -Destination $engineRoot -Force
Copy-Item -LiteralPath $ccbsn -Destination $engineRoot -Force

$installer = Join-Path $engineRoot 'Install-And-Start-CCControllerM5Ver4.ps1'
$arguments = @{
    TerminalPath = $TerminalPath
    AccountLogin = $AccountLogin
    ExpectedServer = $ExpectedServer
    Symbol = $Symbol
    QuoteDigits = $QuoteDigits
    ExpectedSymbolPrefix = $ExpectedSymbolPrefix
    WorkRoot = $WorkRoot
}
if ($DataRoot) { $arguments.DataRoot = $DataRoot }
if ($PrepareOnly) { $arguments.PrepareOnly = $true }
if ($ReplaceCCBSNBinary) { $arguments.ReplaceCCBSNBinary = $true }

& $installer @arguments
