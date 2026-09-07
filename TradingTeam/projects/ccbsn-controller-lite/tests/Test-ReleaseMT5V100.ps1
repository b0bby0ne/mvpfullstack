[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$releaseRoot = Join-Path $projectRoot 'releases\mt5-v1.0.0'
$canonicalSource = Join-Path $projectRoot 'src\mt5\CCBSN_Controller_Lite_Ver3_M5.mq5'
$compileLog = Join-Path $projectRoot 'build\compile-ver3-m5.log'
$manifestPath = Join-Path $releaseRoot 'SHA256.txt'
$archivePath = Join-Path $projectRoot 'releases\ccbsn-controller-lite-mt5-v1.0.0.zip'
$archiveHashPath = "$archivePath.sha256"
$requiredFiles = @(
    'CCBSN_Controller_Lite_Ver3_M5.mq5',
    'CCBSN_Controller_Lite_Ver3_M5.ex5',
    'RELEASE.md',
    'SHA256.txt'
)

foreach ($name in $requiredFiles) {
    $path = Join-Path $releaseRoot $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Release artifact missing: $name"
    }
}

if (-not (Test-Path -LiteralPath $archivePath -PathType Leaf)) {
    throw 'Release ZIP is missing.'
}
if (-not (Test-Path -LiteralPath $archiveHashPath -PathType Leaf)) {
    throw 'Release ZIP checksum is missing.'
}

$manifestEntries = @{}
foreach ($line in Get-Content -LiteralPath $manifestPath -Encoding UTF8) {
    if ($line -notmatch '^([0-9A-F]{64}) \*(.+)$') {
        throw "Invalid SHA256 manifest line: $line"
    }
    $manifestEntries[$Matches[2]] = $Matches[1]
}

foreach ($name in $requiredFiles | Where-Object { $_ -ne 'SHA256.txt' }) {
    if (-not $manifestEntries.ContainsKey($name)) {
        throw "SHA256 manifest entry missing: $name"
    }
    $actual = (Get-FileHash -LiteralPath (Join-Path $releaseRoot $name) `
        -Algorithm SHA256).Hash
    if ($actual -ne $manifestEntries[$name]) {
        throw "SHA256 mismatch: $name"
    }
}

$releaseSource = Join-Path $releaseRoot 'CCBSN_Controller_Lite_Ver3_M5.mq5'
$releaseBinary = Join-Path $releaseRoot 'CCBSN_Controller_Lite_Ver3_M5.ex5'
if ((Get-FileHash $releaseSource -Algorithm SHA256).Hash -ne `
    (Get-FileHash $canonicalSource -Algorithm SHA256).Hash) {
    throw 'Release MQ5 does not match canonical source.'
}
if ((Get-Item -LiteralPath $releaseBinary).Length -lt 100000) {
    throw 'Release EX5 is unexpectedly small.'
}
if (-not (Test-Path -LiteralPath $compileLog -PathType Leaf)) {
    throw 'MetaEditor compile evidence is missing.'
}
$compileEvidence = Get-Content -LiteralPath $compileLog -Raw -Encoding Unicode
if ($compileEvidence -notmatch 'Result:\s+0 errors,\s+0 warnings') {
    throw 'Current source compile evidence is not 0 errors, 0 warnings.'
}

$source = Get-Content -LiteralPath $releaseSource -Raw -Encoding UTF8
if ($source -notmatch 'POLICY_VERSION\s*=\s*"1\.0\.0-mt5-cycle-consistency"') {
    throw 'Release source version contract is invalid.'
}
if ($source -notmatch 'InpControlMode\s*=\s*CCBSN_CONTROL_VISUAL_ONLY;') {
    throw 'Release source does not retain Visual Only safe default.'
}

$archiveHashLine = Get-Content -LiteralPath $archiveHashPath -Raw -Encoding UTF8
if ($archiveHashLine.Trim() -notmatch '^([0-9A-F]{64}) \*ccbsn-controller-lite-mt5-v1\.0\.0\.zip$') {
    throw 'Release ZIP checksum format is invalid.'
}
if ((Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash -ne $Matches[1]) {
    throw 'Release ZIP checksum mismatch.'
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($archivePath)
try {
    $zipNames = @($zip.Entries | ForEach-Object { $_.FullName })
    foreach ($name in $requiredFiles) {
        if ($name -notin $zipNames) {
            throw "Release ZIP entry missing: $name"
        }
    }
}
finally {
    $zip.Dispose()
}

Write-Output "PASS: $releaseRoot"
Write-Output "  Package files: $($requiredFiles.Count)"
Write-Output '  Manifest SHA256: PASS (3 artifacts)'
Write-Output '  Canonical source parity: PASS'
Write-Output '  Release EX5 manifest/size: PASS'
Write-Output '  Current source compile: PASS (0 errors, 0 warnings)'
Write-Output '  Visual Only safe default: PASS'
Write-Output '  ZIP checksum/content: PASS'
