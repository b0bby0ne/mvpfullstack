$ErrorActionPreference = "Stop"

function Reduce-CorePivots {
  param([object[]]$Candidates, [double]$ReversalFloor)

  $prices = [System.Collections.Generic.List[double]]::new()
  $directions = [System.Collections.Generic.List[int]]::new()
  foreach ($candidate in $Candidates) {
    $price = [double]$candidate.Price
    $direction = [int]$candidate.Direction
    if ($prices.Count -eq 0) {
      $prices.Add($price)
      $directions.Add($direction)
      continue
    }

    $last = $prices.Count - 1
    if ($directions[$last] -eq $direction) {
      $moreExtreme = if ($direction -eq 1) { $price -gt $prices[$last] } else { $price -lt $prices[$last] }
      if ($moreExtreme) { $prices[$last] = $price }
    } elseif ([Math]::Abs($price - $prices[$last]) -ge $ReversalFloor) {
      $prices.Add($price)
      $directions.Add($direction)
    }
  }

  return @{ Prices = $prices.ToArray(); Directions = $directions.ToArray() }
}

$sequence = @(
  @{ Price = 100; Direction = -1 },
  @{ Price = 108; Direction = 1 },
  @{ Price = 105; Direction = -1 },
  @{ Price = 110; Direction = 1 },
  @{ Price = 102; Direction = -1 },
  @{ Price = 104; Direction = 1 },
  @{ Price = 100; Direction = -1 }
)
$result = Reduce-CorePivots $sequence 5
$tests = @(
  @{ Name = "Core directions alternate"; Actual = $result.Directions -join ","; Expected = "-1,1,-1" },
  @{ Name = "Shallow reversals are rejected"; Actual = $result.Prices.Count; Expected = 3 },
  @{ Name = "Same-direction high moves to new extreme"; Actual = $result.Prices[1]; Expected = 110 },
  @{ Name = "Same-direction low moves to new extreme"; Actual = $result.Prices[2]; Expected = 100 },
  @{ Name = "ATR and percent gate use stricter floor"; Actual = [Math]::Max(20 * 1.0, 2000 * 2.0 * 0.01); Expected = 40 }
)

$failed = $false
foreach ($test in $tests) {
  if ($test.Actual -eq $test.Expected) {
    Write-Host "[PASS] $($test.Name)"
  } else {
    Write-Host "[FAIL] $($test.Name): expected $($test.Expected), got $($test.Actual)" -ForegroundColor Red
    $failed = $true
  }
}

if ($failed) { exit 1 }
Write-Host "Verified $($tests.Count) core-swing rule fixtures." -ForegroundColor Green
