param(
    [Parameter(Mandatory = $true)] [string]$BaseSet,
    [Parameter(Mandatory = $true)] [string]$OutputSet,
    [Parameter(Mandatory = $true)] [hashtable]$Overrides
)

$lines = [System.Collections.Generic.List[string]]::new()
foreach ($line in (Get-Content -LiteralPath $BaseSet -Encoding UTF8)) {
    [void]$lines.Add($line)
}

foreach ($name in $Overrides.Keys) {
    $replacement = "$name=$($Overrides[$name])"
    $matched = $false
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -match ('^' + [regex]::Escape([string]$name) + '=')) {
            $lines[$index] = $replacement
            $matched = $true
            break
        }
    }
    if (-not $matched) {
        [void]$lines.Add($replacement)
    }
}

$duplicates = @($lines | Where-Object { $_ -match '^(Inp_[A-Za-z0-9_]+)=' } |
    ForEach-Object { [regex]::Match($_, '^(Inp_[A-Za-z0-9_]+)=').Groups[1].Value } |
    Group-Object | Where-Object Count -gt 1)
if ($duplicates.Count -gt 0) {
    throw "Duplicate input names: $($duplicates.Name -join ', ')"
}

[System.IO.File]::WriteAllLines(
    [System.IO.Path]::GetFullPath($OutputSet),
    $lines,
    [System.Text.UTF8Encoding]::new($false)
)
