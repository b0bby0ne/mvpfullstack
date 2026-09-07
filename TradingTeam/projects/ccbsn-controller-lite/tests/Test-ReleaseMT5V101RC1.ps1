[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$releaseRoot = Join-Path $projectRoot 'releases\mt5-v1.0.1-rc1'
$zipPath = Join-Path $projectRoot 'releases\ccbsn-controller-lite-mt5-v1.0.1-rc1.zip'
$expected = [ordered]@{
    'CCBSN_Controller_Lite_Ver3_M5.ex5' = '4AC32010DD09066C3D116E4A6A0EF3A872CB696BF453EF585BCEF95A16FA4FDF'
    'CCBSN_Controller_Lite_Ver3_M5.mq5' = '8199E13050F1E286B95341E81172919E4EFC3697B1C7A8EF99438C20A1C84416'
    'RELEASE.md' = '1D7A48E822D4981CE3F2AC6E4823EE66841F4C36A975B6B291E8AE0655D9349B'
    'RUNTIME_APPROVAL.md' = '4CF156256A8A4EBDF622F60301406D38C74ECE18F8785822DE082A1615431349'
    'Start-CCBSNSupervised.ps1' = '6AB87BDCA169DDC06702EA8177659A2994603C3008BD9B734395F8815329F076'
    'SUPERVISOR.md' = '9F2E699D0DF0D700869C14645EEC8B691CFF73A1E7002100F6E075151882E194'
    'supervisor-preflight-off.chr' = '9BC0C7A4D9518FD3151359496F9CA90022E5E1F0A19953E38F288CBBFB338E3F'
}

foreach ($entry in $expected.GetEnumerator()) {
    $path = Join-Path $releaseRoot $entry.Key
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    if ($actual -ne $entry.Value) {
        throw "Release hash mismatch: $($entry.Key) expected=$($entry.Value) actual=$actual"
    }
}

$zipHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
if ($zipHash -ne 'E86112BA8305289DAEF493970F035ADFD66E6AC32022A8CD8F5F15D5838F79DC') {
    throw "ZIP hash mismatch: $zipHash"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [IO.Compression.ZipFile]::OpenRead((Resolve-Path $zipPath))
try {
    $names = @($archive.Entries | ForEach-Object { $_.FullName })
    foreach ($name in @($expected.Keys) + 'SHA256.txt') {
        if ($name -notin $names) { throw "ZIP entry missing: $name" }
    }
}
finally {
    $archive.Dispose()
}

Write-Host "PASS: $releaseRoot"
Write-Host "  Artifact hashes: PASS ($($expected.Count))"
Write-Host "  ZIP hash/content: PASS"
