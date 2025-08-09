# Massa de Teste - GEADI

Esta pasta contém dados e scripts para popular o banco de dados com informações de teste.

## Arquivos

### 📄 `BASE_MENSAL.csv`
- **Descrição:** Dados de teste da base mensal ETL
- **Formato:** CSV com separador de vírgula
- **Uso:** Dados para importação no banco de testes

### 🔧 `import_ETL_BASE_MENSAL.ps1`
- **Descrição:** Script PowerShell para importar os dados CSV no banco
- **Pré-requisitos:** 
  - PowerShell 5.1 ou superior
  - SQL Server rodando (via docker-compose)
  - Migrations aplicadas no banco

### 📮 `PSI_GEADI.postman_collection.json`
- **Descrição:** Collection do Postman com requests para testar a API
- **Inclui:** Endpoints para validar os dados importados
- **Como usar:** Importe no Postman e execute os requests

## Como executar

### 1. Preparar o ambiente
```bash
# Na pasta database
docker-compose up -d

# Aplicar migrations
cd ../ControleArquivosGEADI.API
dotnet ef database update
cd ../database/massa-de-teste-db
```

### 2. Importar dados
```powershell
# Execute o script PowerShell
.\import_ETL_BASE_MENSAL.ps1
```

### 3. Validar com Postman
1. Abra o Postman
2. Importe `PSI_GEADI.postman_collection.json`
3. Execute os requests para validar

## Estrutura dos Dados

O arquivo CSV contém dados da tabela `ADITB003_BASE_MENSAL_ETL` com campos como:
- Informações de controle de arquivos
- Dados de processamento ETL
- Metadados de lotes e capturas

## Troubleshooting

### Erro na execução do script PowerShell:
```powershell
# Verifique a política de execução
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Erro de conexão com banco:
- Verifique se o container SQL Server está rodando
- Confirme as credenciais no script (sa/Ge@di2024)
- Teste a conexão: `docker-compose logs -f sqlserver`

### Dados não aparecem na API:
- Execute as migrations: `dotnet ef database update`
- Verifique se a API está apontando para o banco correto
- Confirme se os dados foram importados executando queries diretas no banco
