param(
    [string]$StoryRoot = (Split-Path -Parent $PSScriptRoot),
    [ValidateRange(70, 100)]
    [int]$JpegQuality = 92
)

$ErrorActionPreference = 'Stop'

$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
if (-not (Test-Path -LiteralPath $chrome)) {
    throw "Chrome not found at $chrome"
}

$story = (Resolve-Path -LiteralPath $StoryRoot).Path
$visual = Join-Path $story 'Visual_Assets'
$publishRoot = Join-Path $story 'Social_Publish'
$imageRoot = Join-Path $publishRoot 'Images'
$tempRoot = Join-Path $publishRoot '.render-temp'
$profileRoot = Join-Path $publishRoot '.chrome-export-profile'

New-Item -ItemType Directory -Force -Path $imageRoot, $tempRoot, $profileRoot | Out-Null

$pages = @(
    @{ Page = 'P01'; Svg = 'LETTERED-P01_BatchA_v3.svg' },
    @{ Page = 'P02'; Svg = 'LETTERED-P02_BatchA_v2.svg' },
    @{ Page = 'P03'; Svg = 'LETTERED-P03_BatchA_v3.svg' },
    @{ Page = 'P04'; Svg = 'LETTERED-P04_BatchA_v2.svg' },
    @{ Page = 'P05'; Svg = 'LETTERED-P05_BatchA_v2.svg' },
    @{ Page = 'P06'; Svg = 'LETTERED-P06_BatchA_v2.svg' },
    @{ Page = 'P07'; Svg = 'LETTERED-P07_BatchB_v1.svg' },
    @{ Page = 'P08'; Svg = 'LETTERED-P08_BatchB_v1.svg' },
    @{ Page = 'P09'; Svg = 'LETTERED-P09_BatchB_v1.svg' },
    @{ Page = 'P10'; Svg = 'LETTERED-P10_BatchB_v1.svg' },
    @{ Page = 'P11'; Svg = 'LETTERED-P11_BatchB_v3.svg' },
    @{ Page = 'P12'; Svg = 'LETTERED-P12_BatchB_v2.svg' },
    @{ Page = 'P13'; Svg = 'LETTERED-P13_BatchC_v1.svg' },
    @{ Page = 'P14'; Svg = 'LETTERED-P14_BatchC_v2.svg' },
    @{ Page = 'P15'; Svg = 'LETTERED-P15_BatchC_v2.svg' },
    @{ Page = 'P16'; Svg = 'LETTERED-P16_BatchC_v1.svg' },
    @{ Page = 'P17'; Svg = 'LETTERED-P17_BatchC_v1.svg' },
    @{ Page = 'P18'; Svg = 'LETTERED-P18_BatchC_v1.svg' },
    @{ Page = 'P19'; Svg = 'LETTERED-P19_BatchD_v1.svg' },
    @{ Page = 'P20'; Svg = 'LETTERED-P20_BatchD_v1.svg' },
    @{ Page = 'P21'; Svg = 'LETTERED-P21_BatchD_v3.svg' },
    @{ Page = 'P22'; Svg = 'LETTERED-P22_BatchD_v3.svg' },
    @{ Page = 'P23'; Svg = 'LETTERED-P23_BatchD_v2.svg' },
    @{ Page = 'P24'; Svg = 'LETTERED-P24_BatchD_v2.svg' }
)

Add-Type -AssemblyName System.Drawing
$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object MimeType -eq 'image/jpeg' |
    Select-Object -First 1
$encoder = [System.Drawing.Imaging.Encoder]::Quality

$manifest = foreach ($item in $pages) {
    $svgPath = Join-Path $visual $item.Svg
    if (-not (Test-Path -LiteralPath $svgPath)) {
        throw "Missing source file: $svgPath"
    }

    $tempPng = Join-Path $tempRoot ("STORY-XTL-S01E01_{0}.png" -f $item.Page)
    $jpgName = "STORY-XTL-S01E01_{0}.jpg" -f $item.Page
    $jpgPath = Join-Path $imageRoot $jpgName
    $svgUri = 'file:///' + ((Resolve-Path -LiteralPath $svgPath).Path.Replace('\', '/'))

    $chromeArgs = @(
        '--headless=new'
        '--disable-gpu'
        '--no-sandbox'
        '--disable-dev-shm-usage'
        '--disable-crash-reporter'
        '--hide-scrollbars'
        "--user-data-dir=$profileRoot"
        '--window-size=1024,1536'
        "--screenshot=$tempPng"
        $svgUri
    )
    & $chrome @chromeArgs | Out-Null

    if (-not (Test-Path -LiteralPath $tempPng)) {
        throw "Chrome did not render $($item.Page)"
    }

    $bitmap = [System.Drawing.Bitmap]::FromFile($tempPng)
    try {
        if ($bitmap.Width -ne 1024 -or $bitmap.Height -ne 1536) {
            throw "Invalid dimensions for $($item.Page): $($bitmap.Width)x$($bitmap.Height)"
        }

        $parameters = [System.Drawing.Imaging.EncoderParameters]::new(1)
        try {
            $parameters.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new(
                $encoder,
                [long]$JpegQuality
            )
            $bitmap.Save($jpgPath, $jpegCodec, $parameters)
        }
        finally {
            $parameters.Dispose()
        }
    }
    finally {
        $bitmap.Dispose()
    }

    Remove-Item -LiteralPath $tempPng -Force
    $file = Get-Item -LiteralPath $jpgPath
    if ($file.Length -lt 100KB -or $file.Length -gt 8MB) {
        throw "Image size outside QA range for $($item.Page): $($file.Length) bytes"
    }

    $number = [int]$item.Page.Substring(1)
    [pscustomobject]@{
        Page = $item.Page
        FileName = $jpgName
        Width = 1024
        Height = 1536
        Bytes = $file.Length
        SHA256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $jpgPath).Hash
        FacebookOrder = $number
        ThreadsPart = if ($number -le 8) { 1 } elseif ($number -le 16) { 2 } else { 3 }
        ThreadsOrder = (($number - 1) % 8) + 1
    }
}

$manifestPath = Join-Path $publishRoot 'Social_Asset_Manifest.csv'
$manifest | Export-Csv -LiteralPath $manifestPath -NoTypeInformation -Encoding utf8

$resolvedPublish = (Resolve-Path -LiteralPath $publishRoot).Path
foreach ($cleanup in @($tempRoot, $profileRoot)) {
    $resolvedCleanup = (Resolve-Path -LiteralPath $cleanup).Path
    if (-not $resolvedCleanup.StartsWith($resolvedPublish, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing cleanup outside Social_Publish: $resolvedCleanup"
    }
    Remove-Item -LiteralPath $resolvedCleanup -Recurse -Force
}

Write-Output "Exported $($manifest.Count) images to $imageRoot"
Write-Output "Manifest: $manifestPath"
