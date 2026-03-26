param(
    [string]$RunName = "vn_tender_companies_batch_1_2026_03_25"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Fix-Text {
    param([string]$Text)

    if ([string]::IsNullOrEmpty($Text)) {
        return $Text
    }

    if ($Text -match "Ã|Æ|Ä|Å") {
        try {
            return [System.Text.Encoding]::UTF8.GetString(
                [System.Text.Encoding]::GetEncoding(28591).GetBytes($Text)
            )
        }
        catch {
            return $Text
        }
    }

    return $Text
}

function Get-AreaName {
    param(
        [string]$Code,
        [hashtable]$Cache
    )

    if ([string]::IsNullOrWhiteSpace($Code)) {
        return $null
    }

    if ($Cache.ContainsKey($Code)) {
        return $Cache[$Code]
    }

    $payload = @{
        queryParams = @{
            code = @{
                equals = $Code
            }
        }
    } | ConvertTo-Json -Depth 5

    try {
        $response = Invoke-RestMethod -Uri "https://muasamcong.mpi.gov.vn/o/egp-portal-contractors-approved/services/get-area-by-code" -Method Post -ContentType "application/json" -Body $payload
        if ($response -and $response.Count -gt 0) {
            $name = Fix-Text ([string]$response[0].name)
            $Cache[$Code] = $name
            return $name
        }
    }
    catch {
    }

    $Cache[$Code] = $Code
    return $Code
}

$runDir = Join-Path "d:\Researcher\SaleTeam\Output" $RunName
$leadJsonPath = Join-Path $runDir "_tmp_leads.json"
$outputJsonPath = Join-Path $runDir "_tmp_contact_data.json"

if (-not (Test-Path $leadJsonPath)) {
    throw "Missing input file: $leadJsonPath"
}

$leads = Get-Content -Raw $leadJsonPath | ConvertFrom-Json
$areaCache = @{}
$results = New-Object System.Collections.Generic.List[object]

foreach ($lead in $leads) {
    $payload = @{
        orgCode = [string]$lead.org_code
        roleName = "NT"
    } | ConvertTo-Json

    try {
        $detail = Invoke-RestMethod -Uri "https://muasamcong.mpi.gov.vn/o/egp-portal-contractors-approved/services/get-detail-approve-bidder" -Method Post -ContentType "application/json" -Body $payload
    }
    catch {
        $detail = $null
    }

    $province = if ($detail) { Get-AreaName -Code ([string]$detail.officePro) -Cache $areaCache } else { $null }
    $district = if ($detail) { Get-AreaName -Code ([string]$detail.officeDis) -Cache $areaCache } else { $null }
    $ward = if ($detail) { Get-AreaName -Code ([string]$detail.officeWar) -Cache $areaCache } else { $null }

    $results.Add([pscustomobject]@{
        record_id = [string]$lead.record_id
        org_code = [string]$lead.org_code
        profile_url = [string]$lead.profile_url
        company_name = if ($detail) { Fix-Text ([string]$detail.orgFullName) } else { $null }
        tax_code = if ($detail) { [string]$detail.taxCode } else { $null }
        office_phone = if ($detail) { Fix-Text ([string]$detail.officePhone) } else { $null }
        office_web = if ($detail) { Fix-Text ([string]$detail.officeWeb) } else { $null }
        office_add = if ($detail) { Fix-Text ([string]$detail.officeAdd) } else { $null }
        province = $province
        district = $district
        ward = $ward
        rep_name = if ($detail) { Fix-Text ([string]$detail.repName) } else { $null }
        rep_position = if ($detail) { Fix-Text ([string]$detail.repPosition) } else { $null }
        dec_no = if ($detail) { Fix-Text ([string]$detail.decNo) } else { $null }
    })

    Start-Sleep -Milliseconds 150
}

$json = $results | ConvertTo-Json -Depth 6
Set-Content -Path $outputJsonPath -Value $json -Encoding utf8

"OUTPUT_JSON=$outputJsonPath"
"COUNT=$($results.Count)"
