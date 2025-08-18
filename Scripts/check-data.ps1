# Verificar dados importados
# Garantir que estamos na pasta raiz do projeto
Push-Location "$PSScriptRoot\.."

$connectionString = "Server=localhost,1433;Database=DBGEADI;User Id=sa;Password=Ge@di2024;TrustServerCertificate=True;"

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

$command = $connection.CreateCommand()
$command.CommandText = "SELECT COUNT(*) FROM aditb003_base_mensal_ETL"
$count = $command.ExecuteScalar()

Write-Host "Registros na tabela aditb003_base_mensal_ETL: $count" -ForegroundColor Green

$connection.Close()

# Voltar para pasta original
Pop-Location
