param(
    [string]$RunName = "vn_tender_companies_batch_1_2026_03_25",
    [int]$TargetCount = 100
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Fix-Text {
    param([string]$Text)

    if ([string]::IsNullOrEmpty($Text)) {
        return $Text
    }

    return [System.Text.Encoding]::UTF8.GetString(
        [System.Text.Encoding]::GetEncoding(28591).GetBytes($Text)
    )
}

function Remove-Diacritics {
    param([string]$Text)

    if ([string]::IsNullOrEmpty($Text)) {
        return $Text
    }

    $normalized = $Text.Normalize([Text.NormalizationForm]::FormD)
    $builder = New-Object System.Text.StringBuilder

    foreach ($char in $normalized.ToCharArray()) {
        $category = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($char)
        if ($category -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$builder.Append($char)
        }
    }

    return $builder.ToString().Normalize([Text.NormalizationForm]::FormC)
}

$endpoint = "https://muasamcong.mpi.gov.vn/o/egp-portal-contractors-approved/services/get-list"
$sourcePage = "https://muasamcong.mpi.gov.vn/web/guest/approved-contractors-list"
$outputDir = Join-Path "d:\Researcher\SaleTeam\Output" $RunName

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$all = New-Object System.Collections.Generic.List[object]
$seen = @{}
$page = 0

while ($page -lt 20 -and $all.Count -lt $TargetCount) {
    $payload = @{
        pageSize = 20
        pageNumber = $page
        queryParams = @{
            officePro = @{
                contains = $null
            }
            effRoleDate = @{
                greaterThanOrEqual = $null
                lessThanOrEqual = $null
            }
            isForeignInvestor = @{
                equals = 0
            }
            roleType = @{
                in = @("NT")
            }
            decNo = @{
                contains = $null
            }
            orgName = @{
                contains = $null
            }
            taxCode = @{
                contains = $null
            }
            orgNameOrOrgCode = @{
                contains = $null
            }
            agencyName = @{
                in = $null
            }
        }
    } | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-RestMethod -Uri $endpoint -Method Post -ContentType "application/json" -Body $payload

        foreach ($item in $response.content) {
            $name = Fix-Text ([string]$item.orgFullname)
            $normalizedName = (Remove-Diacritics $name).ToUpperInvariant()
            $key = if ($item.taxCode) { [string]$item.taxCode } else { [string]$item.orgCode }

            if (
                -not $seen.ContainsKey($key) -and
                ($normalizedName.StartsWith("CONG TY") -or $normalizedName.StartsWith("DOANH NGHIEP"))
            ) {
                $seen[$key] = $true

                $all.Add([pscustomobject]@{
                    Name = $name
                    TaxCode = [string]$item.taxCode
                    OrgCode = [string]$item.orgCode
                    Address = Fix-Text ([string]$item.officeAdd)
                    EffDate = ("{0:00}/{1:00}/{2}" -f $item.effRoleDate[2], $item.effRoleDate[1], $item.effRoleDate[0])
                    Role = [string]$item.parentName
                })
            }
        }

        $page++
        Start-Sleep -Milliseconds 250
    }
    catch {
        Start-Sleep -Seconds 2
    }
}

$leads = $all | Select-Object -First $TargetCount

if ($leads.Count -lt $TargetCount) {
    throw "Could not collect enough enterprises. Current count: $($leads.Count)"
}

$briefLines = @(
    "# ICP_Input_Brief - $RunName",
    "",
    "## Muc tieu chon lead",
    "- Muc tieu kinh doanh: tao danh sach 100 doanh nghiep tu nguon dau thau Viet Nam de dung lam dau vao sales.",
    "- Loai account mong muon: doanh nghiep xuat hien tren nguon dau thau cong khai.",
    "",
    "## Doi tuong uu tien",
    "- Vai tro / chuc nang: Chua xac dinh",
    "- Buyer hay user: Chua xac dinh",
    "",
    "## Loai cong ty uu tien",
    "- Nganh: Tat ca",
    "- Mo hinh doanh nghiep: nha thau trong nuoc, phap nhan doanh nghiep",
    "- Quy mo: Chua xac dinh",
    "- Khu vuc: Viet Nam",
    "",
    "## Dau hieu uu tien",
    "- Tin hieu can co: xuat hien trong danh sach nha thau duoc phe duyet cong khai tren He thong mang dau thau quoc gia.",
    "- Tin hieu nen tranh: ca nhan, ho kinh doanh, don vi khong phai phap nhan doanh nghiep.",
    "",
    "## Ghi chu them",
    "- Dieu kien dac biet: giu nguyen ten phap nhan theo nguon chinh thuc; chua yeu cau enrich website, LinkedIn hay nguoi lien he o run nay."
)

Set-Content -Path (Join-Path $outputDir "ICP_Input_Brief.md") -Value $briefLines -Encoding utf8

