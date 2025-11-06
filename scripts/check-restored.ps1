Write-Host "=== ВОССТАНОВЛЕННЫЕ ОРИГИНАЛЬНЫЕ ФАЙЛЫ ===" -ForegroundColor Green
Write-Host ""

$files = @{
    '05-technical\ai-systems\npc-personality-romance-ai.md' = 948
    '02-gameplay\combat\combat-weapon-classes-detailed.md' = 619
    '06-tasks\config\WORKFLOW-DETAILS.md' = 719
    '02-gameplay\economy\economy-stock-exchange.md' = 622
    '05-technical\algorithms\romance-event-engine.md' = 1021
    '05-technical\ui-character-creation.md' = 988
    '04-narrative\quests\VISUAL-QUEST-MAP.md' = 507
    '04-narrative\quests\romantic\romance-events-system.md' = 536
    '04-narrative\quests\romantic\ROMANCE-EVENTS-INDEX-1000.md' = 574
    '05-technical\ROMANCE-SYSTEM-TECHNICAL-OVERVIEW.md' = 635
    '05-technical\api-structures\quests-json-schema.md' = 544
    '05-technical\mvp-initial-data.md' = 561
    '06-tasks\active\CURRENT-WORK\active\2025-11-07-BACKEND-COMPLETE-AUDIT.md' = 517
    '02-gameplay\combat\combat-abilities-catalog.md' = 709
    '02-gameplay\combat\combat-ai-enemies.md' = 704
    '04-narrative\npc-lore\npc-status-tracker.md' = 661
    '04-narrative\quests\side\side-quests-2020-2030-EXPANDED.md' = 701
    '04-narrative\sid-endings\periods\2090-2093-finale.md' = 662
    '05-technical\api-requirements\mvp-data-models.md' = 804
    '05-technical\content-generation\npc-profile-generator.md' = 790
    '05-technical\frontend-backend-integration.md' = 696
    '02-gameplay\economy\economy-crafting-recipes.md' = 571
    '02-gameplay\economy\equipment-matrix.md' = 557
    '02-gameplay\economy\stock-exchange\stock-corporations.md' = 533
}

$total = 0
$found = 0
$missing = 0

foreach ($file in $files.Keys) {
    $total++
    if (Test-Path $file) {
        $lines = (Get-Content $file | Measure-Object -Line).Lines
        $expected = $files[$file]
        $diff = $lines - $expected
        
        if ($diff -ge -50 -and $diff -le 50) {
            Write-Host "✅ $lines lines - $file" -ForegroundColor Green
            $found++
        } else {
            Write-Host "⚠️ $lines lines (expected ~$expected) - $file" -ForegroundColor Yellow
            $found++
        }
    } else {
        Write-Host "❌ MISSING - $file" -ForegroundColor Red
        $missing++
    }
}

Write-Host ""
Write-Host "=== ИТОГО ===" -ForegroundColor Cyan
Write-Host "Всего файлов: $total"
Write-Host "Найдено: $found" -ForegroundColor Green
Write-Host "Отсутствует: $missing" -ForegroundColor Red

