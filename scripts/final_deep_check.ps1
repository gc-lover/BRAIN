# Final Deep Check - Find all ready docs without status
$ErrorActionPreference = "Stop"
Set-Location "C:\NECPGAME\.BRAIN"

Write-Host "=== FINAL DEEP CHECK ===" -ForegroundColor Cyan

# Find all files with api-readiness: ready
$readyFiles = Get-ChildItem -Recurse -Filter "*.md" | 
    Where-Object { $_.FullName -notmatch "\\\.git\\" } |
    Select-String -Pattern "\*\*api-readiness:\*\* ready" -List |
    Select-Object -ExpandProperty Path |
    ForEach-Object { $_.Replace("C:\NECPGAME\.BRAIN\", "").Replace("\", "/") } |
    Sort-Object -Unique

Write-Host "`nTotal files with 'api-readiness: ready': $($readyFiles.Count)" -ForegroundColor Yellow

# Find files WITHOUT "API Tasks Status:"
$unprocessed = @()
foreach ($file in $readyFiles) {
    $fullPath = "C:\NECPGAME\.BRAIN\$($file.Replace('/', '\'))"
    $hasStatus = Select-String -Path $fullPath -Pattern "API Tasks Status:" -Quiet
    if (-not $hasStatus) {
        $unprocessed += $file
    }
}

Write-Host "Files WITHOUT 'API Tasks Status': $($unprocessed.Count)" -ForegroundColor $(if ($unprocessed.Count -eq 0) { "Green" } else { "Red" })

if ($unprocessed.Count -gt 0) {
    Write-Host "`nUNPROCESSED FILES:" -ForegroundColor Red
    $unprocessed | ForEach-Object { Write-Host "  - $_" }
} else {
    Write-Host "`n✅ ALL READY DOCUMENTS ARE PROCESSED!" -ForegroundColor Green
}

# Additional check - exclude service files
$servicePatterns = @(
    "06-tasks/active/CURRENT-WORK/",
    "06-tasks/config/",
    "09-reports/",
    "VERIFICATION",
    "REPORT",
    "STATUS",
    "BATCH-",
    "DUAPITASK",
    "FINAL-",
    "MASTER-",
    "READY.md",
    "COMPLETE.md"
)

$realFeatureDocs = $readyFiles | Where-Object {
    $path = $_
    $isService = $false
    foreach ($pattern in $servicePatterns) {
        if ($path -like "*$pattern*") {
            $isService = $true
            break
        }
    }
    -not $isService
}

Write-Host "`n=== FEATURE DOCUMENTS ONLY ===" -ForegroundColor Cyan
Write-Host "Real feature docs with 'ready': $($realFeatureDocs.Count)" -ForegroundColor Yellow

$unprocessedFeatures = @()
foreach ($file in $realFeatureDocs) {
    $fullPath = "C:\NECPGAME\.BRAIN\$($file.Replace('/', '\'))"
    $hasStatus = Select-String -Path $fullPath -Pattern "API Tasks Status:" -Quiet
    if (-not $hasStatus) {
        $unprocessedFeatures += $file
    }
}

Write-Host "Unprocessed feature docs: $($unprocessedFeatures.Count)" -ForegroundColor $(if ($unprocessedFeatures.Count -eq 0) { "Green" } else { "Red" })

if ($unprocessedFeatures.Count -gt 0) {
    Write-Host "`nUNPROCESSED FEATURE DOCS:" -ForegroundColor Red
    $unprocessedFeatures | ForEach-Object { Write-Host "  - $_" }
}

Write-Host "`n=== CHECK COMPLETE ===" -ForegroundColor Cyan

