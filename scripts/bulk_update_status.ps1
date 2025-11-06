# Bulk update - add API Tasks Status to all processed docs
$ErrorActionPreference = "Stop"
Set-Location "C:\NECPGAME\.BRAIN"

$unprocessedFile = "06-tasks/active/CURRENT-WORK/unprocessed-list.txt"
$mappingFile = "C:\NECPGAME\API-SWAGGER\tasks\config\brain-mapping.yaml"

Write-Host "=== BULK UPDATE API TASKS STATUS ===" -ForegroundColor Cyan

if (-not (Test-Path $unprocessedFile)) {
    Write-Host "Error: unprocessed-list.txt not found!" -ForegroundColor Red
    exit 1
}

$files = Get-Content $unprocessedFile
Write-Host "Files to update: $($files.Count)" -ForegroundColor Yellow

# Read brain-mapping.yaml
$mapping = Get-Content $mappingFile -Raw

$updated = 0
$skipped = 0
$errors = 0

foreach ($file in $files) {
    $fullPath = $file.Replace("/", "\")
    
    # Skip service files
    if ($file -match "06-tasks/|BATCH-|VERIFICATION|REPORT|FINAL-|MASTER-|config/|archive/|ARCHITECTURE") {
        Write-Host "SKIP (service): $file" -ForegroundColor Gray
        $skipped++
        continue
    }
    
    if ($file -match "PROCEDURE|CHECKLIST|EXAMPLES") {
        Write-Host "SKIP (service): $file" -ForegroundColor Gray
        $skipped++
        continue
    }
    
    if (-not (Test-Path $fullPath)) {
        Write-Host "NOT EXISTS: $file" -ForegroundColor Red
        $skipped++
        continue
    }
    
    # Find task_id in brain-mapping
    $pattern = [regex]::Escape($file.Replace("\", "/"))
    if ($mapping -match "source:\s*`"\.BRAIN/$pattern`"[\s\S]{0,200}?task_id:\s*`"(API-TASK-\d+)`"") {
        $taskId = $matches[1]
        
        # Read file content
        $content = Get-Content $fullPath -Raw -Encoding UTF8
        
        # Check if already has status
        if ($content -match "##\s*API Tasks Status") {
            Write-Host "SKIP (has status): $file" -ForegroundColor Gray
            $skipped++
            continue
        }
        
        # Build status section
        $nl = "`r`n"
        $statusSection = $nl + "---" + $nl + $nl
        $statusSection += "## API Tasks Status" + $nl + $nl
        $statusSection += "- **Status:** created" + $nl
        $statusSection += "- **Tasks:**" + $nl
        $statusSection += "  - ${taskId}: (2025-11-07)" + $nl
        $statusSection += "- **Last Updated:** 2025-11-07 18:30" + $nl + $nl
        
        # Try to insert before "## История изменений" or at end
        if ($content -match "(---\s*##\s*История изменений)") {
            $content = $content -replace "(---\s*##\s*История изменений)", "$statusSection`$1"
        }
        elseif ($content -match "(\r?\n)$") {
            $content = $content.TrimEnd() + $statusSection + "`n"
        }
        else {
            $content = $content + $statusSection
        }
        
        # Write back
        Set-Content -Path $fullPath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "UPDATED: $file -> $taskId" -ForegroundColor Green
        $updated++
        
    } else {
        Write-Host "NOT IN MAPPING: $file" -ForegroundColor Yellow
        $errors++
    }
}

Write-Host "`n=== RESULTS ===" -ForegroundColor Cyan
Write-Host "Updated: $updated" -ForegroundColor Green
Write-Host "Skipped: $skipped" -ForegroundColor Gray
Write-Host "Not in mapping: $errors" -ForegroundColor Yellow

