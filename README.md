# Controle de Arquivos GEADI

API para controle de arquivos e lotes do sistema GEADI desenvolvida em .NET 8.0.

## 📋 Pré-requisitos

### Opção 1: Docker (Recomendado)
- **Docker Desktop** - [Download aqui](https://www.docker.com/products/docker-desktop/)
- **.NET 8.0 SDK** - [Download aqui](https://dotnet.microsoft.com/download/dotnet/8.0) (para migrations)
- **PowerShell** (para scripts de automação)
- **Git** (para clonar o repositório)

### Opção 2: Desenvolvimento Local
- **.NET 8.0 SDK** - [Download aqui](https://dotnet.microsoft.com/download/dotnet/8.0)
- **SQL Server** (Express, LocalDB ou Docker)
- **Git** (para clonar o repositório)

## 🚀 Instalação Rápida (Docker)

### 1. Clone o repositório
```powershell
git clone https://github.com/hcfmpc/desafio-caixa-geadi.git
cd desafio-caixa-geadi
```

### 2. Verificar dependências
```powershell
.\Scripts\verify.ps1
```

### 3. Iniciar aplicação
```powershell
# Subir containers (API + Banco)
docker-compose up -d

# Criar banco de dados (apenas primeira vez)
docker exec -it geadi-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Ge@di2024" -C -Q "CREATE DATABASE DBGEADI"

# Aplicar migrations (apenas primeira vez)
cd ControleArquivosGEADI.API
dotnet tool install --global dotnet-ef
dotnet ef database update
cd ..
```

### 4. Acessar aplicação
- **API**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger
- **SQL Server**: localhost:1433 (sa/Ge@di2024)

## ⚡ Scripts de Inicialização

### Opção 1: Inicialização Rápida (Recomendado)
```powershell
# Inicialização otimizada (~15 segundos)
.\Scripts\quick-start.ps1
```

### Opção 2: Inicialização Completa
```powershell
# Executa: verificação + docker-compose + migrations + banco
.\Scripts\start.ps1
```

### Opção 3: Desenvolvimento Híbrido (SQL no Docker + API Local)
```powershell
# Inicia apenas SQL Server
docker-compose up -d sqlserver

# Em outro terminal, executar API localmente:
dotnet run --project ControleArquivosGEADI.API
# API disponível em: http://localhost:8080
```

### Opção 4: Script Híbrido Automatizado  
```powershell
# Inicia apenas SQL Server para desenvolvimento
.\Scripts\start-sql-only.ps1

# Em outro terminal:
dotnet run --project ControleArquivosGEADI.API
```

### Opção 5: Docker Manual
```powershell
# Para usuários que preferem controle manual
docker-compose up -d
# Nota: SQL Server pode demorar 60+ segundos para inicializar
```

## 🛠️ Desenvolvimento Local

### Opção 1: Híbrido (Recomendado para Desenvolvimento)
Use SQL Server no Docker + API local para melhor debugging:

#### 1. Iniciar apenas SQL Server
```powershell
# Subir apenas o banco de dados
docker-compose up -d sqlserver
# Aguardar inicialização (~30 segundos na primeira vez)
```

#### 2. Executar API localmente
```powershell
# Executar a partir da raiz do projeto
dotnet run --project ControleArquivosGEADI.API

# API disponível em: http://localhost:8080
# Swagger UI: http://localhost:8080/swagger
```

#### 3. (Opcional) Aplicar migrations na primeira vez
```powershell
# Se for a primeira execução:
cd ControleArquivosGEADI.API
dotnet ef database update
cd ..

# Depois executar:
dotnet run --project ControleArquivosGEADI.API
```

#### 4. (Opcional) Testar banco isoladamente
```powershell
# Em outro terminal, na raiz do projeto:
.\database\script-manual\import_ETL_BASE_MENSAL.ps1
```

**Vantagens da abordagem híbrida:**
- ✅ Banco containerizado (sem instalação local)
- ✅ API rodando localmente (debugging completo)
- ✅ Mesma porta (8080) tanto local quanto container
- ✅ Hot reload durante desenvolvimento
- ✅ Acesso completo a breakpoints
- ✅ Logs detalhados no terminal
- ✅ Mesma porta (8080) tanto local quanto container
- ✅ Hot reload durante desenvolvimento
- ✅ Acesso completo a breakpoints

### Opção 2: Totalmente Local (sem Docker)

#### 1. Instalar dependências
- Baixe e instale o [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- Configure SQL Server local ou use LocalDB

#### 2. Configurar banco
```powershell
# Editar connection string em appsettings.json se necessário
# Aplicar migrations
cd ControleArquivosGEADI.API
dotnet ef database update
cd ..
```

#### 3. Executar aplicação
```powershell
cd ControleArquivosGEADI.API
dotnet run
# API disponível em: http://localhost:8080
```

## 📊 Banco de Dados

### Estrutura das Tabelas
A aplicação cria automaticamente as seguintes tabelas:
- `aditb001_controle_arquivos` - Controle de arquivos capturados
- `aditb002_lote_arquivos` - Lotes de processamento de arquivos  
- `aditb003_base_mensal_ETL` - Base mensal para processamento ETL

### Inicialização do Banco

#### Opção 1: Banco Vazio (Padrão)
Após seguir os passos de instalação, o banco será criado com as tabelas vazias, pronto para receber dados via API.

#### Opção 2: Testar Rota ETLBaseMensal
Use a API normalmente e envie o arquivo `BASE_MENSAL.csv` via endpoint ETLBaseMensal para testar a funcionalidade.

## 🧪 Testes Isolados de Banco de Dados

### Cenário: Testar Inserção Direta no Banco (Sem API)
Caso queira verificar se o banco consegue receber dados sem usar a API:

```powershell
# Para testar inserção direta no SQL Server
.\database\script-manual\import_ETL_BASE_MENSAL.ps1
```

**Quando usar:**
- ✅ Debugging de problemas de conexão com banco
- ✅ Testar performance de inserção isoladamente  
- ✅ Verificar se migrations foram aplicadas corretamente
- ❌ **NÃO usar para inicialização normal da aplicação**

# Verificar se os dados foram importados
.\Scripts\check-data.ps1
```
**Dados importados:**
- Tabela: `aditb003_base_mensal_ETL`
- Fonte: `database/massa-de-teste-db/BASE_MENSAL.csv`
- Registros: 100.000 linhas com dados simulados

### Persistência de Dados

#### ✅ **Dados Persistem ao Parar/Reiniciar**
```powershell
# Parar aplicação
docker-compose down

# Reiniciar aplicação  
docker-compose up -d
# ✅ Todos os dados permanecem intactos
```

#### ❌ **Remover Dados Permanentemente**
```powershell
# Apagar dados e volumes
docker-compose down -v
# ⚠️ CUIDADO: Remove TODOS os dados do banco
```

#### 📊 **Verificar Dados Após Reinicialização**
```powershell
.\Scripts\check-data.ps1
# Mostra quantidade de registros em cada tabela
```

## 🏢 Usando SQL Server Externo

### Configuração para Servidor Próprio

#### 1. Preparar Servidor SQL
- ✅ SQL Server 2019 ou superior
- ✅ Autenticação SQL habilitada
- ✅ Usuário com permissões de `db_owner`

#### 2. Configurar Connection String
Edite o arquivo `ControleArquivosGEADI.API/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=SEU_SERVIDOR;Initial Catalog=DBGEADI;User ID=seu_usuario;Password=sua_senha;Connect Timeout=30;Encrypt=True;TrustServerCertificate=True;"
  }
}
```

#### 3. Aplicar Migrations
```powershell
cd ControleArquivosGEADI.API
dotnet ef database update
cd ..
```

**✅ O que as Migrations fazem automaticamente:**
- Criam o banco `DBGEADI` se não existir
- Criam todas as 3 tabelas necessárias
- Aplicam índices e constraints
- Configuram relacionamentos entre tabelas

**📋 Não é necessário:**
- Executar scripts SQL manualmente
- Criar tabelas previamente
- Configurar esquemas ou usuários especiais

#### 4. Executar Aplicação
```powershell
# Desenvolvimento local
dotnet run

# Ou via Docker (apontando para servidor externo)
docker-compose up -d api
```

## 🌐 Endpoints Principais

- `GET /arquivos` - Listar arquivos
- `GET /arquivos/{id}` - Buscar arquivo por ID
- `GET /lotes` - Listar lotes
- `GET /lotes/{id}` - Buscar lote por ID
- `POST /mapearpasta` - Mapear arquivos de pasta
- `POST /etlbasemensal` - Processar ETL base mensal

## 🔧 Comandos Úteis

### Gerenciamento Docker
```powershell
# Ver status dos containers
docker ps

# Ver logs da API
docker-compose logs api

# Ver logs do banco
docker-compose logs sqlserver

# Parar aplicação
docker-compose down

# Rebuild completo
docker-compose up --build

# Limpar volumes (apaga dados do banco)
docker-compose down -v
```

### Scripts Utilitários
```powershell
# Verificar dependências
.\Scripts\verify.ps1

# Inicialização rápida (~15 segundos)
.\Scripts\quick-start.ps1

# Inicialização completa automatizada
.\Scripts\start.ps1

# Verificar dados importados
.\Scripts\check-data.ps1
```

## ⏱️ Comparação de Performance

| Método | Tempo | Descrição |
|--------|-------|-----------|
| `.\quick-start.ps1` | ~15 segundos | ⚡ Otimizado, inicia SQL primeiro |
| `.\start.ps1` | ~30 segundos | 🔄 Completo com todas verificações |
| `docker-compose up -d` | 60+ segundos | 🐌 Aguarda health check do SQL |

## 🐛 Solução de Problemas

### ❌ SQL Server demora muito
```powershell
# Use o script otimizado
.\Scripts\quick-start.ps1

# Ou inicie SQL Server separadamente
docker-compose up -d sqlserver
# Aguarde ~10 segundos
docker-compose up -d api
```

### Banco não conecta
```powershell
# Verificar se SQL Server está rodando
docker ps

# Verificar logs do banco
docker logs geadi-sqlserver

# Testar conexão diretamente
.\Scripts\check-data.ps1
```

### Swagger não aparece
- Verifique se `ASPNETCORE_ENVIRONMENT=Development` no docker-compose.yml
- Acesse: http://localhost:8080/swagger (não https)
- Aguarde alguns segundos para a API inicializar

### Porta ocupada
```powershell
# Windows - verificar processo na porta 8080
netstat -ano | findstr :8080

# Parar containers e tentar novamente
docker-compose down
docker-compose up -d
```

### Problemas com dados de teste
```powershell
# Verificar se containers estão funcionando
docker ps

# Verificar conexão com banco
.\Scripts\check-data.ps1
```

## 📁 Estrutura do Projeto

```
desafio-caixa-geadi/
├── ControleArquivosGEADI.API/    # 🚀 Projeto principal da API
│   ├── DbContexts/               # Contextos Entity Framework
│   ├── EndpointHandlers/         # Handlers dos endpoints
│   ├── Models/                   # Modelos de dados
│   └── Migrations/               # Migrações do banco
├── Scripts/                      # � Scripts de automação
│   ├── verify.ps1                # Verificação de dependências
│   ├── quick-start.ps1           # Inicialização rápida (~15s)
│   ├── start.ps1                 # Inicialização completa
│   └── check-data.ps1            # Verificação de dados
├── database/                     # 🗄️ Scripts e dados para desenvolvimento
│   ├── script-manual/            # Script de teste do banco
│   │   └── import_ETL_BASE_MENSAL.ps1  # Teste isolado do banco
│   ├── massa-de-teste-db/        # Dados CSV para rota ETLBaseMensal
│   └── docker-compose.yml       # Configuração SQL Server
├── Dockerfile                    # � Configuração Docker da aplicação
├── docker-compose.yml           # 🎯 Orquestração dos serviços
└── README.md                    # 📖 Esta documentação
```

## 📋 Scripts Disponíveis

| Script | Tempo | Propósito | Quando Usar |
|--------|-------|-----------|-------------|
| `Scripts\verify.ps1` | ~5s | Verifica dependências (Docker/.NET) | Antes de iniciar |
| `Scripts\quick-start.ps1` | ~15s | Inicialização otimizada | ⭐ **Recomendado** |
| `Scripts\start.ps1` | ~30s | Inicialização completa com verificações | Primeira execução |
| `Scripts\check-data.ps1` | ~1s | Verifica quantidade de dados no banco | Para validação |

## 🎯 Fluxos Recomendados

### 🚀 **Desenvolvimento Rápido**
```powershell
.\Scripts\quick-start.ps1      # 15s - Inicializar tudo
```

### 🔍 **Primeira Vez/Troubleshooting** 
```powershell
.\Scripts\verify.ps1           # 5s  - Verificar dependências
.\Scripts\start.ps1            # 30s - Inicialização completa
.\Scripts\check-data.ps1       # 1s  - Verificar se tudo OK
```

## 🔄 Gerenciamento de Dados

### **Parar/Reiniciar (Dados Persistem)**
```powershell
docker-compose down    # Parar containers
docker-compose up -d   # Reiniciar containers
# ✅ Dados permanecem intactos no volume Docker
```

### **Reset Completo (Remove Tudo)**
```powershell
docker-compose down -v # Remover containers + volumes
.\Scripts\quick-start.ps1       # Reconstruir do zero
```

## 🏷️ Tecnologias

- **.NET 8.0** - Framework principal
- **Entity Framework Core** - ORM
- **SQL Server 2022** - Banco de dados
- **Docker** - Containerização
- **Swagger/OpenAPI** - Documentação da API
- **AutoMapper** - Mapeamento de objetos

## 📝 Notas Importantes

- O Swagger só funciona em ambiente `Development`
- A senha do SQL Server é `Ge@di2024` (para desenvolvimento)
- Os dados ficam persistidos no volume Docker `sqlserver_data`
- Para produção, considere usar Docker Secrets para senhas