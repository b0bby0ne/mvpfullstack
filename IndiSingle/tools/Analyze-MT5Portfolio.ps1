param(
    [Parameter(Mandatory = $true)] [string]$Path,
    [switch]$IncludeTrades
)

function Clean([string]$Value) {
    return ([System.Net.WebUtility]::HtmlDecode($Value) -replace '<[^>]+>', '').Trim()
}

function Number([string]$Value) {
    $normalized = (Clean $Value) -replace '\s', ''
    if ([string]::IsNullOrWhiteSpace($normalized)) { return 0.0 }
    return [double]::Parse($normalized, [System.Globalization.CultureInfo]::InvariantCulture)
}

function Cells($Row) {
    return [regex]::Matches($Row.Groups[1].Value, '<td[^>]*>(.*?)</td>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
}

$html = Get-Content -LiteralPath $Path -Raw
$ordersMarker = $html.IndexOf('<b>Orders</b>')
$dealsMarker = $html.IndexOf('<b>Deals</b>')
if ($ordersMarker -lt 0 -or $dealsMarker -lt 0) { throw "Orders/deals tables not found: $Path" }

$orders = @{}
$orderRows = [regex]::Matches($html.Substring($ordersMarker, $dealsMarker - $ordersMarker), '<tr[^>]*>(.*?)</tr>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
foreach ($row in $orderRows) {
    $cells = Cells $row
    if ($cells.Count -ne 11) { continue }
    $orderId = Clean $cells[1].Groups[1].Value
    $comment = Clean $cells[10].Groups[1].Value
    if ($orderId -notmatch '^\d+$' -or $comment -notmatch '^BV') { continue }
    $orders[$orderId] = [pscustomobject]@{
        StopLoss = Number $cells[6].Groups[1].Value
        TakeProfit = Number $cells[7].Groups[1].Value
        Comment = $comment
    }
}

$active = [System.Collections.ArrayList]::new()
$closed = [System.Collections.ArrayList]::new()
$concurrent = 0
$peakConcurrent = 0
$overlapEntries = 0
$dealRows = [regex]::Matches($html.Substring($dealsMarker), '<tr[^>]*>(.*?)</tr>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
foreach ($row in $dealRows) {
    $cells = Cells $row
    if ($cells.Count -ne 13) { continue }
    $direction = Clean $cells[4].Groups[1].Value
    $orderId = Clean $cells[7].Groups[1].Value
    $comment = Clean $cells[12].Groups[1].Value
    if ($direction -eq 'in' -and $orders.ContainsKey($orderId)) {
        $time = [datetime]::ParseExact((Clean $cells[0].Groups[1].Value), 'yyyy.MM.dd HH:mm:ss', [System.Globalization.CultureInfo]::InvariantCulture)
        $type = (Clean $cells[3].Groups[1].Value).ToUpperInvariant()
        $volume = Number $cells[5].Groups[1].Value
        $meta = $orders[$orderId]
        $setup = if ($comment -match '^BVCTXM5_([^_]+)_') { $Matches[1] } elseif ($comment -match '^BVIX_([^_]+)_') { "INV-$($Matches[1])" } else { 'OTHER' }
        if ($concurrent -gt 0) { $overlapEntries++ }
        $concurrent++
        if ($concurrent -gt $peakConcurrent) { $peakConcurrent = $concurrent }
        [void]$active.Add([pscustomobject]@{
            EntryTime = $time
            Side = $type
            Volume = $volume
            Comment = $comment
            Setup = $setup
            StopLoss = $meta.StopLoss
            TakeProfit = $meta.TakeProfit
            EntryCosts = (Number $cells[8].Groups[1].Value) + (Number $cells[9].Groups[1].Value) + (Number $cells[10].Groups[1].Value)
            ConcurrentAtEntry = $concurrent
        })
        continue
    }
    if ($direction -ne 'out' -or $active.Count -eq 0) { continue }

    $exitType = (Clean $cells[3].Groups[1].Value).ToUpperInvariant()
    $exitVolume = Number $cells[5].Groups[1].Value
    $trigger = if ($comment -match '^(?:sl|tp)\s+([0-9.]+)') { [double]$Matches[1] } else { 0.0 }
    $candidates = @(0..($active.Count - 1) | Where-Object {
        $trade = $active[$_]
        $opposite = (($trade.Side -eq 'BUY' -and $exitType -eq 'SELL') -or ($trade.Side -eq 'SELL' -and $exitType -eq 'BUY'))
        $opposite -and [math]::Abs($trade.Volume - $exitVolume) -lt 0.000001
    })
    $matchIndex = -1
    if ($trigger -gt 0.0) {
        $matchedByLevel = @($candidates | Where-Object {
            $trade = $active[$_]
            [math]::Abs($trade.StopLoss - $trigger) -lt 0.0001 -or [math]::Abs($trade.TakeProfit - $trigger) -lt 0.0001
        })
        if ($matchedByLevel.Count -gt 0) { $matchIndex = $matchedByLevel[0] }
    }
    if ($matchIndex -lt 0 -and $candidates.Count -gt 0) { $matchIndex = $candidates[0] }
    if ($matchIndex -lt 0) { continue }

    $trade = $active[$matchIndex]
    $exitTime = [datetime]::ParseExact((Clean $cells[0].Groups[1].Value), 'yyyy.MM.dd HH:mm:ss', [System.Globalization.CultureInfo]::InvariantCulture)
    $profit = $trade.EntryCosts + (Number $cells[8].Groups[1].Value) + (Number $cells[9].Groups[1].Value) + (Number $cells[10].Groups[1].Value)
    [void]$closed.Add([pscustomobject]@{
        EntryTime = $trade.EntryTime
        ExitTime = $exitTime
        Side = $trade.Side
        Setup = $trade.Setup
        Comment = $trade.Comment
        Profit = [math]::Round($profit, 2)
        ConcurrentAtEntry = $trade.ConcurrentAtEntry
    })
    $active.RemoveAt($matchIndex)
    $concurrent--
}

$summary = [pscustomobject]@{
    Report = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    ClosedTrades = $closed.Count
    PeakConcurrent = $peakConcurrent
    OverlapEntries = $overlapEntries
    UnmatchedOpen = $active.Count
}
$summary

$closed | Group-Object Setup, Side | ForEach-Object {
    $items = @($_.Group)
    $wins = @($items | Where-Object Profit -gt 0).Count
    $grossProfit = ($items | Where-Object Profit -gt 0 | Measure-Object Profit -Sum).Sum
    $grossLoss = -1.0 * (($items | Where-Object Profit -lt 0 | Measure-Object Profit -Sum).Sum)
    if ($null -eq $grossProfit) { $grossProfit = 0.0 }
    if ($null -eq $grossLoss) { $grossLoss = 0.0 }
    [pscustomobject]@{
        Report = 'BRANCH'
        ClosedTrades = $items.Count
        PeakConcurrent = "$($items[0].Setup) $($items[0].Side)"
        OverlapEntries = [math]::Round(100.0 * $wins / $items.Count, 2)
        UnmatchedOpen = [math]::Round((($items | Measure-Object Profit -Sum).Sum), 2)
        ProfitFactor = if ($grossLoss -gt 0) { [math]::Round($grossProfit / $grossLoss, 2) } else { [double]::PositiveInfinity }
    }
}

if ($IncludeTrades) { $closed }
