[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $TerminalPath,
    [Parameter(Mandatory)] [string] $DataRoot,
    [Parameter(Mandatory)] [string] $ExpectedAccount
)

$ErrorActionPreference = 'Stop'
$bundleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$supervisor = Join-Path $bundleRoot 'Start-CCBSNSupervised-Ver4_0_2.ps1'

& $supervisor `
    -TerminalPath $TerminalPath `
    -DataRoot $DataRoot `
    -ControllerBinary (Join-Path $bundleRoot 'CC_Controller_M5_Ver4_0.ex5') `
    -PreflightControllerChart (Join-Path $bundleRoot 'supervisor-preflight-off.chr') `
    -RuntimeControllerChart (Join-Path $bundleRoot 'real20-controller-ver4.chr') `
    -CCBSNChart (Join-Path $bundleRoot 'real20-ccbsn-v3.chr') `
    -ExpectedControllerSha256 'C33881E6738F80BC003ED2792E27C8807E58066F5C172AACA4F2212C3C017D65' `
    -ExpectedCCBSNSha256 'F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68' `
    -ExpectedAccount $ExpectedAccount `
    -EvidenceRoot (Join-Path $bundleRoot 'evidence') `
    -ControllerExpertFileName 'CC_Controller_M5_Ver4_0.ex5' `
    -ExpectedPolicyVersion '4.0.0-supervisor' `
    -PreflightTimeoutSeconds 120 `
    -RuntimeTimeoutSeconds 120 `
    -PostAckAuditSeconds 65 `
    -UpdateWarmupSeconds 70 `
    -TerminalQuiescenceSeconds 60 `
    -TerminalQuiescenceTimeoutSeconds 180
