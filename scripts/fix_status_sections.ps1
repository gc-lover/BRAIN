# Normalize API Tasks Status sections to heading-based format
$ErrorActionPreference = "Stop"
Set-Location "C:\NECPGAME\.BRAIN"

Write-Host "=== NORMALIZING API TASKS STATUS SECTIONS ===" -ForegroundColor Cyan

$pattern = '(?s)---\s*\*\*API\s+Tasks\s+Status:\*\*\s*-\s*Status:\s*(?<status>[^\r\n]+)\s*-\s*Tasks:\s*(?<tasks>(?:\s{2}-[^\r\n]+\s*)*)-\s*Last\s+Updated:\s*(?<updated>[^\r\n]+)\s*---'

$files = Get-ChildItem -Recurse -Filter *.md | ForEach-Object {
    $match = Select-String -Path $_.FullName -Pattern '**API Tasks Status:**' -SimpleMatch -List -Quiet
    if ($match) { $_.FullName }
}

if (-not $files) {
    Write-Host "No files with legacy API Tasks Status format found." -ForegroundColor Yellow
    exit 0
}

$fixed = 0
$failed = 0

foreach ($file in $files) {
    try {
        $content = Get-Content $file -Raw -Encoding UTF8
        if ($content -notmatch '\*\*API Tasks Status:\*\*') {
            continue
        }
        $newContent = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m)
            $statusLocal = $m.Groups['status'].Value.Trim()
            $tasksLocal = $m.Groups['tasks'].Value
            $updatedLocal = $m.Groups['updated'].Value.Trim()
            $tasksLinesLocal = ($tasksLocal -split "`r?`n") | Where-Object { $_.Trim() -ne '' }
            if ($tasksLinesLocal.Count -eq 0) {
                $tasksBlock = ""
            } else {
                $tasksBlock = ($tasksLinesLocal | ForEach-Object { $_.TrimEnd() }) -join "`r`n"
            }
            $builder = "---`r`n`r`n## API Tasks Status`r`n`r`n- **Status:** $statusLocal`r`n- **Tasks:**"
            if ($tasksBlock -ne "") {
                $builder += "`r`n$tasksBlock"
            }
            $builder += "`r`n- **Last Updated:** $updatedLocal`r`n---"
            return $builder
        }, 1)
        if ($newContent -ne $content) {
            Set-Content -Path $file -Value $newContent -Encoding UTF8
            Write-Host "FIXED: $file" -ForegroundColor Green
            $fixed++
        }
    }
    catch {
        Write-Host "FAILED: $file -> $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`nFixed: $fixed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Red
