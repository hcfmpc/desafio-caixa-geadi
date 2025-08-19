# Funcoes utilitarias para leitura de variaveis de ambiente
function Get-EnvVar {
    param(
        [string]$Name,
        [string]$DefaultValue = ""
    )
    
    # Primeiro tentar variavel de ambiente do sistema
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ($value) {
        return $value
    }
    
    # Se nao encontrou, tentar ler do arquivo .env
    if (Test-Path ".env") {
        $envContent = Get-Content ".env"
        foreach ($line in $envContent) {
            if ($line -match "^$Name=(.*)$") {
                return $matches[1]
            }
        }
    }
    
    # Se nao encontrou, retornar valor padrao
    return $DefaultValue
}

function Get-ConnectionString {
    param(
        [string]$Server = "localhost,1433",
        [string]$Database = "master",
        [string]$User = "",
        [string]$Password = "",
        [int]$Timeout = 30
    )
    
    # Se user/password nao foram fornecidos, buscar OBRIGATORIAMENTE do .env
    if (-not $User) {
        $User = Get-EnvVar "DB_USER"
        if (-not $User) {
            throw "Variavel DB_USER nao encontrada no .env ou nas variaveis de ambiente"
        }
    }
    if (-not $Password) {
        $Password = Get-EnvVar "DB_PASSWORD"
        if (-not $Password) {
            throw "Variavel DB_PASSWORD nao encontrada no .env ou nas variaveis de ambiente"
        }
    }
    
    return "Server=$Server;Database=$Database;User Id=$User;Password=$Password;TrustServerCertificate=True;Connect Timeout=$Timeout;"
}

# Funcao para validar se todas as variaveis obrigatorias estao definidas
function Test-RequiredEnvVars {
    param(
        [string[]]$RequiredVars
    )
    
    $missing = @()
    foreach ($var in $RequiredVars) {
        $value = Get-EnvVar $var
        if (-not $value) {
            $missing += $var
        }
    }
    
    if ($missing.Count -gt 0) {
        Write-Host "   ERRO: Variaveis obrigatorias nao encontradas:" -ForegroundColor Red
        foreach ($var in $missing) {
            Write-Host "      • $var" -ForegroundColor Gray
        }
        Write-Host "   Verifique o arquivo .env" -ForegroundColor Yellow
        return $false
    }
    
    return $true
}
