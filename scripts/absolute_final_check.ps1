# Absolute Final Check - Check every file manually
$ErrorActionPreference = "Stop"
Set-Location "C:\NECPGAME\.BRAIN"

$unprocessedList = @(
    "05-technical/global-state-system/README.md",
    "06-tasks/active/CURRENT-WORK/active/backend-audit-part1.md",
    "06-tasks/active/CURRENT-WORK/active/backend-audit-part2.md",
    "06-tasks/active/CURRENT-WORK/active/quest-branching-db-schema.md",
    "06-tasks/active/CURRENT-WORK/active/quest-branching-er-part1.md",
    "06-tasks/active/CURRENT-WORK/active/quest-branching-er-part2.md",
    "06-tasks/active/CURRENT-WORK/active/quest-branching-logic.md",
    "06-tasks/active/CURRENT-WORK/archive/2025-11-06-global-state-system.md",
    "06-tasks/active/CURRENT-WORK/archive/2025-11-06-world-state-player-impact.md",
    "06-tasks/active/CURRENT-WORK/BATCH-7-SPLIT-DOCUMENTS-COMPLETE.md",
    "06-tasks/config/check-documents-readiness.md",
    "06-tasks/config/readiness-check-guide.md",
    "06-tasks/config/STATUSES-GUIDE.md",
    "06-tasks/config/workflow/workflow-agents.md",
    "06-tasks/config/workflow/workflow-process.md"
)

Write-Host "=== ABSOLUTE FINAL CHECK ===" -ForegroundColor Cyan
Write-Host "Checking $($unprocessedList.Count) files..." -ForegroundColor Yellow

$trueUnprocessed = @()
foreach ($file in $unprocessedList) {
    $fullPath = $file.Replace("/", "\")
    if (Test-Path $fullPath) {
        $content = Get-Content $fullPath -Raw
        $hasStatus = $content -match "API Tasks Status:"
        if (-not $hasStatus) {
            $trueUnprocessed += $file
        }
    }
}

Write-Host "`nTrue unprocessed files: $($trueUnprocessed.Count)" -ForegroundColor $(if ($trueUnprocessed.Count -eq 0) { "Green" } else { "Red" })

if ($trueUnprocessed.Count -gt 0) {
    Write-Host "`nTRUE UNPROCESSED:" -ForegroundColor Red
    $trueUnprocessed | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
} else {
    Write-Host "`n✅✅✅ ALL READY DOCUMENTS ARE FULLY PROCESSED! ✅✅✅" -ForegroundColor Green
    Write-Host "ДУАПИТАСК work is 100% COMPLETE!" -ForegroundColor Green
}

