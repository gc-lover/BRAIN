# Скрипт автоматического коммита для агентов
# Использование: .\autocommit.ps1 [сообщение коммита]
# Кодировка: UTF-8

param(
    [string]$CommitMessage = ""
)

# Устанавливаем кодировку UTF-8 для PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Получаем текущую директорию репозитория
$RepoRoot = git rev-parse --show-toplevel 2>$null
if (-not $RepoRoot) {
    Write-Host "Ошибка: Не найден git репозиторий в текущей директории" -ForegroundColor Red
    exit 1
}

Set-Location $RepoRoot

# Проверяем, есть ли изменения для коммита
$Status = git status --porcelain
if (-not $Status) {
    Write-Host "Нет изменений для коммита" -ForegroundColor Yellow
    exit 0
}

# Добавляем все изменения
Write-Host "Добавление изменений..." -ForegroundColor Cyan
git add -A

# Генерируем сообщение коммита, если не указано явно
if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
    # Пытаемся сгенерировать осмысленное сообщение на основе измененных файлов
    $ChangedFiles = git diff --cached --name-only
    
    if ($ChangedFiles) {
        # Определяем тип изменений
        $Action = "Обновление"
        if ($ChangedFiles | Where-Object { $_ -match "\.md$" }) {
            $Action = "Документация"
        } elseif ($ChangedFiles | Where-Object { $_ -match "\.(yaml|yml)$" }) {
            $Action = "API спецификация"
        } elseif ($ChangedFiles | Where-Object { $_ -match "\.(go|java|js|ts|py)$" }) {
            $Action = "Реализация"
        } elseif ($ChangedFiles | Where-Object { $_ -match "rules\.mdc$" }) {
            $Action = "Обновление правил"
        }
        
        $FileCount = ($ChangedFiles | Measure-Object).Count
        $CommitMessage = "${Action}: изменения в файлах (${FileCount} файлов)"
    } else {
        $CommitMessage = "Автоматический коммит: обновления от агента"
    }
}

# Делаем коммит с правильным экранированием сообщения
Write-Host "Создание коммита: $CommitMessage" -ForegroundColor Cyan
$CommitResult = git commit -m "$CommitMessage" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Ошибка при создании коммита: $CommitResult" -ForegroundColor Red
    exit 1
}

Write-Host "Коммит создан успешно" -ForegroundColor Green

# Определяем текущую ветку
$CurrentBranch = git rev-parse --abbrev-ref HEAD 2>$null
if (-not $CurrentBranch) {
    Write-Host "Предупреждение: Не удалось определить текущую ветку, используем 'main'" -ForegroundColor Yellow
    $CurrentBranch = "main"
}

# Отправляем изменения
Write-Host "Отправка изменений в GitHub (ветка: $CurrentBranch)..." -ForegroundColor Cyan
$PushResult = git push origin "$CurrentBranch" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Предупреждение: Не удалось отправить изменения: $PushResult" -ForegroundColor Yellow
    Write-Host "Изменения закоммичены локально, но не отправлены" -ForegroundColor Yellow
} else {
    Write-Host "Изменения успешно отправлены в GitHub" -ForegroundColor Green
}

exit 0
