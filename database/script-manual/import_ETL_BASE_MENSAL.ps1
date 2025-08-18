# ===============================================================
# Script de Importação ETL - BASE_MENSAL.csv
# ===============================================================
# Carrega dados de teste do arquivo CSV para a tabela aditb003_base_mensal_ETL
# Utiliza SqlBulkCopy para alta performance (20k-50k registros/seg)
# ===============================================================

param(
    [switch]$Force = $false
)

# Parâmetros de conexão para container Docker
$serverName = "localhost,1433"
$databaseName = "DBGEADI"
$tableName = "aditb003_base_mensal_ETL"
$userName = "sa"
$password = "Ge@di2024"

# Caminho do arquivo CSV (relativo à pasta script-manual)
$csvFilePath = "..\massa-de-teste-db\BASE_MENSAL.csv"

Write-Host "=======================================================" -ForegroundColor Green
Write-Host "🚀 SCRIPT DE IMPORTAÇÃO ETL - BASE MENSAL" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green

# Verificar se o arquivo CSV existe
if (-not (Test-Path $csvFilePath)) {
    Write-Host "❌ ERRO: Arquivo CSV não encontrado em: $csvFilePath" -ForegroundColor Red
    Write-Host "   Certifique-se de que o arquivo BASE_MENSAL.csv existe na pasta massa-de-teste-db" -ForegroundColor Yellow
    exit 1
}

$csvInfo = Get-Item $csvFilePath
Write-Host "📁 Arquivo CSV: $($csvInfo.FullName)" -ForegroundColor Cyan
Write-Host "📏 Tamanho: $([math]::Round($csvInfo.Length / 1MB, 2)) MB" -ForegroundColor Cyan

try {
    # Criar conexão
    $connectionString = "Server=$serverName;Database=$databaseName;User Id=$userName;Password=$password;TrustServerCertificate=true;"
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    
    Write-Host "🔌 Conectando ao SQL Server..." -ForegroundColor Yellow
    $connection.Open()
    Write-Host "✅ Conexão estabelecida!" -ForegroundColor Green

    # Verificar se há dados na tabela
    $checkCmd = $connection.CreateCommand()
    $checkCmd.CommandText = "SELECT COUNT(*) FROM $tableName"
    $existingCount = $checkCmd.ExecuteScalar()
    
    if ($existingCount -gt 0 -and -not $Force) {
        Write-Host "⚠️  AVISO: A tabela já contém $existingCount registros!" -ForegroundColor Yellow
        Write-Host "   Use o parâmetro -Force para sobrescrever os dados existentes" -ForegroundColor Yellow
        Write-Host "   Exemplo: .\import_ETL_BASE_MENSAL.ps1 -Force" -ForegroundColor Cyan
        return
    }
    
    if ($existingCount -gt 0 -and $Force) {
        Write-Host "🗑️  Limpando dados existentes ($existingCount registros)..." -ForegroundColor Yellow
        $deleteCmd = $connection.CreateCommand()
        $deleteCmd.CommandText = "TRUNCATE TABLE $tableName"
        $deleteCmd.ExecuteNonQuery()
        Write-Host "✅ Tabela limpa!" -ForegroundColor Green
    }

    # Ler CSV e criar DataTable
    Write-Host "📖 Lendo arquivo CSV..." -ForegroundColor Yellow
    $csvData = Import-Csv -Path $csvFilePath -Delimiter ';'
    $totalRows = $csvData.Count
    Write-Host "📊 Total de registros no CSV: $totalRows" -ForegroundColor Cyan

    # Criar DataTable com as colunas necessárias (apenas as 5 principais para performance)
    $dataTable = New-Object System.Data.DataTable
    $dataTable.Columns.Add("ctr", [string]) | Out-Null
    $dataTable.Columns.Add("co_ope", [string]) | Out-Null
    $dataTable.Columns.Add("cpf_cnpj", [string]) | Out-Null
    $dataTable.Columns.Add("ic_caixa", [string]) | Out-Null
    $dataTable.Columns.Add("tp_pessoa", [string]) | Out-Null

    Write-Host "🔄 Processando dados..." -ForegroundColor Yellow
    $processed = 0
    
    foreach ($row in $csvData) {
        $dataRow = $dataTable.NewRow()
        $dataRow["ctr"] = $row.ctr
        $dataRow["co_ope"] = $row.co_ope
        $dataRow["cpf_cnpj"] = $row.cpf_cnpj
        $dataRow["ic_caixa"] = $row.ic_caixa
        $dataRow["tp_pessoa"] = $row.tp_pessoa
        $dataTable.Rows.Add($dataRow)
        
        $processed++
        if ($processed % 10000 -eq 0) {
            Write-Host "   Processados: $processed/$totalRows registros..." -ForegroundColor Gray
        }
    }

    # Usar SqlBulkCopy para inserção rápida
    Write-Host "⚡ Iniciando importação em lote (SqlBulkCopy)..." -ForegroundColor Yellow
    $startTime = Get-Date
    
    $bulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($connection)
    $bulkCopy.DestinationTableName = $tableName
    $bulkCopy.BatchSize = 10000
    $bulkCopy.BulkCopyTimeout = 300
    
    # Mapear colunas
    $bulkCopy.ColumnMappings.Add("ctr", "ctr") | Out-Null
    $bulkCopy.ColumnMappings.Add("co_ope", "co_ope") | Out-Null
    $bulkCopy.ColumnMappings.Add("cpf_cnpj", "cpf_cnpj") | Out-Null
    $bulkCopy.ColumnMappings.Add("ic_caixa", "ic_caixa") | Out-Null
    $bulkCopy.ColumnMappings.Add("tp_pessoa", "tp_pessoa") | Out-Null
    
    $bulkCopy.WriteToServer($dataTable)
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    $recordsPerSecond = [math]::Round($totalRows / $duration, 0)

    Write-Host "=======================================================" -ForegroundColor Green
    Write-Host "✅ IMPORTAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Green
    Write-Host "📊 Registros importados: $totalRows" -ForegroundColor Cyan
    Write-Host "⏱️  Tempo total: $([math]::Round($duration, 2)) segundos" -ForegroundColor Cyan
    Write-Host "🚀 Performance: $recordsPerSecond registros/segundo" -ForegroundColor Cyan
    Write-Host "=======================================================" -ForegroundColor Green

} catch {
    Write-Host "❌ ERRO durante a importação:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
} finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
        Write-Host "🔌 Conexão fechada." -ForegroundColor Gray
    }
}