$leadLines = New-Object System.Collections.Generic.List[string]
$leadLines.Add("# 01_Lead_List - $RunName")
$leadLines.Add("")
$leadLines.Add("## Boi canh")
$leadLines.Add("- Goi nguon: He thong mang dau thau quoc gia - danh sach nha thau duoc phe duyet")
$leadLines.Add("- ICP muc tieu: Doanh nghiep trong nuoc, moi nganh, xuat hien tren nguon dau thau Viet Nam")
$leadLines.Add("- Ngay thu thap: 2026-03-25")
$leadLines.Add("- Trang thai run: Hoan tat batch 1 voi 100 doanh nghiep")
$leadLines.Add("- Ghi chu nguon: Danh sach nay lay tu nguon dau thau chinh thuc va da loc bo cac ban ghi khong phai phap nhan doanh nghiep")
$leadLines.Add("")

$index = 1
foreach ($lead in $leads) {
    $recordId = "LEAD-VN-BID-{0:D3}" -f $index
    $detailUrl = "https://muasamcong.mpi.gov.vn/web/guest/approved-contractors-list?p_p_id=egpportalcontractorsapproved_WAR_egpportalcontractorsapproved&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&_egpportalcontractorsapproved_WAR_egpportalcontractorsapproved_render=detail&orgCode=$($lead.OrgCode)&effRoleDate=$([uri]::EscapeDataString($lead.EffDate))&role=$($lead.Role)"

    $leadLines.Add(("## Lead {0:D2}" -f $index))
    $leadLines.Add("- Ma ban ghi: $recordId")
    $leadLines.Add("- Batch / run nguon: $RunName")
    $leadLines.Add("- Ngay them vao run: 2026-03-25")
    $leadLines.Add("- Ngay cap nhat gan nhat: 2026-03-25")
    $leadLines.Add("- Nguon scan gan nhat: He thong mang dau thau quoc gia - Nha thau duoc phe duyet")
    $leadLines.Add("- Ten trong danh sach goc: $($lead.Name)")
    $leadLines.Add("- Loai lead: Cong ty")
    $leadLines.Add("- Ten nguoi: Chua co")
    $leadLines.Add("- Ten cong ty: $($lead.Name)")
    $leadLines.Add("- Vai tro / chuc nang: Chua co")
    $leadLines.Add("- Khu vuc: Viet Nam")
    $leadLines.Add("- Website cong ty: Chua co")
    $leadLines.Add("- LinkedIn / ho so: $detailUrl")
    $leadLines.Add("- Nguon: He thong mang dau thau quoc gia")
    $leadLines.Add("- Ly do dua vao: xuat hien trong danh sach nha thau duoc phe duyet cong khai; la phap nhan doanh nghiep trong nuoc.")
    $leadLines.Add("- Do phu hop ICP: Chua xac dinh")
    $leadLines.Add("- Trang thai xac minh: Da xac minh")
    $leadLines.Add("- Trang thai enrichment: Chua enrich")
    $leadLines.Add("- Ma trung da gop: Khong co")
    $leadLines.Add("- Chuyen Agent 2: Khong")
    $leadLines.Add("- Chuyen Agent 3: Khong")
    $leadLines.Add("- Ghi chu: Ma so thue $($lead.TaxCode); dia chi cong khai: $($lead.Address); ngay phe duyet: $($lead.EffDate).")
    $leadLines.Add("- Refs:")
    $leadLines.Add("  - Nguon danh sach: $sourcePage")
    $leadLines.Add("  - Ho so chi tiet: $detailUrl")
    $leadLines.Add("")

    $index++
}

Set-Content -Path (Join-Path $outputDir "01_Lead_List.md") -Value $leadLines -Encoding utf8

$masterLines = @(
    "# Master_Index - $RunName",
    "",
    "## Muc tieu run",
    "Thu thap 100 doanh nghiep tu nguon dau thau Viet Nam va luu thanh run chinh thuc trong SaleTeam/Output.",
    "",
    "## Trang thai run",
    "- Target ban dau: 100 doanh nghiep",
    "- Ket qua hien tai: 100 doanh nghiep",
    "- Thi truong: Viet Nam",
    "- Pham vi nganh: Tat ca cac nganh",
    "- Nguon chinh thuc: He thong mang dau thau quoc gia - danh sach nha thau duoc phe duyet",
    "- Ghi chu: day la danh sach doanh nghiep tu nguon dau thau cong khai; khong phai danh sach nguoi lien he hay ho so enrich sau.",
    "",
    "## File trong run",
    "1. [ICP_Input_Brief.md](./ICP_Input_Brief.md)",
    "2. [01_Lead_List.md](./01_Lead_List.md)",
    "",
    "## Ghi chu nguon",
    "- Trang nguon: $sourcePage",
    "- Cach lay: goi du lieu cong khai tu trang Nha thau duoc phe duyet tren cong chinh thuc.",
    "- Quy tac loc: chi giu ban ghi la phap nhan doanh nghiep trong nuoc; loai cac ban ghi ca nhan, ho kinh doanh va don vi khong phai doanh nghiep.",
    "",
    "## Ghi chu su dung",
    "- Run nay phu hop de lam dau vao cho cac buoc tiep theo cua Agent 1.",
    "- Vi chua co website va nguoi lien he, trang thai enrichment cua toan bo lead hien la Chua enrich."
)

Set-Content -Path (Join-Path $outputDir "Master_Index.md") -Value $masterLines -Encoding utf8

"RUN_DIR=$outputDir"
"COUNT=$($leads.Count)"
