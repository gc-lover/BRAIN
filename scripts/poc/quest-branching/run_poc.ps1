#Requires -Version 7.0
param(
    [string]$LiquibaseProperties = "liquibase.properties",
    [string]$Changelog = "scripts/migrations/quest-branching/master.xml",
    [string]$Tag = "quest-branching-v1",
    [switch]$RollbackOnly
)

function Invoke-Step([string]$Title, [scriptblock]$Action) {
    Write-Host "`n=== $Title ===" -ForegroundColor Cyan
    & $Action
    if ($LASTEXITCODE -ne 0) {
        throw "Step '$Title' failed with code $LASTEXITCODE"
    }
}

if (-not $RollbackOnly) {
    Invoke-Step "Liquibase Update" {
        liquibase --defaultsFile=$LiquibaseProperties --changelog-file=$Changelog update --tag=$Tag
    }

    Invoke-Step "Refresh MV quest_path_popularity" {
        psql -f "./scripts/poc/quest-branching/sql/refresh_mv.sql"
    }

    Invoke-Step "Insert Sample Data" {
        psql -f "./scripts/poc/quest-branching/sql/sample_data.sql"
    }

    Invoke-Step "Verify RLS" {
        psql -f "./scripts/poc/quest-branching/sql/check_rls.sql"
    }
}

Invoke-Step "Call quest_branching_rollback()" {
    psql -c "SELECT quest_branching_rollback();"
}

Invoke-Step "Liquibase Rollback" {
    liquibase --defaultsFile=$LiquibaseProperties --changelog-file=$Changelog rollbackOneTag $Tag
}

Write-Host "`nPoC cycle completed successfully." -ForegroundColor Green

