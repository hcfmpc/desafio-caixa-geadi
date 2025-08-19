# Script hibrido - API .NET local + Banco Docker
Write-Host "=== Start API .NET + DB Docker GEADI ===" -ForegroundColor Green

# Garantir que estamos na pasta raiz do projeto
Push-Location "$PSScriptRoot\.."

# ETAPA 1: Verificar Docker
Write-Host "ETAPA 1: Verificando Docker..." -ForegroundColor Yellow
$dockerVersion = docker --version 2>$null
if (-not $dockerVersion) {
    Write-Host "   ERRO: Docker não encontrado" -ForegroundColor Red
    Write-Host "   Instale: https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    Pop-Location
    exit 1
}
Write-Host "   OK: Docker encontrado" -ForegroundColor Green

# ETAPA 2: Verificar .NET (obrigatorio)
Write-Host "ETAPA 2: Verificando .NET..." -ForegroundColor Yellow
$dotnetVersion = dotnet --version 2>$null
if (-not $dotnetVersion) {
    Write-Host "   ERRO: .NET não encontrado" -ForegroundColor Red
    Write-Host "   Instale: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Cyan
    Pop-Location
    exit 1
}
Write-Host "   OK: .NET encontrado" -ForegroundColor Green

# ETAPA 3: Configurar ambiente
Write-Host "ETAPA 3: Configurando ambiente..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    Write-Host "   Criando .env..." -ForegroundColor Cyan
    .\Scripts\setup-env.ps1
} else {
    Write-Host "   OK: .env ja existe" -ForegroundColor Green
}

# Carregar funcoes utilitarias (após garantir que .env existe)
. "$PSScriptRoot\env-utils.ps1"

# Validar variaveis obrigatorias
if (-not (Test-RequiredEnvVars @("DB_USER", "DB_PASSWORD", "DB_NAME"))) {
    Pop-Location
    exit 1
}

# ETAPA 4: Parar containers e iniciar apenas SQL Server
Write-Host "ETAPA 4: Parando containers e iniciando SQL Server..." -ForegroundColor Yellow
docker-compose down > $null 2>&1
docker-compose up -d sqlserver

# ETAPA 5: Aguardar SQL Server ficar pronto
Write-Host "ETAPA 5: Aguardando SQL Server inicializar (max 60s)..." -ForegroundColor Yellow
$timeout = 60
$elapsed = 0
$ready = $false

while ($elapsed -lt $timeout -and -not $ready) {
    Start-Sleep 5
    $elapsed += 5
    
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = Get-ConnectionString -Server "localhost,1433" -Database "master" -Timeout 5
        $connection.Open()
        $connection.Close()
        $ready = $true
        Write-Host "   OK: SQL Server pronto em $elapsed segundos!" -ForegroundColor Green
    }
    catch {
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
}

if (-not $ready) {
    Write-Host "`nERRO: SQL Server não respondeu em 60s" -ForegroundColor Red
    Pop-Location
    exit 1
}

# ETAPA 6: Criar banco DBGEADI
Write-Host "`nETAPA 6: Criando banco DBGEADI..." -ForegroundColor Yellow
try {
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = Get-ConnectionString -Server "localhost,1433" -Database "master"
    $connection.Open()
    
    $command = $connection.CreateCommand()
    $command.CommandText = "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'DBGEADI') CREATE DATABASE DBGEADI"
    $command.ExecuteNonQuery() | Out-Null
    $connection.Close()
    Write-Host "   OK: Banco DBGEADI criado/verificado!" -ForegroundColor Green
}
catch {
    Write-Host "   ERRO: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
    exit 1
}

# ETAPA 7: Verificar EF Tools e aplicar migrations
Write-Host "`nETAPA 7: Aplicando migrations..." -ForegroundColor Yellow
# Verificar EF Tools
$efVersion = dotnet ef --version 2>$null
if (-not $efVersion) {
    Write-Host "   Instalando EF Tools..." -ForegroundColor Cyan
    dotnet tool install --global dotnet-ef > $null 2>&1
}

Push-Location "ControleArquivosGEADI.API"
try {
    dotnet ef database update > $null 2>&1
    Write-Host "   OK: Migrations aplicadas!" -ForegroundColor Green
}
catch {
    Write-Host "   AVISO: Erro nas migrations - continuando..." -ForegroundColor Yellow
}
Pop-Location

# ETAPA 8: Iniciar API local
Write-Host "`nETAPA 8: Iniciando API local..." -ForegroundColor Yellow
Write-Host "   Iniciando API em background..." -ForegroundColor Cyan

# Iniciar API em background
$apiJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Push-Location "ControleArquivosGEADI.API"
    dotnet run --urls "http://localhost:8080"
    Pop-Location
}

Write-Host "   OK: API iniciando (Job ID: $($apiJob.Id))" -ForegroundColor Green

# ETAPA 9: Testar API
Write-Host "`nETAPA 9: Testando API..." -ForegroundColor Yellow
$apiTimeout = 30
$apiElapsed = 0
$apiReady = $false

while ($apiElapsed -lt $apiTimeout -and -not $apiReady) {
    Start-Sleep 5
    $apiElapsed += 5
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/arquivos" -Method GET -TimeoutSec 5
        $apiReady = $true
        Write-Host "   OK: API respondendo em $apiElapsed segundos!" -ForegroundColor Green
    }
    catch {
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
}

if (-not $apiReady) {
    Write-Host "`n   AVISO: API ainda inicializando..." -ForegroundColor Yellow
}

# ETAPA 10: Abrir Swagger
Write-Host "`nETAPA 10: Abrindo Swagger..." -ForegroundColor Yellow
Start-Process "http://localhost:8080/swagger"

Write-Host "`n=======================================================" -ForegroundColor Green
Write-Host "APLICACAO HIBRIDA INICIALIZADA!" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "API (.NET local): http://localhost:8080" -ForegroundColor Cyan
Write-Host "Swagger: http://localhost:8080/swagger" -ForegroundColor Cyan
Write-Host "SQL Server (Docker): localhost:1433 ($(Get-EnvVar 'DB_USER')/***)" -ForegroundColor Cyan
Write-Host "`nPara parar API: Get-Job | Stop-Job" -ForegroundColor Yellow
Write-Host "Para parar DB: docker-compose down" -ForegroundColor Yellow
Write-Host "Para logs DB: docker-compose logs -f sqlserver" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Green

# Voltar para pasta original
Pop-Location
