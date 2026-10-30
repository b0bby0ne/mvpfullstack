param(
    [Parameter(Mandatory = $true)]
    [string[]]$Path,

    [double]$StartingBalance = 10000.0,

    [switch]$IncludeRemoved
)

function Get-Metrics([object[]]$Trades, [double]$InitialBalance) {
    $ordered = @($Trades | Sort-Object ExitTime, EntryTime)
    $wins = @($ordered | Where-Object Profit -gt 0)
    $losses = @($ordered | Where-Object Profit -lt 0)
    $grossProfit = ($wins | Measure-Object Profit -Sum).Sum
    $grossLoss = -1.0 * (($losses | Measure-Object Profit -Sum).Sum
    )
    if ($null -eq $grossProfit) { $grossProfit = 0.0 }
    if ($null -eq $grossLoss) { $grossLoss = 0.0 }

    $balance = $InitialBalance
    $peak = $InitialBalance
    $maxDD = 0.0
    $maxDDPct = 0.0
    foreach ($trade in $ordered) {
        $balance += [double]$trade.Profit
        if ($balance -gt $peak) { $peak = $balance }
        $dd = $peak - $balance
        $ddPct = if ($peak -gt 0.0) { 100.0 * $dd / $peak } else { 0.0 }
        if ($dd -gt $maxDD) { $maxDD = $dd }
        if ($ddPct -gt $maxDDPct) { $maxDDPct = $ddPct }
    }

    $net = (($ordered | Measure-Object Profit -Sum).Sum)
    if ($null -eq $net) { $net = 0.0 }
    [pscustomobject]@{
        N = $ordered.Count
        WR = if ($ordered.Count) { 100.0 * $wins.Count / $ordered.Count } else { 0.0 }
        Net = $net
        PF = if ($grossLoss -gt 0.0) { $grossProfit / $grossLoss } else { [double]::PositiveInfinity }
        TradeDD = $maxDD
        TradeDDPct = $maxDDPct
        RF = if ($maxDD -gt 0.0) { $net / $maxDD } else { [double]::PositiveInfinity }
    }
}

function Apply-Cap(
    [object[]]$Trades,
    [int]$MaxBuy,
    [int]$MaxSell,
    [int]$MaxTotal
) {
    $accepted = [System.Collections.Generic.List[object]]::new()
    $removed = [System.Collections.Generic.List[object]]::new()
    $active = [System.Collections.Generic.List[object]]::new()

    foreach ($trade in @($Trades | Sort-Object EntryTime, ExitTime)) {
        for ($i = $active.Count - 1; $i -ge 0; $i--) {
            if ($active[$i].ExitTime -le $trade.EntryTime) {
                $active.RemoveAt($i)
            }
        }

        $sameSide = @($active | Where-Object Side -eq $trade.Side).Count
        $sideCap = if ($trade.Side -eq 'BUY') { $MaxBuy } else { $MaxSell }
        $blocked = ($sameSide -ge $sideCap) -or ($active.Count -ge $MaxTotal)
        if ($blocked) {
            $removed.Add($trade)
            continue
        }

        $accepted.Add($trade)
        $active.Add($trade)
    }

    [pscustomobject]@{
        Accepted = @($accepted)
        Removed = @($removed)
    }
}

$rules = @(
    [pscustomobject]@{ Rule='BASELINE'; MaxBuy=99; MaxSell=99; MaxTotal=99 },
    [pscustomobject]@{ Rule='SAME_SIDE_1'; MaxBuy=1; MaxSell=1; MaxTotal=99 },
    [pscustomobject]@{ Rule='SAME_SIDE_2'; MaxBuy=2; MaxSell=2; MaxTotal=99 },
    [pscustomobject]@{ Rule='BUY_1'; MaxBuy=1; MaxSell=99; MaxTotal=99 },
    [pscustomobject]@{ Rule='SELL_1'; MaxBuy=99; MaxSell=1; MaxTotal=99 },
    [pscustomobject]@{ Rule='BUY_1_SELL_2'; MaxBuy=1; MaxSell=2; MaxTotal=99 },
    [pscustomobject]@{ Rule='BUY_2_SELL_1'; MaxBuy=2; MaxSell=1; MaxTotal=99 },
    [pscustomobject]@{ Rule='TOTAL_2'; MaxBuy=99; MaxSell=99; MaxTotal=2 },
    [pscustomobject]@{ Rule='TOTAL_1'; MaxBuy=99; MaxSell=99; MaxTotal=1 }
)

foreach ($reportPath in $Path) {
    $parsed = @(& "$PSScriptRoot\Analyze-MT5Portfolio.ps1" -Path $reportPath -IncludeTrades)
    $trades = @($parsed | Where-Object { $_.PSObject.Properties.Name -contains 'EntryTime' })
    $baseline = Get-Metrics $trades $StartingBalance

    foreach ($rule in $rules) {
        $simulation = Apply-Cap $trades $rule.MaxBuy $rule.MaxSell $rule.MaxTotal
        $metrics = Get-Metrics $simulation.Accepted $StartingBalance
        [pscustomobject]@{
            Record = 'SUMMARY'
            Report = [System.IO.Path]::GetFileNameWithoutExtension($reportPath)
            Rule = $rule.Rule
            N = $metrics.N
            Removed = $trades.Count - $metrics.N
            WR = [math]::Round($metrics.WR, 2)
            Net = [math]::Round($metrics.Net, 2)
            DeltaNet = [math]::Round($metrics.Net - $baseline.Net, 2)
            PF = [math]::Round($metrics.PF, 2)
            RF = [math]::Round($metrics.RF, 2)
            TradeDD = [math]::Round($metrics.TradeDD, 2)
            TradeDDPct = [math]::Round($metrics.TradeDDPct, 2)
            Branch = ''
            BranchRemoved = 0
            BranchRemovedNet = 0.0
        }

        if ($IncludeRemoved -and $rule.Rule -ne 'BASELINE') {
            $simulation.Removed | Group-Object Setup, Side | ForEach-Object {
                $items = @($_.Group)
                [pscustomobject]@{
                    Record = 'REMOVED'
                    Report = [System.IO.Path]::GetFileNameWithoutExtension($reportPath)
                    Rule = $rule.Rule
                    N = 0
                    Removed = 0
                    WR = 0.0
                    Net = 0.0
                    DeltaNet = 0.0
                    PF = 0.0
                    RF = 0.0
                    TradeDD = 0.0
                    TradeDDPct = 0.0
                    Branch = "$($items[0].Setup) $($items[0].Side)"
                    BranchRemoved = $items.Count
                    BranchRemovedNet = [math]::Round((($items | Measure-Object Profit -Sum).Sum), 2)
                }
            }
        }
    }
}
