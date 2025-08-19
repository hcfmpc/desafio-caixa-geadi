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
    
    # Se user/password nao foram fornecidos, buscar do .env
    if (-not $User) {
        $User = Get-EnvVar "DB_USER" "sa"
    }
    if (-not $Password) {
        $Password = Get-EnvVar "DB_PASSWORD" "Ge@di2024"
    }
    
    return "Server=$Server;Database=$Database;User Id=$User;Password=$Password;TrustServerCertificate=True;Connect Timeout=$Timeout;"
}
