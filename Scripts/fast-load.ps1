# Script SqlBulkCopy - Super rapido para importar dados
Write-Host "=== Importacao SqlBulkCopy GEADI ===" -ForegroundColor Green

# Garantir que estamos na pasta raiz do projeto
Push-Location "$PSScriptRoot\.."

# Configuracao
$csvPath = ".\database\massa-de-teste-db\BASE_MENSAL.csv"
$connectionString = "Server=localhost,1433;Database=DBGEADI;User Id=sa;Password=Ge@di2024;TrustServerCertificate=True;"

# Verificar arquivo
if (-not (Test-Path $csvPath)) {
    Write-Host "Erro: Arquivo nao encontrado: $csvPath" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "Arquivo encontrado: $csvPath" -ForegroundColor Green

try {
    # 1. LIMPAR TABELA PRIMEIRO
    Write-Host "Limpando tabela existente..." -ForegroundColor Yellow
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    $command = $connection.CreateCommand()
    $command.CommandText = "TRUNCATE TABLE aditb003_base_mensal_ETL"
    $command.ExecuteNonQuery()
    Write-Host "Tabela limpa!" -ForegroundColor Green
    
    # 2. PREPARAR DATATABLE
    Write-Host "`nCarregando CSV em memoria..." -ForegroundColor Cyan
    $dataTable = New-Object System.Data.DataTable
    
    # Definir colunas
    $dataTable.Columns.Add("ctr", [string])
    $dataTable.Columns.Add("co_ope", [string]) 
    $dataTable.Columns.Add("cpf_cnpj", [string])
    $dataTable.Columns.Add("ic_caixa", [string])
    $dataTable.Columns.Add("tp_pessoa", [string])
    
    # Ler CSV
    $csvData = Import-Csv -Path $csvPath -Delimiter ';'
    $total = $csvData.Count
    Write-Host "Registros para processar: $total" -ForegroundColor Green
    
    # Adicionar dados ao DataTable
    Write-Host "Processando dados..." -ForegroundColor Cyan
    foreach ($row in $csvData) {
        $dataRow = $dataTable.NewRow()
        $dataRow["ctr"] = if ($row.ctr -eq "NULL" -or $row.ctr -eq "") { [DBNull]::Value } else { $row.ctr }
        $dataRow["co_ope"] = if ($row.co_ope -eq "NULL" -or $row.co_ope -eq "") { [DBNull]::Value } else { $row.co_ope }
        $dataRow["cpf_cnpj"] = if ($row.cpf_cnpj -eq "NULL" -or $row.cpf_cnpj -eq "") { [DBNull]::Value } else { $row.cpf_cnpj }
        $dataRow["ic_caixa"] = if ($row.ic_caixa -eq "NULL" -or $row.ic_caixa -eq "") { [DBNull]::Value } else { $row.ic_caixa }
        $dataRow["tp_pessoa"] = if ($row.tp_pessoa -eq "NULL" -or $row.tp_pessoa -eq "") { [DBNull]::Value } else { $row.tp_pessoa }
        $dataTable.Rows.Add($dataRow)
    }
    
    # 3. BULK COPY
    Write-Host "`nIniciando SqlBulkCopy..." -ForegroundColor Yellow
    $startTime = Get-Date
    
    $bulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($connection)
    $bulkCopy.DestinationTableName = "aditb003_base_mensal_ETL"
    $bulkCopy.BatchSize = 10000
    $bulkCopy.BulkCopyTimeout = 300
    
    # Mapeamento de colunas
    $bulkCopy.ColumnMappings.Add("ctr", "ctr")
    $bulkCopy.ColumnMappings.Add("co_ope", "co_ope")
    $bulkCopy.ColumnMappings.Add("cpf_cnpj", "cpf_cnpj")
    $bulkCopy.ColumnMappings.Add("ic_caixa", "ic_caixa")
    $bulkCopy.ColumnMappings.Add("tp_pessoa", "tp_pessoa")
    
    $bulkCopy.WriteToServer($dataTable)
    
    $endTime = Get-Date
    $totalTime = $endTime - $startTime
    
    # 4. VERIFICAR RESULTADO
    $countCommand = $connection.CreateCommand()
    $countCommand.CommandText = "SELECT COUNT(*) FROM aditb003_base_mensal_ETL"
    $importedCount = $countCommand.ExecuteScalar()
    
    Write-Host "`n================================" -ForegroundColor Green
    Write-Host "SQLBULKCOPY CONCLUIDO!" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host "Registros importados: $importedCount" -ForegroundColor Green
    Write-Host "Tempo total: $($totalTime.ToString('mm\:ss\.fff'))" -ForegroundColor Cyan
    
    if ($totalTime.TotalSeconds -gt 0) {
        $rate = [math]::Round($importedCount / $totalTime.TotalSeconds, 0)
        Write-Host "Taxa: $rate registros/segundo" -ForegroundColor Cyan
    }
    
    Write-Host "`nComparacao de metodos:" -ForegroundColor Yellow
    Write-Host "- SqlBulkCopy: ~20,000-50,000 reg/seg" -ForegroundColor Green
    Write-Host "- INSERT individual: ~500-1,000 reg/seg" -ForegroundColor Red
    Write-Host "Melhoria: 20-50x mais rapido!" -ForegroundColor Green
}
catch {
    Write-Host "`nERRO: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack: $($_.Exception.StackTrace)" -ForegroundColor Gray
    exit 1
}
finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
        Write-Host "`nConexao fechada." -ForegroundColor Gray
    }
    # Voltar para pasta original
    Pop-Location
}
