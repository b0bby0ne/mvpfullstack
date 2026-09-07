[CmdletBinding()]
param(
    [string] $SourceChart = 'C:\Users\your_user\AppData\Roaming\MetaQuotes\Terminal\your_terminal_id\MQL5\Profiles\Charts\Default\chart02.chr',
    [string] $SourceCCBSNChart = 'C:\Users\your_user\AppData\Roaming\MetaQuotes\Terminal\your_terminal_id\MQL5\Profiles\Charts\Default\chart01.chr'
)

$ErrorActionPreference = 'Stop'
$outputRoot = Join-Path $PSScriptRoot 'generated'
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
$chart = Get-Content -LiteralPath $SourceChart -Raw -Encoding Unicode

function New-ExpertBlock {
    param([ValidateSet('OFF', 'ON')] [string] $Mode)

    $policyInputs = if ($Mode -eq 'OFF') {
@'
InpM5PriceScale=0.50
InpEnableSession1=false
InpSession1=0000-2359
InpEnableSession2=false
InpSession2=0000-0001
InpEnableSession3=false
InpSession3=0000-0001
'@
    }
    else {
@'
InpM5PriceScale=3.0
InpMinATRPrice=0.01
InpUpsideMaxAboveEMAPrice=100.0
InpUpsideConfirmBars=1
InpDownsideMinATRPrice=0.01
InpDownsideBandBoundary=100.0
InpDownsideHoldMaxAboveEMA=100.0
InpDownsideConfirmBars=1
InpDownsideRequireDRising=false
InpDownsideRequireEMANonDown=false
InpEnableBearDrop=false
InpEnableConsecutiveRedBlock=false
InpEnableBearTwoBlock=false
InpEnableActiveLowATRBlock=false
InpEnableBearishPatternBlock=false
InpEnableDenyBlock=false
InpEnableReverseBlock=false
InpEnableFallBlock=false
InpEnableSession1=true
InpSession1=0000-2359
InpEnableSession2=false
InpSession2=0000-0001
InpEnableSession3=false
InpSession3=0000-0001
'@
    }

    return @"
<expert>
name=CCBSN_Controller_Lite_Ver3_M5
path=Experts\CCBSN_Controller_Lite_Ver3_M5.ex5
expertmode=1
<inputs>
$policyInputs
InpControlMode=1
InpCCBSNMagic=9696
InpControllerMagic=996970
InpForceSyncOnInit=true
InpShowDashboard=true
InpShowEventDashboard=true
InpWriteCsvAudit=true
InpEnableExternalMonitor=false
</inputs>
</expert>
"@
}

foreach ($mode in @('OFF', 'ON')) {
    $generated = [regex]::Replace(
        $chart,
        '(?s)<expert>.*?</expert>',
        (New-ExpertBlock -Mode $mode),
        1
    )
    $generated = $generated -replace '(?m)^period_size=15\r?$', 'period_size=5'
    $target = Join-Path $outputRoot "chart02-$($mode.ToLowerInvariant()).chr"
    Set-Content -LiteralPath $target -Value $generated -Encoding Unicode
    Write-Output $target
}

$ccbsnChart = Get-Content -LiteralPath $SourceCCBSNChart -Raw -Encoding Unicode
$guardedCCBSNChart = $ccbsnChart `
    -replace '(?m)^InpMaxBuyOrders=\d+\r?$', 'InpMaxBuyOrders=0' `
    -replace '(?m)^InpMaxSellOrders=\d+\r?$', 'InpMaxSellOrders=0'
if ($guardedCCBSNChart -notmatch '(?m)^InpMaxBuyOrders=0\r?$' -or
    $guardedCCBSNChart -notmatch '(?m)^InpMaxSellOrders=0\r?$') {
    throw 'Failed to apply the no-strategy-order guard to the CCBSN demo chart.'
}
$guardedChartPath = Join-Path $outputRoot 'chart01-ccbsn-no-new-orders.chr'
Set-Content -LiteralPath $guardedChartPath -Value $guardedCCBSNChart -Encoding Unicode
Write-Output $guardedChartPath
