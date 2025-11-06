$files = @(
    '05-technical\ai-systems\npc-personality-romance-ai.md',
    '02-gameplay\combat\combat-weapon-classes-detailed.md',
    '06-tasks\config\WORKFLOW-DETAILS.md',
    '02-gameplay\economy\economy-stock-exchange.md',
    '05-technical\ui-main-game.md',
    '02-gameplay\economy\economy-player-market.md',
    '02-gameplay\economy\economy-auction-house.md',
    '05-technical\global-state-system.md',
    '05-technical\ui-game-start.md',
    '02-gameplay\world\world-state-player-impact.md',
    '05-technical\api-specs\api-data-models.md',
    '05-technical\algorithms\romance-event-engine.md',
    '05-technical\ui-character-creation.md'
)

Write-Host "Checking restored original files:" -ForegroundColor Green
Write-Host ""

foreach ($file in $files) {
    if (Test-Path $file) {
        $lines = (Get-Content $file | Measure-Object -Line).Lines
        Write-Host "$lines lines - $file" -ForegroundColor Cyan
    } else {
        Write-Host "MISSING - $file" -ForegroundColor Red
    }
}

