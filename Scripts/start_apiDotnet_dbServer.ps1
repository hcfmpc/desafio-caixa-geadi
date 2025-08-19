# Script servidor - API .NET local + Banco servidor
Write-Host "=== Start API .NET + DB Server GEADI ===" -ForegroundColor Green

# Garantir que estamos na pasta raiz do projeto
Push-Location "$PSScriptRoot\.."

# ETAPA 1: Verificar .NET (obrigatorio)
Write-Host "ETAPA 1: Verificando .NET..." -ForegroundColor Yellow
$dotnetVersion = dotnet --version 2>$null
if (-not $dotnetVersion) {
    Write-Host "   ERRO: .NET não encontrado" -ForegroundColor Red
    Write-Host "   Instale: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Cyan
    Pop-Location
    exit 1
}
Write-Host "   OK: .NET encontrado" -ForegroundColor Green

# ETAPA 2: Configurar ambiente
Write-Host "ETAPA 2: Configurando ambiente..." -ForegroundColor Yellow
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

# ETAPA 3: Verificar configuracao de conexao
Write-Host "ETAPA 3: Verificando conexao com banco..." -ForegroundColor Yellow

# Ler string de conexao do appsettings
$appsettingsPath = "ControleArquivosGEADI.API/appsettings.json"
if (Test-Path $appsettingsPath) {
    $appsettings = Get-Content $appsettingsPath | ConvertFrom-Json
    $connectionString = $appsettings.ConnectionStrings.DefaultConnection
    
    # Montar string de conexao padrao para comparacao
    $defaultUser = Get-EnvVar "DB_USER" "sa"
    $defaultPassword = Get-EnvVar "DB_PASSWORD" "Ge@di2024"
    $defaultDatabase = Get-EnvVar "DB_NAME" "DBGEADI"
    $defaultConnectionString = "Server=localhost,1433;Database=$defaultDatabase;User Id=$defaultUser;Password=$defaultPassword;TrustServerCertificate=True;"
    
    if ($connectionString -and $connectionString -ne $defaultConnectionString) {
        Write-Host "   OK: String de conexao customizada detectada" -ForegroundColor Green
        $serverInfo = ($connectionString -split ';')[0] -replace 'Server=',''
        Write-Host "   Servidor: $serverInfo" -ForegroundColor Cyan
        
        # Testar conexao
        Write-Host "   Testando conectividade..." -ForegroundColor Cyan
        try {
            $connection = New-Object System.Data.SqlClient.SqlConnection
            $connection.ConnectionString = $connectionString
            $connection.Open()
            $connection.Close()
            Write-Host "   OK: Conexao com banco bem-sucedida!" -ForegroundColor Green
        } catch {
            Write-Host "   ERRO: Conexao falhou: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "`n   Verifique:" -ForegroundColor Yellow
            Write-Host "      • Servidor SQL disponivel" -ForegroundColor Gray
            Write-Host "      • Credenciais corretas em appsettings.json" -ForegroundColor Gray
            Write-Host "      • Firewall/rede permitindo conexao" -ForegroundColor Gray
            Write-Host "      • Banco DBGEADI criado no servidor" -ForegroundColor Gray
            Pop-Location
            exit 1
        }
    } else {
        Write-Host "   AVISO: String de conexao padrao (localhost) detectada" -ForegroundColor Yellow
        Write-Host "   Para servidor, edite appsettings.json com:" -ForegroundColor Cyan
        Write-Host '   "Server=SEU_SERVIDOR;Database=DBGEADI;User Id=SEU_USER;Password=SUA_SENHA;TrustServerCertificate=True;"' -ForegroundColor Gray
        
        $response = Read-Host "`n   Continuar mesmo assim? (s/n)"
        if ($response -ne "s" -and $response -ne "S") {
            Write-Host "   Execucao cancelada pelo usuario" -ForegroundColor Red
            Pop-Location
            exit 0
        }
    }
} else {
    Write-Host "   ERRO: appsettings.json não encontrado" -ForegroundColor Red
    Pop-Location
    exit 1
}

# ETAPA 4: Verificar EF Tools e aplicar migrations
Write-Host "`nETAPA 4: Aplicando migrations..." -ForegroundColor Yellow
# Verificar EF Tools
$efVersion = dotnet ef --version 2>$null
if (-not $efVersion) {
    Write-Host "   Instalando EF Tools..." -ForegroundColor Cyan
    dotnet tool install --global dotnet-ef > $null 2>&1
}

Push-Location "ControleArquivosGEADI.API"
$migrationOutput = dotnet ef database update 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK: Migrations aplicadas com sucesso" -ForegroundColor Green
} else {
    Write-Host "   ERRO: Migrations falharam:" -ForegroundColor Red
    Write-Host "   $migrationOutput" -ForegroundColor Gray
    Write-Host "`n   Possiveis solucoes:" -ForegroundColor Yellow
    Write-Host "      • Verificar se o banco DBGEADI existe" -ForegroundColor Gray
    Write-Host "      • Confirmar permissoes do usuario no servidor" -ForegroundColor Gray
    Write-Host "      • Validar string de conexao" -ForegroundColor Gray
    Pop-Location
    Pop-Location
    exit 1
}
Pop-Location

# ETAPA 5: Iniciar API local
Write-Host "`nETAPA 5: Iniciando API local..." -ForegroundColor Yellow
Write-Host "   Iniciando API em background..." -ForegroundColor Cyan

# Iniciar API em background
$apiJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Push-Location "ControleArquivosGEADI.API"
    dotnet run --urls "http://localhost:8080"
    Pop-Location
}

Write-Host "   OK: API iniciando (Job ID: $($apiJob.Id))" -ForegroundColor Green

# ETAPA 6: Testar API
Write-Host "`nETAPA 6: Testando API..." -ForegroundColor Yellow
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

# ETAPA 7: Validar integracao banco via API
Write-Host "`nETAPA 7: Validando integracao banco..." -ForegroundColor Yellow
try {
    $lotes = Invoke-RestMethod -Uri "http://localhost:8080/lotes" -Method GET -TimeoutSec 10
    Write-Host "   OK: API conectada ao banco com sucesso!" -ForegroundColor Green
    Write-Host "   Lotes encontrados: $($lotes.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "   AVISO: Erro na consulta ao banco via API" -ForegroundColor Yellow
    Write-Host "   Motivos possiveis: migrations pendentes, permissoes, conectividade" -ForegroundColor Gray
}

# ETAPA 8: Abrir Swagger
Write-Host "`nETAPA 8: Abrindo Swagger..." -ForegroundColor Yellow
Start-Process "http://localhost:8080/swagger"

Write-Host "`n=======================================================" -ForegroundColor Green
Write-Host "APLICACAO SERVIDOR INICIALIZADA!" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "API (.NET local): http://localhost:8080" -ForegroundColor Cyan
Write-Host "Swagger: http://localhost:8080/swagger" -ForegroundColor Cyan
Write-Host "SQL Server: Configurado via appsettings.json" -ForegroundColor Cyan
Write-Host "`nPara parar API: Get-Job | Stop-Job" -ForegroundColor Yellow
Write-Host "Para editar conexao: appsettings.json" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Green

# Voltar para pasta original
Pop-Location
