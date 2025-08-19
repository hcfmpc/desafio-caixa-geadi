# Script de Configuração Automática do Ambiente
param()

Write-Host "=======================================================" -ForegroundColor Green
Write-Host "Configuracao Automatica do Ambiente" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green

# Detectar caminho atual do projeto
$projectRoot = Get-Location
Write-Host "Caminho detectado: $projectRoot" -ForegroundColor Cyan

# Verificar se estamos na raiz do projeto
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "AVISO: Execute este script na raiz do projeto!" -ForegroundColor Yellow
    exit 1
}

# Configurar caminho para Docker
$dockerPath = $projectRoot.ToString().Replace('\', '/')

# Criar arquivo .env
$envContent = "PROJECT_ROOT=$dockerPath`nDB_PASSWORD=Ge@di2024`nDB_USER=sa`nDB_NAME=DBGEADI"
$envContent | Out-File -FilePath ".env" -Encoding UTF8

Write-Host "Arquivo .env configurado!" -ForegroundColor Green
Write-Host "PROJECT_ROOT definido como: $dockerPath" -ForegroundColor Cyan

Write-Host "=======================================================" -ForegroundColor Green
Write-Host "CONFIGURACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
