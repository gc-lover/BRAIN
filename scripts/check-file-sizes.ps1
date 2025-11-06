# Check all .md files > 500 lines
$files = Get-ChildItem -Path .BRAIN -Recurse -Filter '*.md' | Where-Object { $_.Length -gt 0 }

$largeFiles = @()

foreach ($file in $files) {
    $lines = (Get-Content $file.FullName | Measure-Object -Line).Lines
    if ($lines -gt 500) {
        $relativePath = $file.FullName.Replace($PWD.Path + '\', '')
        $largeFiles += [PSCustomObject]@{
            Lines = $lines
            Path = $relativePath
        }
    }
}

$largeFiles | Sort-Object -Property Lines -Descending | ForEach-Object {
    Write-Output "$($_.Lines) lines | $($_.Path)"
}

Write-Output ""
Write-Output "Total files > 500 lines: $($largeFiles.Count)"

