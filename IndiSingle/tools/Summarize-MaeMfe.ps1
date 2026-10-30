param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'
$rows = @(Import-Csv -LiteralPath $Path -Delimiter ';')

if ($rows.Count -eq 0) {
    throw "MAE/MFE file has no trade rows: $Path"
}

$summary = foreach ($group in ($rows | Group-Object setup | Sort-Object Name)) {
    $trades = @($group.Group)
    $losses = @($trades | Where-Object { [double]$_.net_profit -lt 0 })
    $wins = $trades.Count - $losses.Count

    [pscustomobject]@{
        Setup                 = $group.Name
        Trades                = $trades.Count
        Wins                  = $wins
        Losses                = $losses.Count
        WinRatePct            = [math]::Round(100.0 * $wins / $trades.Count, 2)
        LossAvgMfeR           = if ($losses.Count) { [math]::Round((($losses | Measure-Object mfe_r -Average).Average), 2) } else { 0 }
        ImmediateFalseBreaks  = @($losses | Where-Object { [double]$_.mfe_r -lt 0.25 }).Count
        GaveBackFromHalfR     = @($losses | Where-Object { [double]$_.mfe_r -ge 0.50 }).Count
        PostExitReachedTarget = @($losses | Where-Object { [double]$_.post_best_r -ge [double]$_.target_rr }).Count
    }
}

$summary | Format-Table -AutoSize

