param(
    [string]$SourcePath = (Join-Path $PSScriptRoot '..\IndiSingle.mq5')
)

$source = Get-Content -LiteralPath $SourcePath -Raw
$findings = [System.Collections.Generic.List[object]]::new()

function Add-Finding {
    param(
        [string]$Severity,
        [string]$Check,
        [string]$Evidence
    )

    $findings.Add([PSCustomObject]@{
        Severity = $Severity
        Check    = $Check
        Evidence = $Evidence
    })
}

if ($source -match '#property\s+strict') {
    Add-Finding 'PASS' 'Strict compilation mode' '#property strict is present.'
} else {
    Add-Finding 'HIGH' 'Strict compilation mode' '#property strict is missing.'
}

if ($source -match 'if\(_Period\s*!=\s*PERIOD_M5\)') {
    Add-Finding 'PASS' 'Timeframe guard' 'EA rejects non-M5 charts.'
} else {
    Add-Finding 'HIGH' 'Timeframe guard' 'No explicit M5 guard found.'
}

$maxPositions = [regex]::Match($source, 'Inp_MaxPositions\s*=\s*(\d+)')
if ($maxPositions.Success -and [int]$maxPositions.Groups[1].Value -eq 1) {
    Add-Finding 'PASS' 'Single-position default' 'Inp_MaxPositions defaults to 1.'
} else {
    Add-Finding 'HIGH' 'Single-position default' "Inp_MaxPositions defaults to $($maxPositions.Groups[1].Value), not 1."
}

if ($source -match 'trade\.(Buy|Sell)\(' -and $source -notmatch 'ResultRetcode\(') {
    Add-Finding 'CRITICAL' 'Trade-server result validation' 'Buy/Sell calls exist but ResultRetcode() is never checked.'
}

if ($source -match 'ResultOrder\(' -and $source -match 'DEAL_POSITION_ID' -and $source -match 'PositionGetTicket\(') {
    Add-Finding 'CRITICAL' 'L2 position identity' 'L2 state mixes order ticket, position ticket, and position identifier.'
}

if ($source -match 'PositionClosePartial\(' -and $source -notmatch 'ACCOUNT_MARGIN_MODE') {
    Add-Finding 'CRITICAL' 'Netting/hedging compatibility' 'Partial close is used without checking account margin mode.'
}

if ($source -notmatch 'SYMBOL_TRADE_STOPS_LEVEL' -or $source -notmatch 'SYMBOL_TRADE_FREEZE_LEVEL') {
    Add-Finding 'HIGH' 'Broker stop/freeze constraints' 'SL/TP modification does not validate stop and freeze levels.'
}

if ($source -match 'NormalizeDouble\(lot,\s*2\)') {
    Add-Finding 'HIGH' 'Volume-step precision' 'Lot precision is hard-coded to 2 decimals.'
}

if ($source -notmatch 'SetTypeFillingBySymbol\(') {
    Add-Finding 'MEDIUM' 'Order filling policy' 'CTrade filling policy is not selected from symbol settings.'
}

foreach ($preset in @('L1_EMAPreset', 'L3_EMAPreset')) {
    $count = ([regex]::Matches($source, [regex]::Escape($preset))).Count
    if ($count -le 1) {
        Add-Finding 'MEDIUM' "$preset wiring" "$preset occurs only $count time(s), so the input is not consumed by logic."
    }
}

if ($source -match 'double\s+sesF\s*=\s*1\.0') {
    Add-Finding 'MEDIUM' 'L2 session score' 'Session factor is constant, so its configured weight adds no discrimination.'
}

if ($source -match 'TRADE_TRANSACTION_DEAL_ADD' -and $source -match 's_L2_trades\+\+') {
    Add-Finding 'MEDIUM' 'Trade statistics' 'Exit deals are counted as trades; partial exits can inflate trade and win counts.'
}

if ($source -notmatch 'BarsCalculated\(') {
    Add-Finding 'MEDIUM' 'Indicator readiness' 'No BarsCalculated() readiness check was found before CopyBuffer().' 
}

$rank = @{ CRITICAL = 0; HIGH = 1; MEDIUM = 2; LOW = 3; PASS = 4 }
$ordered = $findings | Sort-Object @{ Expression = { $rank[$_.Severity] } }, Check
$ordered | Format-Table Severity, Check, Evidence -Wrap -AutoSize

$counts = $findings | Group-Object Severity | Sort-Object Name
''
'Summary:'
$counts | ForEach-Object { '{0}: {1}' -f $_.Name, $_.Count }
