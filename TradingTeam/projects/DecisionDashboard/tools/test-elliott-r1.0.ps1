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

function Test-ImbalanceSupport {
  param([int[]]$States, [string]$Rule)

  $validCount = @($States | Where-Object { $_ -lt 2 }).Count
  $latestIsValid = $States[2] -lt 2
  $rulePasses = $Rule -eq "Latest motive IMB" -or ($Rule -eq "At least 2 motive IMBs" -and $validCount -ge 2) -or ($Rule -eq "All 3 motive IMBs" -and $validCount -eq 3)
  return $latestIsValid -and $rulePasses
}

function Get-ZoneState {
  param([int[]]$Ids, [int[]]$States, [int]$TargetId)

  $result = 2
  for ($index = 0; $index -lt $Ids.Count; $index++) {
    if ($Ids[$index] -eq $TargetId) { $result = $States[$index] }
  }
  return $result
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
  @{ Name = "Reject C inside A"; Actual = Test-StrictCorrection @(99, 108, 103, 107) @(-1, 1, -1, 1) -1; Expected = $false },
  @{ Name = "Latest IMB keeps impulse active"; Actual = Test-ImbalanceSupport @(2, 2, 0) "Latest motive IMB"; Expected = $true },
  @{ Name = "Filled latest IMB invalidates impulse"; Actual = Test-ImbalanceSupport @(0, 0, 2) "Latest motive IMB"; Expected = $false },
  @{ Name = "Two-IMB mode accepts two valid"; Actual = Test-ImbalanceSupport @(0, 2, 1) "At least 2 motive IMBs"; Expected = $true },
  @{ Name = "Two-IMB mode rejects one valid"; Actual = Test-ImbalanceSupport @(2, 2, 1) "At least 2 motive IMBs"; Expected = $false },
  @{ Name = "All-IMB mode requires three valid"; Actual = Test-ImbalanceSupport @(0, 1, 0) "All 3 motive IMBs"; Expected = $true },
  @{ Name = "All-IMB mode rejects a filled support"; Actual = Test-ImbalanceSupport @(0, 2, 0) "All 3 motive IMBs"; Expected = $false },
  @{ Name = "Stable zone ID resolves active"; Actual = Get-ZoneState @(11, 12, 13) @(2, 0, 1) 12; Expected = 0 },
  @{ Name = "Stable zone ID resolves touched"; Actual = Get-ZoneState @(11, 12, 13) @(2, 0, 1) 13; Expected = 1 },
  @{ Name = "Pruned zone ID fails closed"; Actual = Get-ZoneState @(11, 12, 13) @(2, 0, 1) 99; Expected = 2 }
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
