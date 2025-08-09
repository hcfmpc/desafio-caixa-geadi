# Banco de Dados - Ambiente de Desenvolvimento

Este diretório contém os arquivos necessários para configurar o ambiente de banco de dados para desenvolvimento e testes da aplicação ControleArquivosGEADI.

## Estrutura

```
database/
├── docker-compose.yml               # Configuração do SQL Server
├── GEADICriandoTabelas.sql         # Script SQL para criar tabelas e relacionamentos
├── README.md                       # Este arquivo
└── massa-de-teste-db/              # Massa de teste e scripts
    ├── BASE_MENSAL.csv             # Dados de teste em formato CSV
    ├── import_ETL_BASE_MENSAL.ps1  # Script PowerShell para importação
    └── PSI_GEADI.postman_collection.json  # Collection do Postman para testes
```

## Pré-requisitos

- Docker Desktop instalado
- Docker Compose disponível

## Como inicializar

### Opção 1: Usando Migrations (Recomendado para desenvolvimento)

1. Navegue até este diretório:
   ```bash
   cd database
   ```

2. Execute o comando para subir o container:
   ```bash
   docker-compose up -d
   ```

3. Aguarde alguns segundos para o SQL Server inicializar completamente.

4. Execute as migrations da aplicação:
   ```bash
   cd ../ControleArquivosGEADI.API
   dotnet ef database update
   cd ../database
   ```

### Opção 2: Usando Script SQL direto

1. Suba o container SQL Server:
   ```bash
   docker-compose up -d
   ```

2. Execute o script SQL para criar as tabelas:
   ```bash
   # Via linha de comando (sqlcmd deve estar instalado)
   sqlcmd -S localhost,1433 -U sa -P Ge@di2024 -i GEADICriandoTabelas.sql
   
   # OU conecte com Azure Data Studio/SSMS e execute o arquivo GEADICriandoTabelas.sql
   ```

3. Verifique se o container está rodando:
   ```bash
   docker-compose ps
   ```

## Configurações

- **Servidor:** localhost,1433
- **Usuário:** sa
- **Senha:** Ge@di2024 (definida no docker-compose.yml)
- **Database:** DBGEADI
- **Porta:** 1433

## String de Conexão

```
Data Source=localhost;Initial Catalog=DBGEADI;User ID=sa;Password=Ge@di2024;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;ApplicationIntent=ReadWrite;MultiSubnetFailover=False
```

## Comandos Úteis

- **Parar o container:** `docker-compose down`
- **Reiniciar:** `docker-compose restart`
- **Ver logs:** `docker-compose logs -f sqlserver`
- **Remover completamente:** `docker-compose down -v` (remove dados!)

## Estrutura do Banco de Dados

O arquivo `GEADICriandoTabelas.sql` contém:

### 📋 **Tabelas Criadas:**
- **`aditb001_controle_arquivos`** - Controle de arquivos do sistema
- **`aditb002_lote_arquivos`** - Lotes de processamento de arquivos  
- **`aditb003_base_mensal_ETL`** - Base mensal para ETL com dados detalhados

### 🔗 **Relacionamentos:**
- **FK:** `aditb001_controle_arquivos.nu_lote_id` → `aditb002_lote_arquivos.nu_id`
- **Cascade Delete:** Exclusão de lote remove arquivos relacionados

### 🎯 **Funcionalidades:**
- ✅ Criação automática do banco `DBGEADI`
- ✅ Estrutura completa de tabelas
- ✅ Constraints e índices otimizados
- ✅ Foreign keys com integridade referencial

## Migrations

## Migrations vs Script SQL

### 🔄 **Entity Framework Migrations (Recomendado)**
- Mantém sincronia com os models da aplicação
- Controle de versão das mudanças de schema
- Executar: `dotnet ef database update`

### 📜 **Script SQL direto (GEADICriandoTabelas.sql)**
- Criação rápida para ambiente de teste
- Schema já pronto sem dependência do .NET
- Útil para DBAs ou configuração manual

**Importante:** Use APENAS uma das opções. Se usar o script SQL, não execute migrations depois.

## Massa de Teste

A pasta `massa-de-teste-db/` contém arquivos para popular o banco com dados de teste:

### Arquivos Disponíveis:

- **`BASE_MENSAL.csv`** - Dados de teste em formato CSV
- **`import_ETL_BASE_MENSAL.ps1`** - Script PowerShell para importar os dados
- **`PSI_GEADI.postman_collection.json`** - Collection do Postman para testar a API

### Como usar a massa de teste:

1. **Certifique-se que o banco está rodando:**
   ```bash
   docker-compose ps
   ```

2. **Execute as migrations primeiro:**
   ```bash
   cd ../ControleArquivosGEADI.API
   dotnet ef database update
   cd ../database
   ```

3. **Execute o script PowerShell para importar dados:**
   ```powershell
   cd massa-de-teste-db
   .\import_ETL_BASE_MENSAL.ps1
   ```

4. **Para testar a API, importe a collection no Postman:**
   - Abra o Postman
   - Importe o arquivo `PSI_GEADI.postman_collection.json`
   - Execute os requests para validar os dados

### Dicas:

- **Resetar dados:** Se precisar limpar e reimportar os dados, execute novamente o script PowerShell
- **Validação:** Use a collection do Postman para verificar se os dados foram importados corretamente
- **Logs:** Em caso de erro na importação, verifique os logs do container SQL Server com `docker-compose logs -f sqlserver`

## Observações

- Os dados são persistidos em um volume Docker (`sqlserver_data`)
- Para resetar completamente, use `docker-compose down -v` e depois `docker-compose up -d`
- Este ambiente é apenas para desenvolvimento/testes locais
