# Script para Teste de Banco Isolado

Este diretório contém script para testar a inserção de dados diretamente no banco, sem usar a API.

## 📋 Sobre o Script

### `import_ETL_BASE_MENSAL.ps1`
**Script para testar inserção no banco de dados isoladamente**

- **Propósito**: Testar se o banco consegue receber dados sem a API
- **Dados**: Arquivo BASE_MENSAL.csv (necessário para rota ETLBaseMensal da API)
- **Método**: SqlBulkCopy (alta performance)
- **Performance**: 20.000-50.000 registros/segundo

## 🎯 Quando Usar Este Script

### Cenários de Uso:
1. **Teste isolado do banco**: Verificar se o SQL Server consegue receber inserções
2. **Desenvolvimento sem API**: Testar banco de dados independentemente
3. **Debugging de conexão**: Validar configurações de banco

### ⚠️ **IMPORTANTE**:
- **NÃO é um script de dados de teste opcionais**
- O arquivo `BASE_MENSAL.csv` contém **dados necessários** para a rota `ETLBaseMensal` da API
- Use este script **apenas** para testar o banco **sem a API**

## 🚀 Como Usar

### Pré-requisitos
1. Docker container SQL Server rodando (`docker-compose up -d`)
2. Banco de dados DBGEADI criado
3. Migrations aplicadas (`dotnet ef database update`)

### Execução
```powershell
# Na raiz do projeto - Para testar banco isoladamente
.\database\script-manual\import_ETL_BASE_MENSAL.ps1

# Para sobrescrever dados existentes
.\database\script-manual\import_ETL_BASE_MENSAL.ps1 -Force
```

### Parâmetros
- `-Force`: Limpa dados existentes antes da importação

## 📊 Detalhes Técnicos

### Configuração de Conexão
- **Servidor**: localhost,1433 (Docker)
- **Banco**: DBGEADI
- **Usuário**: sa
- **Senha**: Ge@di2024

### Performance
- **Tamanho do lote**: 10.000 registros
- **Timeout**: 300 segundos
- **Tempo típico**: ~2 segundos para 100k registros

### Logs
O script fornece logs detalhados incluindo:
- ✅ Verificação de arquivo CSV
- 📊 Contagem de registros
- ⏱️ Tempo de execução
- 🚀 Taxa de importação (registros/segundo)

## 🔍 Exemplo de Saída

```
=======================================================
🚀 SCRIPT DE IMPORTAÇÃO ETL - BASE MENSAL
=======================================================
📁 Arquivo CSV: C:\projeto\database\massa-de-teste-db\BASE_MENSAL.csv
📏 Tamanho: 15.2 MB
🔌 Conectando ao SQL Server...
✅ Conexão estabelecida!
📖 Lendo arquivo CSV...
📊 Total de registros no CSV: 100000
🔄 Processando dados...
⚡ Iniciando importação em lote (SqlBulkCopy)...
=======================================================
✅ IMPORTAÇÃO CONCLUÍDA COM SUCESSO!
📊 Registros importados: 100000
⏱️  Tempo total: 2.34 segundos
🚀 Performance: 42735 registros/segundo
=======================================================
```

## ⚠️ Observações

- **Este script é para teste do banco, NÃO para a API**
- O arquivo CSV contém dados **necessários** para a rota ETLBaseMensal
- Use `-Force` para limpar dados existentes
- Verifique se o container SQL Server está rodando antes da execução
- Para usar a API normalmente, envie o CSV via endpoint ETLBaseMensal
