# Batch split large .md files

param(
    [int]$MaxLines = 500,
    [string]$TargetDir = ".BRAIN"
)

Write-Output "Scanning for files > $MaxLines lines..."

$files = Get-ChildItem -Path $TargetDir -Recurse -Filter '*.md' | Where-Object { 
    $_.Length -gt 0 -and 
    $_.Directory.Name -ne 'node_modules' -and
    $_.Directory.Name -ne '.git'
}

$toSplit = @()

foreach ($file in $files) {
    $lines = (Get-Content $file.FullName | Measure-Object -Line).Lines
    if ($lines -gt $MaxLines) {
        $relativePath = $file.FullName.Replace($PWD.Path + '\', '')
        $toSplit += [PSCustomObject]@{
            Lines = $lines
            Path = $relativePath
            FullPath = $file.FullName
            Directory = $file.Directory.FullName
            Name = $file.Name
        }
    }
}

Write-Output "`n=== Files to split ($($toSplit.Count)) ==="
$toSplit | Sort-Object -Property Lines -Descending | ForEach-Object {
    Write-Output "$($_.Lines) | $($_.Path)"
}

# Export list for processing
$toSplit | Sort-Object -Property Lines -Descending | Export-Csv -Path ".BRAIN/scripts/files-to-split.csv" -NoTypeInformation

Write-Output "`nList exported to: .BRAIN/scripts/files-to-split.csv"
Write-Output "Total files: $($toSplit.Count)"

