# Auto commit script for agents
# Usage: .\autocommit.ps1 [commit message]

[CmdletBinding()]
param(
    [string]$CommitMessage = "Auto commit: agent update"
)

$RepoRoot = git rev-parse --show-toplevel 2>$null
if (-not $RepoRoot) {
    Write-Host "Error: Git repository not found" -ForegroundColor Red
    exit 1
}

Set-Location $RepoRoot

$Status = git status --porcelain
if (-not $Status) {
    Write-Host "No changes to commit" -ForegroundColor Yellow
    exit 0
}

Write-Host "Staging changes..." -ForegroundColor Cyan
git add -A

if ($CommitMessage -eq "Auto commit: agent update") {
    $ChangedFiles = git diff --cached --name-only

    if ($ChangedFiles) {
        $Action = "Update"
        if ($ChangedFiles | Where-Object { $_ -match "\.md$" }) {
            $Action = "Docs"
        } elseif ($ChangedFiles | Where-Object { $_ -match "\.(yaml|yml)$" }) {
            $Action = "API"
        } elseif ($ChangedFiles | Where-Object { $_ -match "\.(go|java|js|ts|py|tsx)$" }) {
            $Action = "Code"
        } elseif ($ChangedFiles | Where-Object { $_ -match "rules\.mdc$" }) {
            $Action = "Rules"
        }

        $FileCount = ($ChangedFiles | Measure-Object).Count
        $CommitMessage = "${Action}: ${FileCount} files"
    }
}

Write-Host "Creating commit: $CommitMessage" -ForegroundColor Cyan
$CommitResult = git commit -m $CommitMessage 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Commit failed: $CommitResult" -ForegroundColor Red
    exit 1
}

Write-Host "Commit created" -ForegroundColor Green

Write-Host "Pushing to origin/main..." -ForegroundColor Cyan
$PushResult = git push origin main 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Push failed: $PushResult" -ForegroundColor Yellow
    Write-Host "Changes committed locally" -ForegroundColor Yellow
} else {
    Write-Host "Push succeeded" -ForegroundColor Green
}

exit 0
