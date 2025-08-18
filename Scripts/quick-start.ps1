# Script otimizado para inicialização rápida
Write-Host "=== Inicializacao Rapida GEADI ===" -ForegroundColor Green

# Garantir que estamos na pasta raiz do projeto
Push-Location "$PSScriptRoot\.."

# Parar containers existentes
Write-Host "Parando containers existentes..." -ForegroundColor Yellow
docker-compose down > $null 2>&1

# Subir apenas SQL Server primeiro
Write-Host "Iniciando SQL Server..." -ForegroundColor Cyan
docker-compose up -d sqlserver

# Aguardar SQL Server ficar pronto (máximo 60 segundos)
Write-Host "Aguardando SQL Server inicializar (max 60s)..." -ForegroundColor Yellow
$timeout = 60
$elapsed = 0
$ready = $false

while ($elapsed -lt $timeout -and -not $ready) {
    Start-Sleep 5
    $elapsed += 5
    
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = "Server=localhost,1433;Database=master;User Id=sa;Password=Ge@di2024;TrustServerCertificate=True;Connect Timeout=5;"
        $connection.Open()
        $connection.Close()
        $ready = $true
        Write-Host "SQL Server pronto em $elapsed segundos!" -ForegroundColor Green
    }
    catch {
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
}

if (-not $ready) {
    Write-Host "`nTempo limite atingido. SQL Server pode não estar pronto." -ForegroundColor Red
    exit 1
}

# Criar banco se não existir
Write-Host "`nCriando banco DBGEADI..." -ForegroundColor Cyan
try {
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = "Server=localhost,1433;Database=master;User Id=sa;Password=Ge@di2024;TrustServerCertificate=True;"
    $connection.Open()
    
    $command = $connection.CreateCommand()
    $command.CommandText = "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'DBGEADI') CREATE DATABASE DBGEADI"
    $command.ExecuteNonQuery()
    $connection.Close()
    Write-Host "Banco DBGEADI criado/verificado!" -ForegroundColor Green
}
catch {
    Write-Host "Erro ao criar banco: $($_.Exception.Message)" -ForegroundColor Red
}

# Aplicar migrations
Write-Host "`nAplicando migrations..." -ForegroundColor Cyan
Push-Location "ControleArquivosGEADI.API"
try {
    dotnet ef database update --no-build > $null 2>&1
    Write-Host "Migrations aplicadas!" -ForegroundColor Green
}
catch {
    Write-Host "Erro nas migrations: $($_.Exception.Message)" -ForegroundColor Red
}
Pop-Location

# Subir API
Write-Host "`nIniciando API..." -ForegroundColor Cyan
docker-compose up -d api

Write-Host "`n================================" -ForegroundColor Green
Write-Host "INICIALIZACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "API: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Swagger: http://localhost:8080/swagger" -ForegroundColor Cyan
Write-Host "SQL Server: localhost:1433 (sa/Ge@di2024)" -ForegroundColor Cyan

Write-Host "`nPara importar dados de teste:" -ForegroundColor Yellow
Write-Host ".\Scripts\fast-load.ps1" -ForegroundColor White

# Voltar para pasta original
Pop-Location
