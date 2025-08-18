# Definir parâmetros de conexão
$serverName = "PE7466SR037\\CIOPERE"
$databaseName = "DBGEADI"
$tableName = "aditb003_base_mensal_ETL"
$userName = "eliasnageadi"
$password = "Ge@diM@ster2024"

# Caminho do arquivo CSV
$csvFilePath = "C:\PstExemplo\BASE_MENSAL.csv"

# Ler o arquivo CSV
$csvData = Import-Csv -Path $csvFilePath -Delimiter ';'

# Conectar ao SQL Server
$connectionString = "Server=$serverName;Database=$databaseName;User Id=$userName;Password=$password;"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

# Inserir dados na tabela
foreach ($row in $csvData) {
    $query = @"
    INSERT INTO $tableName (
        ctr, co_ope, cpf_cnpj, ic_caixa, tp_pessoa, co_sis, unidade, co_ag_relac, dt_conce, DD_VENCIMENTO_CONTRATO, 
        vlr_conce, posicao, da_ini, dt_mov, da_atual, nu_tabela_atual, base_calculo, rat_prov, rat_hh, co_mod, 
        cart, co_cart, co_seg, no_seg, co_segger, co_segger_gp, co_segad, rat_h5, rat_h6, ic_atacado, 
        ic_reg, ic_rj, ic_honrado, am_honrado
    ) VALUES (
        '$($row.ctr)', '$($row.co_ope)', '$($row.cpf_cnpj)', '$($row.ic_caixa)', '$($row.tp_pessoa)', '$($row.co_sis)', '$($row.unidade)', '$($row.co_ag_relac)', '$($row.dt_conce)', '$($row.DD_VENCIMENTO_CONTRATO)', 
        '$($row.vlr_conce)', '$($row.posicao)', '$($row.da_ini)', '$($row.dt_mov)', '$($row.da_atual)', '$($row.nu_tabela_atual)', '$($row.base_calculo)', '$($row.rat_prov)', '$($row.rat_hh)', '$($row.co_mod)', 
        '$($row.cart)', '$($row.co_cart)', '$($row.co_seg)', '$($row.no_seg)', '$($row.co_segger)', '$($row.co_segger_gp)', '$($row.co_segad)', '$($row.rat_h5)', '$($row.rat_h6)', '$($row.ic_atacado)', 
        '$($row.ic_reg)', '$($row.ic_rj)', '$($row.ic_honrado)', '$($row.am_honrado)'
    )
"@
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $command.ExecuteNonQuery()
}

# Fechar a conexão
$connection.Close()