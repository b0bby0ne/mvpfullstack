param(
    [Parameter(Mandatory = $true)] [string]$Path
)

function Number([object]$Value) {
    return [double]::Parse([string]$Value, [System.Globalization.CultureInfo]::InvariantCulture)
}

function Metrics([object[]]$Rows) {
    $profits = @($Rows | ForEach-Object { Number $_.net_profit })
    $wins = @($profits | Where-Object { $_ -gt 0 })
    $losses = @($profits | Where-Object { $_ -lt 0 })
    $grossProfit = ($wins | Measure-Object -Sum).Sum
    $grossLoss = -1.0 * (($losses | Measure-Object -Sum).Sum)
    if ($null -eq $grossProfit) { $grossProfit = 0.0 }
    if ($null -eq $grossLoss) { $grossLoss = 0.0 }
    $equity = 0.0
    $peak = 0.0
    $drawdown = 0.0
    foreach ($profit in $profits) {
        $equity += $profit
        if ($equity -gt $peak) { $peak = $equity }
        if (($peak - $equity) -gt $drawdown) { $drawdown = $peak - $equity }
    }
    [pscustomobject]@{
        N = $Rows.Count
        WR = if ($Rows.Count) { [math]::Round(100.0 * $wins.Count / $Rows.Count, 2) } else { 0.0 }
        Net = [math]::Round((($profits | Measure-Object -Sum).Sum), 2)
        PF = if ($grossLoss -gt 0) { [math]::Round($grossProfit / $grossLoss, 2) } else { [double]::PositiveInfinity }
        TradeDD = [math]::Round($drawdown, 2)
    }
}

function ISOWeekKey([datetime]$Time) {
    $calendar = [System.Globalization.CultureInfo]::InvariantCulture.Calendar
    $week = $calendar.GetWeekOfYear($Time, [System.Globalization.CalendarWeekRule]::FirstFourDayWeek, [DayOfWeek]::Monday)
    return '{0:D4}-W{1:D2}' -f $Time.Year, $week
}

function Simulate([object[]]$Rows, [double]$DailyStopR, [double]$WeeklyStopR, [int]$DailyLossStreak) {
    $kept = [System.Collections.Generic.List[object]]::new()
    $dailyR = @{}
    $weeklyR = @{}
    $dailyStreak = @{}
    foreach ($row in $Rows) {
        $entry = [datetime]::ParseExact($row.entry_time, 'yyyy.MM.dd HH:mm:ss', [System.Globalization.CultureInfo]::InvariantCulture)
        $exit = [datetime]::ParseExact($row.exit_time, 'yyyy.MM.dd HH:mm:ss', [System.Globalization.CultureInfo]::InvariantCulture)
        $entryDay = $entry.ToString('yyyy-MM-dd')
        $entryWeek = ISOWeekKey $entry
        $blocked = ($DailyStopR -lt 0 -and $dailyR.ContainsKey($entryDay) -and $dailyR[$entryDay] -le $DailyStopR) -or
                   ($WeeklyStopR -lt 0 -and $weeklyR.ContainsKey($entryWeek) -and $weeklyR[$entryWeek] -le $WeeklyStopR) -or
                   ($DailyLossStreak -gt 0 -and $dailyStreak.ContainsKey($entryDay) -and $dailyStreak[$entryDay] -ge $DailyLossStreak)
        if ($blocked) { continue }

        $kept.Add($row)
        $exitDay = $exit.ToString('yyyy-MM-dd')
        $exitWeek = ISOWeekKey $exit
        $resultR = Number $row.exit_r
        if (-not $dailyR.ContainsKey($exitDay)) { $dailyR[$exitDay] = 0.0 }
        if (-not $weeklyR.ContainsKey($exitWeek)) { $weeklyR[$exitWeek] = 0.0 }
        if (-not $dailyStreak.ContainsKey($exitDay)) { $dailyStreak[$exitDay] = 0 }
        $dailyR[$exitDay] += $resultR
        $weeklyR[$exitWeek] += $resultR
        if ($resultR -lt 0) { $dailyStreak[$exitDay] += 1 } else { $dailyStreak[$exitDay] = 0 }
    }
    return @($kept)
}

$rows = @(Import-Csv -LiteralPath $Path -Delimiter ';' | Sort-Object {
    [datetime]::ParseExact($_.entry_time, 'yyyy.MM.dd HH:mm:ss', [System.Globalization.CultureInfo]::InvariantCulture)
})

$rules = @(
    @{ Name='BASELINE'; Daily=0.0; Weekly=0.0; Streak=0 },
    @{ Name='DAILY_-1R'; Daily=-1.0; Weekly=0.0; Streak=0 },
    @{ Name='DAILY_-2R'; Daily=-2.0; Weekly=0.0; Streak=0 },
    @{ Name='DAILY_2_LOSSES'; Daily=0.0; Weekly=0.0; Streak=2 },
    @{ Name='WEEKLY_-3R'; Daily=0.0; Weekly=-3.0; Streak=0 },
    @{ Name='WEEKLY_-4R'; Daily=0.0; Weekly=-4.0; Streak=0 },
    @{ Name='DAILY_-2R_WEEKLY_-4R'; Daily=-2.0; Weekly=-4.0; Streak=0 }
)

foreach ($rule in $rules) {
    $selected = if ($rule.Name -eq 'BASELINE') { $rows } else { Simulate $rows $rule.Daily $rule.Weekly $rule.Streak }
    $stats = Metrics $selected
    [pscustomobject]@{
        Rule = $rule.Name
        N = $stats.N
        Removed = $rows.Count - $stats.N
        WR = $stats.WR
        Net = $stats.Net
        PF = $stats.PF
        TradeDD = $stats.TradeDD
    }
}
