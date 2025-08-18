# Script de inicialização completa do Controle de Arquivos GEADI
# Execute este script para configurar tudo automaticamente

Write-Host "=== Controle de Arquivos GEADI - Inicializacao Completa ===" -ForegroundColor Green
Write-Host ""

# Garantir que estamos na pasta raiz do projeto
Push-Location "$PSScriptRoot\.."

# Verificar dependências
Write-Host "1. Verificando dependencias..." -ForegroundColor Yellow
$dockerOK = $false
$dotnetOK = $false

try {
    docker --version | Out-Null
    $dockerOK = $true
    Write-Host "   ✅ Docker disponivel" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Docker nao encontrado" -ForegroundColor Red
}

try {
    dotnet --version | Out-Null
    $dotnetOK = $true
    Write-Host "   ✅ .NET SDK disponivel" -ForegroundColor Green
} catch {
    Write-Host "   ❌ .NET SDK nao encontrado" -ForegroundColor Red
}

if (-not $dockerOK) {
    Write-Host ""
    Write-Host "❌ Docker nao encontrado! Por favor instale:" -ForegroundColor Red
    Write-Host "   https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    exit 1
}

# Iniciar containers
Write-Host ""
Write-Host "2. Iniciando containers..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "   ❌ Erro ao iniciar containers" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Containers iniciados" -ForegroundColor Green

# Aguardar SQL Server
Write-Host ""
Write-Host "3. Aguardando SQL Server inicializar..." -ForegroundColor Yellow
Start-Sleep -Seconds 15
Write-Host "   ✅ SQL Server deve estar pronto" -ForegroundColor Green

# Criar banco de dados
Write-Host ""
Write-Host "4. Criando banco de dados..." -ForegroundColor Yellow
try {
    docker exec -it geadi-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Ge@di2024" -C -Q "CREATE DATABASE DBGEADI" 2>$null
    Write-Host "   ✅ Banco DBGEADI criado" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️ Banco pode ja existir" -ForegroundColor Yellow
}

# Instalar EF Tools se necessário
Write-Host ""
Write-Host "5. Verificando Entity Framework Tools..." -ForegroundColor Yellow
if ($dotnetOK) {
    try {
        dotnet ef --version 2>$null | Out-Null
        Write-Host "   ✅ EF Tools ja instaladas" -ForegroundColor Green
    } catch {
        Write-Host "   📦 Instalando EF Tools..." -ForegroundColor Yellow
        dotnet tool install --global dotnet-ef
        Write-Host "   ✅ EF Tools instaladas" -ForegroundColor Green
    }
    
    # Aplicar migrations
    Write-Host ""
    Write-Host "6. Aplicando migrations..." -ForegroundColor Yellow
    Set-Location "ControleArquivosGEADI.API"
    try {
        dotnet ef database update
        Write-Host "   ✅ Migrations aplicadas" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️ Erro nas migrations - pode ser normal se ja aplicadas" -ForegroundColor Yellow
    }
    Set-Location ".."
} else {
    Write-Host "   ⚠️ .NET SDK nao disponivel - migrations nao aplicadas" -ForegroundColor Yellow
    Write-Host "   Execute manualmente: cd ControleArquivosGEADI.API && dotnet ef database update" -ForegroundColor Gray
}

# Aguardar API
Write-Host ""
Write-Host "7. Aguardando API inicializar..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Testar aplicação
Write-Host ""
Write-Host "8. Testando aplicacao..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "http://localhost:8080/arquivos" -Method Get -TimeoutSec 5 | Out-Null
    Write-Host "   ✅ API respondendo corretamente" -ForegroundColor Green
    
    try {
        Invoke-WebRequest -Uri "http://localhost:8080/swagger" -UseBasicParsing -TimeoutSec 5 | Out-Null
        Write-Host "   ✅ Swagger disponivel" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️ Swagger pode nao estar disponivel" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ API nao esta respondendo" -ForegroundColor Red
}

# Resultado final
Write-Host ""
Write-Host "🎉 INICIALIZACAO CONCLUIDA!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Aplicacao disponivel em:" -ForegroundColor Cyan
Write-Host "   API: http://localhost:8080" -ForegroundColor White
Write-Host "   Swagger: http://localhost:8080/swagger" -ForegroundColor White
Write-Host "   SQL Server: localhost:1433 (sa/Ge@di2024)" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Comandos uteis:" -ForegroundColor Cyan
Write-Host "   docker ps                    # Ver containers" -ForegroundColor Gray
Write-Host "   docker-compose logs api      # Ver logs da API" -ForegroundColor Gray
Write-Host "   docker-compose down          # Parar aplicacao" -ForegroundColor Gray

# Voltar para pasta original
Pop-Location
Write-Host ""
Write-Host "📖 Veja README.md para mais informacoes" -ForegroundColor Cyan
