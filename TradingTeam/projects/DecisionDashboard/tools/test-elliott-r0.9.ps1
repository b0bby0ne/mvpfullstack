$ErrorActionPreference = "Stop"

function Get-ImpulseDirection {
  param([double[]]$Prices, [int[]]$Directions)

  if ($Prices.Count -ne 6 -or $Directions.Count -ne 6) {
    throw "Impulse fixture must contain exactly six pivots."
  }

  $wave1 = [Math]::Abs($Prices[1] - $Prices[0])
  $wave3 = [Math]::Abs($Prices[3] - $Prices[2])
  $wave5 = [Math]::Abs($Prices[5] - $Prices[4])
  $wave3NotShortest = $wave3 -ge [Math]::Min($wave1, $wave5)
  $bullDirections = ($Directions -join ",") -eq "-1,1,-1,1,-1,1"
  $bearDirections = ($Directions -join ",") -eq "1,-1,1,-1,1,-1"
  $bullRules = $bullDirections -and $Prices[2] -gt $Prices[0] -and $Prices[3] -gt $Prices[1] -and $Prices[4] -gt $Prices[1] -and $Prices[5] -gt $Prices[3] -and $wave3NotShortest
  $bearRules = $bearDirections -and $Prices[2] -lt $Prices[0] -and $Prices[3] -lt $Prices[1] -and $Prices[4] -lt $Prices[1] -and $Prices[5] -lt $Prices[3] -and $wave3NotShortest
  if ($bullRules) { return 1 }
  if ($bearRules) { return -1 }
  return 0
}

function Test-StrictCorrection {
  param([double[]]$Prices, [int[]]$Directions, [int]$ImpulseDirection)

  if ($Prices.Count -ne 4 -or $Directions.Count -ne 4) {
    throw "Correction fixture must contain wave 5 followed by A, B and C."
  }

  if ($ImpulseDirection -eq 1) {
    return ($Directions -join ",") -eq "1,-1,1,-1" -and $Prices[1] -lt $Prices[0] -and $Prices[2] -gt $Prices[1] -and $Prices[2] -lt $Prices[0] -and $Prices[3] -lt $Prices[1]
  }
  return ($Directions -join ",") -eq "-1,1,-1,1" -and $Prices[1] -gt $Prices[0] -and $Prices[2] -lt $Prices[1] -and $Prices[2] -gt $Prices[0] -and $Prices[3] -gt $Prices[1]
}

$cases = @(
  @{ Name = "Bull impulse"; Actual = Get-ImpulseDirection @(100, 110, 104, 122, 114, 128) @(-1, 1, -1, 1, -1, 1); Expected = 1 },
  @{ Name = "Bear impulse"; Actual = Get-ImpulseDirection @(128, 118, 124, 106, 114, 99) @(1, -1, 1, -1, 1, -1); Expected = -1 },
  @{ Name = "Reject wave 2 beyond origin"; Actual = Get-ImpulseDirection @(100, 110, 99, 122, 114, 128) @(-1, 1, -1, 1, -1, 1); Expected = 0 },
  @{ Name = "Reject wave 4 overlap"; Actual = Get-ImpulseDirection @(100, 110, 104, 122, 109, 128) @(-1, 1, -1, 1, -1, 1); Expected = 0 },
  @{ Name = "Reject shortest wave 3"; Actual = Get-ImpulseDirection @(100, 120, 110, 125, 121, 142) @(-1, 1, -1, 1, -1, 1); Expected = 0 },
  @{ Name = "Reject truncated wave 5"; Actual = Get-ImpulseDirection @(100, 110, 104, 122, 114, 121) @(-1, 1, -1, 1, -1, 1); Expected = 0 },
  @{ Name = "Accept bull strict zigzag"; Actual = Test-StrictCorrection @(128, 119, 124, 113) @(1, -1, 1, -1) 1; Expected = $true },
  @{ Name = "Reject B beyond wave 5"; Actual = Test-StrictCorrection @(128, 119, 129, 113) @(1, -1, 1, -1) 1; Expected = $false },
  @{ Name = "Accept bear strict zigzag"; Actual = Test-StrictCorrection @(99, 108, 103, 114) @(-1, 1, -1, 1) -1; Expected = $true },
  @{ Name = "Reject C inside A"; Actual = Test-StrictCorrection @(99, 108, 103, 107) @(-1, 1, -1, 1) -1; Expected = $false }
)

$failed = $false
foreach ($case in $cases) {
  if ($case.Actual -eq $case.Expected) {
    Write-Host "[PASS] $($case.Name)"
  } else {
    Write-Host "[FAIL] $($case.Name): expected $($case.Expected), got $($case.Actual)" -ForegroundColor Red
    $failed = $true
  }
}

if ($failed) { exit 1 }
Write-Host "Verified $($cases.Count) Elliott rule fixtures." -ForegroundColor Green
