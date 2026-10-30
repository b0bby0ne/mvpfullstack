param(
    [Parameter(Mandatory = $true)] [string]$OutputPath,
    [Parameter(Mandatory = $true)] [string]$SetName,
    [Parameter(Mandatory = $true)] [string]$ReportName,
    [Parameter(Mandatory = $true)] [string]$FromDate,
    [Parameter(Mandatory = $true)] [string]$ToDate,
    [ValidateSet(1, 4)] [int]$Model = 1
)

$lines = @(
    '[Tester]',
    'Expert=IndiSingle\IndiSingle_BobVolman_H1_M5',
    "ExpertParameters=$SetName",
    'Symbol=XAUUSDm',
    'Period=M5',
    "Model=$Model",
    'Optimization=0',
    "FromDate=$FromDate",
    "ToDate=$ToDate",
    'Deposit=10000',
    'Currency=USD',
    'Leverage=1:100',
    'UseLocal=1',
    'UseRemote=0',
    'UseCloud=0',
    'Visual=0',
    "Report=Reports\IndiSingle\$ReportName",
    'ReplaceReport=1',
    'ShutdownTerminal=1'
)

[System.IO.File]::WriteAllLines(
    [System.IO.Path]::GetFullPath($OutputPath),
    $lines,
    [System.Text.UTF8Encoding]::new($false)
)
