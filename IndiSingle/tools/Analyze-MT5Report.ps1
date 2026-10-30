param(
    [Parameter(Mandatory = $true)]
    [string[]]$Path,

    [string]$CommentPrefix = "BVCTXM5_RB_BUY"
)

function Convert-MT5Number {
    param([string]$Text)

    $normalized = ([System.Net.WebUtility]::HtmlDecode($Text) -replace '<[^>]+>', '' -replace '\s', '')
    if ([string]::IsNullOrWhiteSpace($normalized)) { return 0.0 }
    return [double]::Parse($normalized, [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-MT5Metric {
    param(
        [string]$Html,
        [string]$Label
    )

    $pattern = [regex]::Escape("$Label</td>") + '\s*<td[^>]*><b>(.*?)</b>'
    $match = [regex]::Match($Html, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $match.Success) { return $null }
    return ([System.Net.WebUtility]::HtmlDecode($match.Groups[1].Value) -replace '<[^>]+>', '').Trim()
}

foreach ($reportPath in $Path) {
    $html = Get-Content -LiteralPath $reportPath -Raw
    $ordersMarker = $html.IndexOf('<b>Orders</b>')
    $dealsMarker = $html.IndexOf('<b>Deals</b>')
    if ($ordersMarker -lt 0 -or $dealsMarker -lt 0) { throw "Orders/deals table not found: $reportPath" }

    # Match each closing order to its own entry. The old implementation used
    # the immediately preceding deal, which is invalid when hedging positions
    # overlap and can assign another setup's PnL to the requested branch.
    $ordersHtml = $html.Substring($ordersMarker, $dealsMarker - $ordersMarker)
    $orderRows = [regex]::Matches($ordersHtml, '<tr[^>]*>(.*?)</tr>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $openOrders = [System.Collections.Generic.List[object]]::new()
    $closedTrades = [System.Collections.Generic.List[object]]::new()
    foreach ($rowMatch in $orderRows) {
        $cells = [regex]::Matches($rowMatch.Groups[1].Value, '<td[^>]*>(.*?)</td>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        if ($cells.Count -ne 11) { continue }
        $values = foreach ($cell in $cells) {
            ([System.Net.WebUtility]::HtmlDecode($cell.Groups[1].Value) -replace '<[^>]+>', '').Trim()
        }
        if ($values[9] -ne 'filled' -or $values[1] -notmatch '^\d+$' -or
            $values[4] -notmatch '^([0-9.]+)') { continue }
        $order = $values[1]
        $side = $values[3]
        $volume = [double]::Parse($Matches[1], [System.Globalization.CultureInfo]::InvariantCulture)
        $comment = $values[10]

        if ($comment -notmatch '^(sl|tp)\s+([0-9.]+)$') {
            $openOrders.Add([pscustomobject]@{
                Order = $order; Side = $side; Volume = $volume
                Stop = Convert-MT5Number $values[6]
                Target = Convert-MT5Number $values[7]
                Comment = $comment
            })
            continue
        }

        $reason = $Matches[1]
        $exitLevel = [double]::Parse($Matches[2], [System.Globalization.CultureInfo]::InvariantCulture)
        $wantedSide = if ($side -eq 'buy') { 'sell' } else { 'buy' }
        $matchIndex = -1
        for ($i = 0; $i -lt $openOrders.Count; $i++) {
            $open = $openOrders[$i]
            $expectedLevel = if ($reason -eq 'sl') { $open.Stop } else { $open.Target }
            if ($open.Side -eq $wantedSide -and [math]::Abs($open.Volume - $volume) -lt 0.000001 -and
                [math]::Abs($expectedLevel - $exitLevel) -lt 0.000001) {
                $matchIndex = $i
                break
            }
        }
        if ($matchIndex -lt 0) { continue }
        $entryOrder = $openOrders[$matchIndex]
        $openOrders.RemoveAt($matchIndex)
        $closedTrades.Add([pscustomobject]@{
            EntryOrder = $entryOrder.Order
            ExitOrder = $order
            Comment = $entryOrder.Comment
        })
    }

    $dealsHtml = $html.Substring($dealsMarker)
    $rowMatches = [regex]::Matches($dealsHtml, '<tr[^>]*>(.*?)</tr>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $orderResults = @{}
    $branchResults = [System.Collections.Generic.List[double]]::new()
    foreach ($rowMatch in $rowMatches) {
        $cellMatches = [regex]::Matches($rowMatch.Groups[1].Value, '<td[^>]*>(.*?)</td>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        if ($cellMatches.Count -ne 13) { continue }
        $order = ([System.Net.WebUtility]::HtmlDecode($cellMatches[7].Groups[1].Value) -replace '<[^>]+>', '').Trim()
        if ($order -notmatch '^\d+$') { continue }
        $result = (Convert-MT5Number $cellMatches[8].Groups[1].Value) +
                  (Convert-MT5Number $cellMatches[9].Groups[1].Value) +
                  (Convert-MT5Number $cellMatches[10].Groups[1].Value)
        if ($orderResults.ContainsKey($order)) { $orderResults[$order] += $result }
        else { $orderResults[$order] = $result }
    }
    foreach ($tradeRecord in $closedTrades) {
        if (-not $tradeRecord.Comment.StartsWith($CommentPrefix, [System.StringComparison]::Ordinal)) { continue }
        $result = 0.0
        if ($orderResults.ContainsKey($tradeRecord.EntryOrder)) { $result += $orderResults[$tradeRecord.EntryOrder] }
        if ($orderResults.ContainsKey($tradeRecord.ExitOrder)) { $result += $orderResults[$tradeRecord.ExitOrder] }
        $branchResults.Add($result)
    }

    $wins = @($branchResults | Where-Object { $_ -gt 0 }).Count
    $grossProfit = ($branchResults | Where-Object { $_ -gt 0 } | Measure-Object -Sum).Sum
    $grossLoss = -1.0 * (($branchResults | Where-Object { $_ -lt 0 } | Measure-Object -Sum).Sum)
    if ($null -eq $grossProfit) { $grossProfit = 0.0 }
    if ($null -eq $grossLoss) { $grossLoss = 0.0 }

    $cumulative = 0.0
    $peak = 0.0
    $maxDrawdown = 0.0
    foreach ($result in $branchResults) {
        $cumulative += $result
        if ($cumulative -gt $peak) { $peak = $cumulative }
        $drawdown = $peak - $cumulative
        if ($drawdown -gt $maxDrawdown) { $maxDrawdown = $drawdown }
    }

    $equityDdText = Get-MT5Metric $html 'Equity Drawdown Relative:'
    $equityDdPercent = if ($equityDdText -match '^([0-9.,]+)%') { $Matches[1] } else { $equityDdText }

    [pscustomobject]@{
        Report         = [System.IO.Path]::GetFileNameWithoutExtension($reportPath)
        NetProfit      = Get-MT5Metric $html 'Total Net Profit:'
        ProfitFactor   = Get-MT5Metric $html 'Profit Factor:'
        RecoveryFactor = Get-MT5Metric $html 'Recovery Factor:'
        EquityDDPct    = $equityDdPercent
        TotalTrades    = Get-MT5Metric $html 'Total Trades:'
        WinRatePct     = if ((Get-MT5Metric $html 'Profit Trades (% of total):') -match '\(([0-9.,]+)%\)') { $Matches[1] } else { $null }
        BranchTrades   = $branchResults.Count
        BranchWins     = $wins
        BranchWinPct   = if ($branchResults.Count -gt 0) { [math]::Round(100.0 * $wins / $branchResults.Count, 2) } else { 0.0 }
        BranchNet      = [math]::Round((($branchResults | Measure-Object -Sum).Sum), 2)
        BranchPF       = if ($grossLoss -gt 0) { [math]::Round($grossProfit / $grossLoss, 2) } else { [double]::PositiveInfinity }
        BranchTradeDD  = [math]::Round($maxDrawdown, 2)
    }
}
