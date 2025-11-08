param(
    [string]$Root = "C:\NECPGAME\.BRAIN"
)

$ErrorActionPreference = "Stop"
Set-Location $Root

Write-Host "=== NORMALIZING LEGACY API TASK STATUS SECTIONS ===" -ForegroundColor Cyan

$pattern = "(?s)---\s*\*\*API\s+Tasks\s+Status:\*\*\s*(?<block>.*?)\s*---"

$files = Get-ChildItem -Recurse -Filter *.md | ForEach-Object {
    $text = Get-Content $_.FullName -Raw -Encoding UTF8
    if ($text -match '\*\*API Tasks Status:\*\*') {
        [PSCustomObject]@{ Path = $_.FullName; Content = $text }
    }
}

if (-not $files) {
    Write-Host "No legacy sections found." -ForegroundColor Green
    exit 0
}

$fixed = 0
$unchanged = 0

foreach ($file in $files) {
    $original = $file.Content
    $converted = [regex]::Replace($original, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m)
        $block = $m.Groups['block'].Value
        $lines = ($block -split "`r?`n") | Where-Object { $_.Trim() -ne '' }
        $statusValue = ''
        $updatedValue = ''
        $tasksLines = @()
        $collectTasks = $false

        foreach ($line in $block -split "`r?`n") {
            $trim = $line.Trim()
            if ($trim -match '^-\s*Status:\s*(.+)$') {
                $statusValue = $matches[1]
                $collectTasks = $false
                continue
            }
            if ($trim -match '^-\s*Tasks:\s*$') {
                $collectTasks = $true
                continue
            }
            if ($trim -match '^-\s*Last\s+Updated:\s*(.+)$') {
                $updatedValue = $matches[1]
                $collectTasks = $false
                continue
            }
            if ($collectTasks -and $line -match '^\s+-\s*.+$') {
                $tasksLines += $line.TrimEnd()
            }
        }

        $nl = "`r`n"
        $builder = "---$nl$nl## API Tasks Status$nl$nl"
        if ([string]::IsNullOrWhiteSpace($statusValue)) {
            $statusValue = "created"
        }
        $builder += "- **Status:** $statusValue$nl"
        $builder += "- **Tasks:**"
        if ($tasksLines.Count -gt 0) {
            $builder += $nl + ($tasksLines -join $nl) + $nl
        } else {
            $builder += $nl
        }
        if ([string]::IsNullOrWhiteSpace($updatedValue)) {
            $updatedValue = (Get-Date -Format 'yyyy-MM-dd HH:mm')
        }
        $builder += "- **Last Updated:** $updatedValue$nl---"
        return $builder
    }, 1)

    if ($converted -ne $original) {
        Set-Content -Path $file.Path -Value $converted -Encoding UTF8 -NoNewline
        Write-Host "FIXED: $($file.Path)" -ForegroundColor Green
        $fixed++
    } else {
        $unchanged++
    }
}

Write-Host "`nFixed: $fixed" -ForegroundColor Green
Write-Host "Unchanged: $unchanged" -ForegroundColor Gray



