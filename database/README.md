# Banco de Dados - Ambiente de Desenvolvimento

Este diretório contém os arquivos e scripts necessários para configurar e testar o ambiente de banco de dados da aplicação ControleArquivosGEADI.

## 📁 Estrutura

```
database/
├── README.md                       # Este arquivo (documentação)
├── script-manual/                  # Scripts para ambiente de teste manual
│   ├── docker-compose.yml          # SQL Server standalone para testes
│   ├── GEADICriandoTabelas.sql     # Script SQL para criar tabelas
│   ├── import_ETL_BASE_MENSAL.ps1  # Script PowerShell para importação manual
│   └── PSI_GEADI.postman_collection.json  # Collection do Postman
└── massa-de-teste-db/              # Dados de teste
    ├── BASE_MENSAL.csv             # Arquivo CSV com dados de exemplo
    └── README.md                   # Instruções específicas da massa de teste
```

## 🎯 Objetivo

Este diretório oferece **duas abordagens** para trabalhar com o banco de dados:

### 1. **Ambiente de Produção/Desenvolvimento (Recomendado)**
- Use o **docker-compose.yml principal** na raiz do projeto
- Executa automaticamente API + SQL Server integrados
- Utiliza Entity Framework Migrations
- **Comando:** `docker-compose up` (na raiz do projeto)

### 2. **Ambiente de Teste Manual (scripts nesta pasta)**
- Use os arquivos da pasta `script-manual/`
- SQL Server standalone para testes isolados
- Scripts SQL manuais para criação de estrutura
- **Comando:** `docker-compose up` (dentro da pasta `script-manual/`)

## 🔧 Configuração para Teste Manual

Se você quiser apenas testar o banco de dados **sem a API**, siga os passos:

### Pré-requisitos
- Docker Desktop instalado
- PowerShell (para scripts de importação)

### Passos

1. **Navegue para a pasta de scripts manuais:**
   ```bash
   cd database/script-manual
   ```

2. **Suba apenas o SQL Server:**
   ```bash
   docker-compose up -d
   ```

3. **Aguarde o SQL Server inicializar** (30-60 segundos)

4. **Execute o script SQL para criar as tabelas:**
   ```bash
   # Via sqlcmd (se instalado)
   sqlcmd -S localhost,1433 -U sa -P Ge@di2024 -i GEADICriandoTabelas.sql
   
   # OU conecte com Azure Data Studio/SSMS e execute o arquivo
   ```

5. **[OPCIONAL] Importe dados de teste:**
   ```powershell
   # Importação manual via PowerShell
   .\import_ETL_BASE_MENSAL.ps1
   ```

## ⚙️ Configurações do Ambiente Manual

- **Servidor:** localhost,1433
- **Usuário:** sa  
- **Senha:** Ge@di2024
- **Database:** DBGEADI
- **Porta:** 1433

### String de Conexão
```
Data Source=localhost;Initial Catalog=DBGEADI;User ID=sa;Password=Ge@di2024;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;ApplicationIntent=ReadWrite;MultiSubnetFailover=False
```

## 🗄️ Estrutura do Banco de Dados

O arquivo `script-manual/GEADICriandoTabelas.sql` contém:

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

## 🔄 Abordagens de Criação do Schema

### **Entity Framework Migrations (Ambiente Integrado)**
- Mantém sincronia com os models da aplicação
- Controle de versão das mudanças de schema
- Usado no ambiente principal (docker-compose na raiz)
- **Executar:** `dotnet ef database update`

### **Script SQL Direto (Testes Manuais)**
- Criação rápida para ambiente de teste isolado
- Schema pronto sem dependência do .NET
- Útil para DBAs ou configuração manual
- **Localização:** `script-manual/GEADICriandoTabelas.sql`

**⚠️ Importante:** Use APENAS uma das opções por ambiente.

## 📊 Massa de Teste

A pasta `massa-de-teste-db/` contém dados para popular o banco:

### Arquivos Disponíveis:
- **`BASE_MENSAL.csv`** - Dados de exemplo (100+ registros)
- **README.md** - Instruções específicas

### 💡 Como Importar Dados

#### **Opção 1: Via API (Recomendado)**
1. **Suba o ambiente completo:**
   ```bash
   # Na raiz do projeto
   docker-compose up
   ```

2. **Use o endpoint ETL da API:**
   ```http
   POST http://localhost:8080/capturasEtlBaseMensal?pasta=C:\LocalGit\Caixa\desafio-caixa-geadi\database\massa-de-teste-db
   ```

#### **Opção 2: Via Script PowerShell (Manual)**
1. **Para ambiente de teste manual apenas:**
   ```bash
   cd database/script-manual
   docker-compose up -d
   # Execute o script SQL para criar tabelas
   ```

2. **Execute o script PowerShell:**
   ```powershell
   cd ../massa-de-teste-db
   .\import_ETL_BASE_MENSAL.ps1
   ```

## 🧪 Testes com Postman

- **Collection:** `script-manual/PSI_GEADI.postman_collection.json`
- **Como usar:**
  1. Importe no Postman
  2. Configure o ambiente para `http://localhost:8080` (API integrada)
  3. Execute os requests para validar

## 🛠️ Comandos Úteis

### Ambiente Manual (script-manual/)
```bash
# Iniciar apenas SQL Server
cd database/script-manual && docker-compose up -d

# Parar
docker-compose down

# Ver logs
docker-compose logs -f sqlserver

# Resetar dados (cuidado!)
docker-compose down -v
```

### Ambiente Integrado (raiz do projeto)  
```bash
# Iniciar API + SQL Server
docker-compose up

# Parar tudo
docker-compose down

# Rebuild se houver mudanças
docker-compose up --build
```

## 📝 Observações Importantes

- **Dados persistentes:** Volumes Docker mantêm dados entre reinicializações
- **Resetar completamente:** Use `docker-compose down -v` + `docker-compose up -d`
- **Ambiente de desenvolvimento:** Configure a API para usar a **rota ETL** para importar dados
- **Scripts manuais:** Apenas para testes isolados do banco de dados

## 🚀 Próximos Passos

1. **Para desenvolvimento:** Use o docker-compose na raiz do projeto
2. **Para testar apenas DB:** Use os scripts em `script-manual/`
3. **Para dados de teste:** Prefira a API com endpoint ETL ao invés do script PowerShell
