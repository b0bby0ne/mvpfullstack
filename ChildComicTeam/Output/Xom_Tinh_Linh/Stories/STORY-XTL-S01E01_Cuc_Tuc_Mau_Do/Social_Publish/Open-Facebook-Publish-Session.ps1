$ErrorActionPreference = 'Stop'

$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
if (-not (Test-Path -LiteralPath $chrome)) {
    throw "Chrome not found at $chrome"
}

$profile = Join-Path $PSScriptRoot '.facebook-publish-session'
$assistant = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'Publish_Assistant.html')).Path.Replace('\', '/')
New-Item -ItemType Directory -Force -Path $profile | Out-Null

$arguments = @(
    '--new-window'
    '--no-first-run'
    '--no-default-browser-check'
    '--remote-debugging-address=127.0.0.1'
    '--remote-debugging-port=9223'
    "--user-data-dir=$profile"
    'https://www.facebook.com/taisanchocon'
    "file:///$assistant"
)

Start-Process -FilePath $chrome -ArgumentList $arguments

