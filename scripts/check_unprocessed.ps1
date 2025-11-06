# Check unprocessed files
$ErrorActionPreference = "Stop"
Set-Location "C:\NECPGAME\.BRAIN"

$unprocessedList = @(
    "04-narrative/quests/VISUAL-QUEST-MAP.md",
    "04-narrative/quests/visual-quest-map-part1.md",
    "04-narrative/quests/visual-quest-map-part2.md",
    "05-technical/api-requirements/mvp-endpoints/README.md",
    "05-technical/api-tech-docs/api-tech-summary-part1.md",
    "05-technical/api-tech-docs/api-tech-summary-part2.md",
    "05-technical/API-TECHNICAL-DOCUMENTATION-SUMMARY.md",
    "05-technical/backend/authentication-authorization/README.md"
)

Write-Host "=== CHECKING UNPROCESSED FILES ===" -ForegroundColor Cyan

foreach ($file in $unprocessedList) {
    $fullPath = $file.Replace("/", "\")
    
    if (-not (Test-Path $fullPath)) {
        Write-Host "NOT EXISTS: $file" -ForegroundColor Red
        continue
    }
    
    $content = Get-Content $fullPath -Raw
    
    # Check for "## API Tasks Status" (markdown header)
    if ($content -match "##\s*API Tasks Status") {
        Write-Host "HAS STATUS: $file" -ForegroundColor Green
    } else {
        Write-Host "NO STATUS: $file" -ForegroundColor Yellow
        
        # Check if it's a split part
        if ($file -match "part\d+\.md") {
            Write-Host "  -> SPLIT PART (processed via original)" -ForegroundColor Gray
        }
        # Check if it's a README
        elseif ($file -match "README\.md") {
            Write-Host "  -> README (navigation file)" -ForegroundColor Gray
        }
    }
}

Write-Host "`n=== CHECK COMPLETE ===" -ForegroundColor Cyan

