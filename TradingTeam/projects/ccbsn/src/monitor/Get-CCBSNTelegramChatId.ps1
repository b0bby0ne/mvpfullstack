param(
    [string]$EnvFile = (Join-Path $PSScriptRoot '..\..\..\..\.env')
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'CCBSNMonitor.psm1') -Force
Import-CCBSNEnvFile -Path $EnvFile
$token = [Environment]::GetEnvironmentVariable('CCBSN_TELEGRAM_BOT_TOKEN', 'Process')
if ([string]::IsNullOrWhiteSpace($token)) {
    throw 'CCBSN_TELEGRAM_BOT_TOKEN is missing from the local environment file.'
}

$bot = Invoke-CCBSNTelegramApi -Token $token -Method 'getMe' -Body @{}
if ($null -eq $bot -or [string]::IsNullOrWhiteSpace([string]$bot.username)) {
    throw 'Telegram token validation did not return a bot username.'
}
Write-Host "Token validated for @$($bot.username)."

$updates = @(Get-CCBSNTelegramUpdates -Token $token -Offset 1 -TimeoutSeconds 10)
$chatIds = @($updates | Where-Object { $null -ne $_.message.chat.id } |
    ForEach-Object { [long]$_.message.chat.id } | Sort-Object -Unique)
if ($chatIds.Count -eq 0) {
    Write-Host 'No chat ID found. Send /start to the bot, then run this script again.'
    exit 0
}
Write-Host 'Telegram chat IDs found:'
$chatIds | ForEach-Object { Write-Host "  $_" }
