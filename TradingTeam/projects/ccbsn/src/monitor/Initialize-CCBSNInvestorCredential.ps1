param(
    [string]$Server = 'Exness-MT5Real20'
)

$ErrorActionPreference = 'Stop'
$credentialRoot = Join-Path $env:LOCALAPPDATA 'CCBSNMonitor'
$credentialPath = Join-Path $credentialRoot 'mt5-investor.credential.xml'
$metadataPath = Join-Path $credentialRoot 'mt5-investor.json'
[IO.Directory]::CreateDirectory($credentialRoot) | Out-Null

$credential = Get-Credential -Message 'Enter the MT5 INVESTOR/VIEW login and password. Do not enter a master trading password.'
if ($null -eq $credential -or
    [string]::IsNullOrWhiteSpace($credential.UserName) -or
    [string]::IsNullOrEmpty($credential.GetNetworkCredential().Password)) {
    throw 'Investor credential entry was cancelled or incomplete.'
}

$temporaryCredential = "$credentialPath.tmp"
$temporaryMetadata = "$metadataPath.tmp"
$credential | Export-Clixml -LiteralPath $temporaryCredential
$metadata = [ordered]@{
    server = $Server
    purpose = 'MT5_INVESTOR_READ_ONLY'
    created_at_utc = [DateTimeOffset]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
}
[IO.File]::WriteAllText(
    $temporaryMetadata,
    (($metadata | ConvertTo-Json) + [Environment]::NewLine),
    [Text.UTF8Encoding]::new($false)
)
Move-Item -LiteralPath $temporaryCredential -Destination $credentialPath -Force
Move-Item -LiteralPath $temporaryMetadata -Destination $metadataPath -Force

Write-Host 'Investor credential saved with Windows DPAPI.' -ForegroundColor Green
Write-Host 'Close this window and return to Codex.'
