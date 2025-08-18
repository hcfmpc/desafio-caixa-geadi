# ===============================================================
# Script de Configuração Automática do Ambiente
# ===============================================================
# Este script detecta automaticamente o caminho do projeto e 
# configura o arquivo .env para uso com Docker
# ===============================================================

Write-Host "=======================================================" -ForegroundColor Green
Write-Host "🔧 CONFIGURAÇÃO AUTOMÁTICA DO AMBIENTE" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green

# Detectar caminho atual do projeto
$projectRoot = Get-Location
Write-Host "📁 Caminho detectado: $projectRoot" -ForegroundColor Cyan

# Verificar se estamos na raiz do projeto
$indicators = @("docker-compose.yml", "ControleArquivosGEADI.sln", "README.md")
$isProjectRoot = $true

foreach ($indicator in $indicators) {
    if (-not (Test-Path $indicator)) {
        $isProjectRoot = $false
        break
    }
}

if (-not $isProjectRoot) {
    Write-Host "⚠️  AVISO: Execute este script na raiz do projeto!" -ForegroundColor Yellow
    Write-Host "   Certifique-se de estar na pasta que contém docker-compose.yml" -ForegroundColor Yellow
    exit 1
}

# Configurar caminho para Docker (converter para formato compatível)
$dockerPath = $projectRoot.ToString().Replace('\', '/')

# Criar arquivo .env
$envContent = @"
# Configuração automática gerada em $(Get-Date)
# Caminho do projeto detectado automaticamente

PROJECT_ROOT=$dockerPath
DB_PASSWORD=Ge@di2024
DB_USER=sa
DB_NAME=DBGEADI
"@

# Salvar arquivo .env
$envContent | Out-File -FilePath ".env" -Encoding UTF8

Write-Host "✅ Arquivo .env configurado!" -ForegroundColor Green
Write-Host "📁 PROJECT_ROOT definido como: $dockerPath" -ForegroundColor Cyan

# Verificar se Docker está disponível
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-Host "🐳 Docker detectado: $dockerVersion" -ForegroundColor Green
        Write-Host "📋 Pronto para executar: docker-compose up -d" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  Docker não detectado. Instale o Docker Desktop para continuar." -ForegroundColor Yellow
}

Write-Host "=======================================================" -ForegroundColor Green
Write-Host "✅ CONFIGURAÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green

Write-Host "`n🚀 Próximos passos:" -ForegroundColor Cyan
Write-Host "1. docker-compose up -d" -ForegroundColor White
Write-Host "2. Aguardar inicialização (~30s)" -ForegroundColor White  
Write-Host "3. Acessar http://localhost:8080/swagger" -ForegroundColor White

Write-Host "`n📋 Para testar com pasta personalizada:" -ForegroundColor Cyan
Write-Host "POST /api/capturas/mapear-arquivos?pasta=database/massa-de-teste-db" -ForegroundColor White
