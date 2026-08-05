$ErrorActionPreference = 'Stop'

$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
if (-not (Test-Path -LiteralPath $chrome)) {
    throw "Chrome not found at $chrome"
}

$assistant = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'Publish_Assistant.html')).Path.Replace('\', '/')
Start-Process -FilePath $chrome -ArgumentList @('--new-window', "file:///$assistant")

