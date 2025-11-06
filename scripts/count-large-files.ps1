# Скрипт для поиска .md файлов размером более 500 строк

$threshold = 500
$brainPath = Split-Path -Parent $PSScriptRoot

Write-Host "Scanning .BRAIN directory for .md files > $threshold lines..."
Write-Host ""

$results = @()

Get-ChildItem -Path $brainPath -Recurse -Filter "*.md" | ForEach-Object {
    $lineCount = (Get-Content $_.FullName | Measure-Object -Line).Lines
    
    if ($lineCount -gt $threshold) {
        $relativePath = $_.FullName.Replace($brainPath + "\", "")
        $results += [PSCustomObject]@{
            Lines = $lineCount
            Path = $relativePath
        }
    }
}

# Sort by line count descending
$results = $results | Sort-Object -Property Lines -Descending

# Output results
Write-Host "Found $($results.Count) files with more than $threshold lines:"
Write-Host ""

foreach ($result in $results) {
    Write-Host "$($result.Lines) lines: $($result.Path)"
}

