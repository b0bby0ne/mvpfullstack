param(
    [Parameter(Mandatory = $true)] [string]$Path,
    [Parameter(Mandatory = $true)] [string]$Setup,
    [Parameter(Mandatory = $true)] [ValidateSet('BUY','SELL')] [string]$Direction,
    [int]$MinimumGroupSize = 2
)

function Number([object]$Value) {
    return [double]::Parse([string]$Value, [System.Globalization.CultureInfo]::InvariantCulture)
}

function Median([object[]]$Values) {
    $sorted = @($Values | ForEach-Object { Number $_ } | Sort-Object)
    if ($sorted.Count -eq 0) { return 0.0 }
    $middle = [math]::Floor($sorted.Count / 2)
    if (($sorted.Count % 2) -eq 1) { return $sorted[$middle] }
    return ($sorted[$middle - 1] + $sorted[$middle]) / 2.0
}

function Statistics([object[]]$Rows) {
    $profits = @($Rows | ForEach-Object { Number $_.net_profit })
    $wins = @($profits | Where-Object { $_ -gt 0 })
    $losses = @($profits | Where-Object { $_ -lt 0 })
    $grossProfit = ($wins | Measure-Object -Sum).Sum
    $grossLoss = -1.0 * (($losses | Measure-Object -Sum).Sum)
    if ($null -eq $grossProfit) { $grossProfit = 0.0 }
    if ($null -eq $grossLoss) { $grossLoss = 0.0 }

    return [pscustomobject]@{
        N = $Rows.Count
        Wins = $wins.Count
        WR = if ($Rows.Count) { [math]::Round(100.0 * $wins.Count / $Rows.Count, 2) } else { 0.0 }
        Net = [math]::Round((($profits | Measure-Object -Sum).Sum), 2)
        PF = if ($grossLoss -gt 0) { [math]::Round($grossProfit / $grossLoss, 2) } else { [double]::PositiveInfinity }
    }
}

$rows = @(Import-Csv -LiteralPath $Path -Delimiter ';' | Where-Object {
    $_.setup -eq $Setup -and $_.direction -eq $Direction
})

$wins = @($rows | Where-Object { (Number $_.net_profit) -gt 0 })
$losses = @($rows | Where-Object { (Number $_.net_profit) -lt 0 })

'SUMMARY'
Statistics $rows | Format-Table -AutoSize
[pscustomobject]@{
    WinnerMedianMFE = [math]::Round((Median $wins.mfe_r), 3)
    WinnerMedianMAE = [math]::Round((Median $wins.mae_r), 3)
    WinnerMAE_GE_075 = @($wins | Where-Object { (Number $_.mae_r) -ge 0.75 }).Count
    LoserMedianMFE = [math]::Round((Median $losses.mfe_r), 3)
    LoserMedianMAE = [math]::Round((Median $losses.mae_r), 3)
    LoserMFE_LT_025 = @($losses | Where-Object { (Number $_.mfe_r) -lt 0.25 }).Count
    LoserMFE_025_050 = @($losses | Where-Object { (Number $_.mfe_r) -ge 0.25 -and (Number $_.mfe_r) -lt 0.50 }).Count
    LoserMFE_050_100 = @($losses | Where-Object { (Number $_.mfe_r) -ge 0.50 -and (Number $_.mfe_r) -lt 1.00 }).Count
    LoserMFE_GE_100 = @($losses | Where-Object { (Number $_.mfe_r) -ge 1.00 }).Count
} | Format-List

$enriched = @($rows | ForEach-Object {
    $entry = [datetime]::ParseExact($_.entry_time, 'yyyy.MM.dd HH:mm:ss', [System.Globalization.CultureInfo]::InvariantCulture)
    $session = if ($entry.Hour -lt 8) { '00-07' } elseif ($entry.Hour -lt 16) { '08-15' } else { '16-23' }
    $_ | Add-Member -NotePropertyName year -NotePropertyValue $entry.Year -PassThru |
        Add-Member -NotePropertyName session -NotePropertyValue $session -PassThru
})

$fields = @('year','session','wyckoff_event','trend_24','trend_72','trend_240','transition_state',
            'volatility_state','activity_state','location_state','elliott_alignment','elliott_phase',
            'confluence_tier','m5_wait_bars')
foreach ($field in $fields) {
    "GROUP $field"
    @($enriched | Group-Object -Property $field | ForEach-Object {
        if ($_.Count -ge $MinimumGroupSize) {
            $stats = Statistics @($_.Group)
            [pscustomobject]@{ Value=$_.Name; N=$stats.N; WR=$stats.WR; Net=$stats.Net; PF=$stats.PF }
        }
    } | Sort-Object Value) | Format-Table -AutoSize
}
