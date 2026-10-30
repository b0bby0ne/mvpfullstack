param(
    [Parameter(Mandatory = $true)] [string]$Path,
    [Parameter(Mandatory = $true)] [string]$CommentPrefix
)

function Clean([string]$Value) {
    return ([System.Net.WebUtility]::HtmlDecode($Value) -replace '<[^>]+>', '').Trim()
}

function Number([string]$Value) {
    $normalized = (Clean $Value) -replace '\s', ''
    if ([string]::IsNullOrWhiteSpace($normalized)) { return 0.0 }
    return [double]::Parse($normalized, [System.Globalization.CultureInfo]::InvariantCulture)
}

$html = Get-Content -LiteralPath $Path -Raw
$marker = $html.IndexOf('<b>Deals</b>')
if ($marker -lt 0) { throw "Deals table not found: $Path" }

$active = $null
$rows = [regex]::Matches($html.Substring($marker), '<tr[^>]*>(.*?)</tr>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
foreach ($row in $rows) {
    $cells = [regex]::Matches($row.Groups[1].Value, '<td[^>]*>(.*?)</td>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($cells.Count -ne 13) { continue }
    $direction = Clean $cells[4].Groups[1].Value
    $comment = Clean $cells[12].Groups[1].Value
    if ($direction -eq 'in') {
        if ($comment.StartsWith($CommentPrefix, [System.StringComparison]::Ordinal)) {
            $entryTime = [datetime]::ParseExact((Clean $cells[0].Groups[1].Value), 'yyyy.MM.dd HH:mm:ss', [System.Globalization.CultureInfo]::InvariantCulture)
            $active = [pscustomobject]@{
                EntryTime = $entryTime
                Side = (Clean $cells[3].Groups[1].Value).ToUpperInvariant()
                Comment = $comment
                EntryCosts = (Number $cells[8].Groups[1].Value) + (Number $cells[9].Groups[1].Value) + (Number $cells[10].Groups[1].Value)
            }
        } else {
            $active = $null
        }
        continue
    }
    if ($direction -eq 'out' -and $null -ne $active) {
        $exitTime = [datetime]::ParseExact((Clean $cells[0].Groups[1].Value), 'yyyy.MM.dd HH:mm:ss', [System.Globalization.CultureInfo]::InvariantCulture)
        $profit = $active.EntryCosts + (Number $cells[8].Groups[1].Value) + (Number $cells[9].Groups[1].Value) + (Number $cells[10].Groups[1].Value)
        [pscustomobject]@{
            EntryTime = $active.EntryTime
            ExitTime = $exitTime
            Year = $active.EntryTime.Year
            Session = if ($active.EntryTime.Hour -lt 8) { '00-07' } elseif ($active.EntryTime.Hour -lt 16) { '08-15' } else { '16-23' }
            Side = $active.Side
            Comment = $active.Comment
            Profit = [math]::Round($profit, 2)
        }
        $active = $null
    }
}
