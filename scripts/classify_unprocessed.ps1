param(
    [string]$ListPath = "06-tasks/active/CURRENT-WORK/unprocessed-list.txt"
)

$ErrorActionPreference = "Stop"
Set-Location "C:\NECPGAME\.BRAIN"

if (-not (Test-Path $ListPath)) {
    Write-Host "List file not found: $ListPath" -ForegroundColor Red
    exit 1
}

$servicePatterns = @(
    '^06-tasks/',
    '^ARCHITECTURE\.md$',
    '^README\.md$',
    '^МЕНЕДЖЕР',
    '^КЛИР',
    '^\.cursor/'
)

$list = Get-Content $ListPath | Where-Object { $_.Trim() -ne '' }

$service = @()
$candidate = @()

foreach ($item in $list) {
    $isService = $false
    foreach ($pattern in $servicePatterns) {
        if ($item -match $pattern) {
            $isService = $true
            break
        }
    }
    if ($isService) {
        $service += $item
    } else {
        $candidate += $item
    }
}

Write-Host "Total entries: $($list.Count)" -ForegroundColor Cyan
Write-Host "Service entries: $($service.Count)" -ForegroundColor Yellow
Write-Host "Feature candidates: $($candidate.Count)" -ForegroundColor Green

$outputDir = "06-tasks/active/CURRENT-WORK"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$serviceFile = Join-Path $outputDir "unprocessed-service.txt"
$featureFile = Join-Path $outputDir "unprocessed-feature.txt"

$service | Sort-Object | Out-File $serviceFile -Encoding UTF8
$candidate | Sort-Object | Out-File $featureFile -Encoding UTF8

Write-Host "Saved classification:" -ForegroundColor Cyan
Write-Host "  Service -> $serviceFile" -ForegroundColor Yellow
Write-Host "  Feature -> $featureFile" -ForegroundColor Green
