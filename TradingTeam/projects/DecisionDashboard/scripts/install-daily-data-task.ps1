$ErrorActionPreference = "Stop"

$taskName = "DecisionDashboard-GoldMacro-Daily"
$projectPath = Split-Path -Parent $PSScriptRoot
$npmPath = (Get-Command npm.cmd -ErrorAction Stop).Source
$command = '"{0}" run data:refresh' -f $npmPath
$action = New-ScheduledTaskAction -Execute $env:ComSpec -Argument "/d /s /c `"$command`"" -WorkingDirectory $projectPath
$trigger = New-ScheduledTaskTrigger -Daily -At "06:05"
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 10)

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description "Refresh DecisionDashboard XAU macro source health daily at 06:05 Asia/Ho_Chi_Minh." -Force | Out-Null
Write-Host "Scheduled task '$taskName' installed for 06:05 daily."
