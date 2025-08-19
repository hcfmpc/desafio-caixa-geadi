# ===========================================================
# Start API .NET + DB Server - API local + Banco servidor
# ===========================================================
# Inicialização para servidor: API local, banco configurado
# ===========================================================

param()

Write-Host "=======================================================" -ForegroundColor Green
Write-Host "🎯 INICIALIZAÇÃO SERVIDOR - API .NET + DB SERVER" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green

# Garantir que estamos na pasta raiz do projeto
Push-Location "$PSScriptRoot\.."

# ETAPA 1: Verificar dependências
Write-Host "📋 ETAPA 1: Verificando dependências..." -ForegroundColor Yellow

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

# ETAPA 3: Verificar configuração de conexão
Write-Host "`n🔗 ETAPA 3: Verificando conexão com banco..." -ForegroundColor Yellow

# Ler string de conexão do appsettings
$appsettingsPath = "ControleArquivosGEADI.API/appsettings.json"
if (Test-Path $appsettingsPath) {
    $appsettings = Get-Content $appsettingsPath | ConvertFrom-Json
    $connectionString = $appsettings.ConnectionStrings.DefaultConnection
    
    if ($connectionString -and $connectionString -ne "Server=localhost,1433;Database=DBGEADI;User Id=sa;Password=Ge@di2024;TrustServerCertificate=True;") {
        Write-Host "   ✅ String de conexão customizada detectada" -ForegroundColor Green
        Write-Host "   📋 Servidor: $(($connectionString -split ';')[0] -replace 'Server=','')" -ForegroundColor Cyan
        
        # Testar conexão
        Write-Host "   🧪 Testando conectividade..." -ForegroundColor Cyan
        try {
            $connection = New-Object System.Data.SqlClient.SqlConnection
            $connection.ConnectionString = $connectionString
            $connection.Open()
            $connection.Close()
            Write-Host "   ✅ Conexão com banco bem-sucedida!" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ Erro de conexão: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "`n   💡 Verifique:" -ForegroundColor Yellow
            Write-Host "      • Servidor SQL disponível" -ForegroundColor Gray
            Write-Host "      • Credenciais corretas em appsettings.json" -ForegroundColor Gray
            Write-Host "      • Firewall/rede permitindo conexão" -ForegroundColor Gray
            Write-Host "      • Banco DBGEADI criado no servidor" -ForegroundColor Gray
            exit 1
        }
    } else {
        Write-Host "   ⚠️  String de conexão padrão (localhost) detectada" -ForegroundColor Yellow
        Write-Host "   📝 Para servidor, edite appsettings.json:" -ForegroundColor Cyan
        Write-Host '      "Server=SEU_SERVIDOR;Database=DBGEADI;User Id=SEU_USER;Password=SUA_SENHA;TrustServerCertificate=True;"' -ForegroundColor Gray
        
        $response = Read-Host "`n   🤔 Continuar mesmo assim? (s/n)"
        if ($response -ne "s" -and $response -ne "S") {
            Write-Host "   🛑 Execução cancelada pelo usuário" -ForegroundColor Red
            exit 0
        }
    }
} else {
    Write-Host "   ❌ appsettings.json não encontrado" -ForegroundColor Red
    exit 1
}

# ETAPA 4: Verificar e instalar EF Tools
Write-Host "`n🔧 ETAPA 4: Verificando EF Tools..." -ForegroundColor Yellow
try {
    dotnet ef --version > $null 2>&1
    Write-Host "   ✅ EF Tools já instalado" -ForegroundColor Green
} catch {
    Write-Host "   🔄 Instalando EF Tools..." -ForegroundColor Cyan
    dotnet tool install --global dotnet-ef > $null 2>&1
    Write-Host "   ✅ EF Tools instalado" -ForegroundColor Green
}

# ETAPA 5: Aplicar migrations
Write-Host "`n📊 ETAPA 5: Aplicando migrations..." -ForegroundColor Yellow
try {
    Push-Location "ControleArquivosGEADI.API"
    $migrationOutput = dotnet ef database update 2>&1
    Pop-Location
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Migrations aplicadas com sucesso" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Erro nas migrations:" -ForegroundColor Red
        Write-Host "   $migrationOutput" -ForegroundColor Gray
        Write-Host "`n   💡 Possíveis soluções:" -ForegroundColor Yellow
        Write-Host "      • Verificar se o banco DBGEADI existe" -ForegroundColor Gray
        Write-Host "      • Confirmar permissões do usuário no servidor" -ForegroundColor Gray
        Write-Host "      • Validar string de conexão" -ForegroundColor Gray
        exit 1
    }
} catch {
    Pop-Location
    Write-Host "   ❌ Erro nas migrations: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ETAPA 6: Iniciar API local
Write-Host "`n🚀 ETAPA 6: Iniciando API local..." -ForegroundColor Yellow
Write-Host "   🔄 Compilando e iniciando aplicação..." -ForegroundColor Cyan

# Iniciar API em background
$apiJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Push-Location "ControleArquivosGEADI.API"
    dotnet run --urls "http://localhost:8080"
    Pop-Location
}

Write-Host "   ✅ API iniciando em background (Job ID: $($apiJob.Id))" -ForegroundColor Green

# ETAPA 7: Aguardar API responder
Write-Host "`n🧪 ETAPA 7: Testando aplicação..." -ForegroundColor Yellow
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

# ETAPA 8: Validar conectividade banco via API
Write-Host "`n💾 ETAPA 8: Validando integração banco..." -ForegroundColor Yellow
try {
    $lotes = Invoke-RestMethod -Uri "http://localhost:8080/lotes" -Method GET -TimeoutSec 10
    Write-Host "   ✅ API conectada ao banco com sucesso!" -ForegroundColor Green
    Write-Host "   📊 Lotes encontrados: $($lotes.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "   ⚠️  Erro na consulta ao banco via API" -ForegroundColor Yellow
    Write-Host "   📋 Motivos possíveis: migrations pendentes, permissões, conectividade" -ForegroundColor Gray
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
Write-Host "🎯 APLICAÇÃO SERVIDOR INICIALIZADA!" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "🌐 API (.NET): http://localhost:8080" -ForegroundColor Cyan
Write-Host "📖 Swagger: http://localhost:8080/swagger" -ForegroundColor Cyan
Write-Host "🗄️ SQL Server: Configurado via appsettings.json" -ForegroundColor Cyan
Write-Host "🔧 Debug: API rodando local com hot reload" -ForegroundColor Cyan
Write-Host "`n💡 Para parar a API: Get-Job | Stop-Job" -ForegroundColor Yellow
Write-Host "🔧 Para editar conexão: appsettings.json" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Green
