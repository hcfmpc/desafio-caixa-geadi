# ===============================================================
# Start API .NET + DB Docker - API local + Banco em container
# ===============================================================
# Inicialização híbrida: API rodando local, banco no Docker
# ===============================================================

param()

Write-Host "=======================================================" -ForegroundColor Green
Write-Host "🏗️ INICIALIZAÇÃO HÍBRIDA - API .NET + DB DOCKER" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green

# Garantir que estamos na pasta raiz do projeto
Push-Location "$PSScriptRoot\.."

# ETAPA 1: Verificar dependências
Write-Host "📋 ETAPA 1: Verificando dependências..." -ForegroundColor Yellow

$dockerOK = $false
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        $dockerOK = $true
        Write-Host "   ✅ Docker: $dockerVersion" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Docker não encontrado" -ForegroundColor Red
    Write-Host "   📥 Instale: https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    exit 1
}

$dotnetOK = $false
try {
    $dotnetVersion = dotnet --version 2>$null
    if ($dotnetVersion) {
        $dotnetOK = $true
        Write-Host "   ✅ .NET SDK: $dotnetVersion" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ .NET SDK não encontrado" -ForegroundColor Red
    Write-Host "   📥 Instale: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Cyan
    exit 1
}

# ETAPA 2: Configurar ambiente
Write-Host "`n🔧 ETAPA 2: Configurando ambiente..." -ForegroundColor Yellow

if (-not (Test-Path ".env")) {
    Write-Host "   🔄 Criando configuração .env..." -ForegroundColor Cyan
    .\Scripts\setup-env.ps1
} else {
    Write-Host "   ✅ Arquivo .env já configurado" -ForegroundColor Green
}

# ETAPA 3: Parar containers existentes e iniciar apenas SQL
Write-Host "`n🛑 ETAPA 3: Configurando banco Docker..." -ForegroundColor Yellow
docker-compose down > $null 2>&1
docker-compose up -d sqlserver

# Aguardar SQL Server ficar pronto
Write-Host "   ⏳ Aguardando SQL Server (max 60s)..." -ForegroundColor Cyan
$timeout = 60
$elapsed = 0
$ready = $false

while ($elapsed -lt $timeout -and -not $ready) {
    Start-Sleep 3
    $elapsed += 3
    
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = "Server=localhost,1433;Database=master;User Id=sa;Password=Ge@di2024;TrustServerCertificate=True;Connect Timeout=5;"
        $connection.Open()
        $connection.Close()
        $ready = $true
        Write-Host "   ✅ SQL Server pronto em $elapsed segundos!" -ForegroundColor Green
    }
    catch {
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
}

if (-not $ready) {
    Write-Host "`n   ❌ SQL Server não respondeu em 60s" -ForegroundColor Red
    exit 1
}

# ETAPA 4: Criar banco DBGEADI
Write-Host "`n💾 ETAPA 4: Verificando banco DBGEADI..." -ForegroundColor Yellow
try {
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = "Server=localhost,1433;Database=master;User Id=sa;Password=Ge@di2024;TrustServerCertificate=True;"
    $connection.Open()
    
    $command = $connection.CreateCommand()
    $command.CommandText = "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DBGEADI') CREATE DATABASE DBGEADI"
    $command.ExecuteNonQuery() | Out-Null
    $connection.Close()
    
    Write-Host "   ✅ Banco DBGEADI criado/verificado" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Erro ao criar banco: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ETAPA 5: Verificar e instalar EF Tools
Write-Host "`n🔧 ETAPA 5: Verificando EF Tools..." -ForegroundColor Yellow
try {
    dotnet ef --version > $null 2>&1
    Write-Host "   ✅ EF Tools já instalado" -ForegroundColor Green
} catch {
    Write-Host "   🔄 Instalando EF Tools..." -ForegroundColor Cyan
    dotnet tool install --global dotnet-ef > $null 2>&1
    Write-Host "   ✅ EF Tools instalado" -ForegroundColor Green
}

# ETAPA 6: Aplicar migrations
Write-Host "`n📊 ETAPA 6: Aplicando migrations..." -ForegroundColor Yellow
try {
    Push-Location "ControleArquivosGEADI.API"
    dotnet ef database update > $null 2>&1
    Pop-Location
    Write-Host "   ✅ Migrations aplicadas" -ForegroundColor Green
} catch {
    Pop-Location
    Write-Host "   ❌ Erro nas migrations: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ETAPA 7: Iniciar API local
Write-Host "`n🚀 ETAPA 7: Iniciando API local..." -ForegroundColor Yellow
Write-Host "   🔄 Compilando e iniciando aplicação..." -ForegroundColor Cyan

# Iniciar API em background
$apiJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Push-Location "ControleArquivosGEADI.API"
    dotnet run --urls "http://localhost:8080"
    Pop-Location
}

Write-Host "   ✅ API iniciando em background (Job ID: $($apiJob.Id))" -ForegroundColor Green

# ETAPA 8: Aguardar API responder
Write-Host "`n🧪 ETAPA 8: Testando aplicação..." -ForegroundColor Yellow
Write-Host "   ⏳ Aguardando API responder (max 30s)..." -ForegroundColor Cyan

$apiReady = $false
$apiTimeout = 30
$apiElapsed = 0

while ($apiElapsed -lt $apiTimeout -and -not $apiReady) {
    Start-Sleep 3
    $apiElapsed += 3
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/arquivos" -Method GET -TimeoutSec 5
        $apiReady = $true
        Write-Host "   ✅ API respondendo em $apiElapsed segundos!" -ForegroundColor Green
    }
    catch {
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
}

if (-not $apiReady) {
    Write-Host "`n   ⚠️  API ainda inicializando... aguarde alguns segundos" -ForegroundColor Yellow
}

# ETAPA 9: Abrir Swagger
Write-Host "`n📖 ETAPA 9: Abrindo documentação..." -ForegroundColor Yellow
try {
    Start-Process "http://localhost:8080/swagger"
    Write-Host "   ✅ Swagger aberto no navegador" -ForegroundColor Green
} catch {
    Write-Host "   📋 Acesse manualmente: http://localhost:8080/swagger" -ForegroundColor Cyan
}

Pop-Location

Write-Host "`n=======================================================" -ForegroundColor Green
Write-Host "🎉 APLICAÇÃO HÍBRIDA INICIALIZADA!" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "🌐 API (.NET): http://localhost:8080" -ForegroundColor Cyan
Write-Host "📖 Swagger: http://localhost:8080/swagger" -ForegroundColor Cyan
Write-Host "🗄️ SQL Server (Docker): localhost:1433" -ForegroundColor Cyan
Write-Host "🔧 Debug: API rodando local com hot reload" -ForegroundColor Cyan
Write-Host "`n💡 Para parar a API: Get-Job | Stop-Job" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Green
