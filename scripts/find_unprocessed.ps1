# Find all ready docs without API Tasks Status
$ErrorActionPreference = "Stop"
Set-Location "C:\NECPGAME\.BRAIN"

Write-Host "=== FINDING UNPROCESSED READY DOCUMENTS ===" -ForegroundColor Cyan

# Find all .md files with **api-readiness:** ready
$readyFiles = Get-ChildItem -Recurse -Filter "*.md" | 
    Where-Object { $_.FullName -notmatch "\\.git\\" } |
    Select-String -Pattern "\*\*api-readiness:\*\* ready" -List |
    Select-Object -ExpandProperty Path |
    ForEach-Object { $_.Replace("C:\NECPGAME\.BRAIN\", "").Replace("\", "/") } |
    Sort-Object -Unique

Write-Host "Total ready files: $($readyFiles.Count)" -ForegroundColor Yellow

# Check each file for "## API Tasks Status:"
$unprocessed = @()
foreach ($file in $readyFiles) {
    $fullPath = "C:\NECPGAME\.BRAIN\$($file.Replace('/', '\'))"
    $content = Get-Content $fullPath -Raw -ErrorAction SilentlyContinue
    
    if ($content -and ($content -notmatch "##\s*API Tasks Status")) {
        $unprocessed += $file
    }
}

Write-Host "Files WITHOUT 'API Tasks Status': $($unprocessed.Count)" -ForegroundColor $(if ($unprocessed.Count -eq 0) { "Green" } else { "Red" })

if ($unprocessed.Count -gt 0) {
    Write-Host "`nUNPROCESSED FILES:" -ForegroundColor Red
    $unprocessed | ForEach-Object { Write-Host "  $_" }
    
    # Save to file for processing
    $unprocessed | Out-File "06-tasks/active/CURRENT-WORK/unprocessed-list.txt" -Encoding UTF8
    Write-Host "`nSaved to: 06-tasks/active/CURRENT-WORK/unprocessed-list.txt" -ForegroundColor Cyan
} else {
    Write-Host "`nALL READY DOCUMENTS ARE PROCESSED!" -ForegroundColor Green
}

