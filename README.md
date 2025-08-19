# Controle de Arquivos GEADI

API para controle de arquivos e lotes do sistema GEADI desenvolvida em .NET 8.0.

## 📋 Pré-requisitos

### Opção 1: Docker (Recomendado)
- **Docker Desktop** - [Download aqui](https://www.docker.com/products/docker-desktop/)
- **.NET 8.0 SDK** - [Download aqui](https://dotnet.microsoft.com/download/dotnet/8.0) (para migrations)
- **PowerShell** (para scripts de automação)
- **Gi├── Scripts/                      # 🔧 Scripts de automação
│   ├── verify.ps1                # Verificação de dependências
│   ├── setup-env.ps1             # Configuração automática
│   ├── env-utils.ps1             # Funções utilitárias e segurança
│   ├── start_full_docker.ps1     # Cenário 1: Tudo Docker
│   ├── start_apiDotnet_dbDocker.ps1  # Cenário 2: API local + DB Docker
│   └── start_apiDotnet_dbServer.ps1  # Cenário 3: API local + DB servidorpara clonar o repositório)

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

### 2. Configurar ambiente (automático)
```powershell
# Detecta automaticamente o caminho do projeto
.\Scripts\setup-env.ps1
```

### 3. Verificar dependências
```powershell
.\Scripts\verify.ps1
```

### 4. Iniciar aplicação
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

### 5. Acessar aplicação
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

## 🔧 Configuração Personalizada

### Configuração Automática (Recomendado)
O script `setup-env.ps1` detecta automaticamente o caminho do projeto e configura o ambiente.

### Configuração Manual
Caso precise ajustar manualmente:

1. **Copie o arquivo de exemplo:**
```powershell
cp .env.example .env
```

2. **Edite o arquivo `.env`:**
```bash
# Ajuste o caminho para sua máquina
PROJECT_ROOT=C:/SeuCaminho/desafio-caixa-geadi
```

3. **Exemplos de caminhos:**
```bash
# Windows
PROJECT_ROOT=C:/Users/SeuUsuario/projetos/desafio-caixa-geadi
PROJECT_ROOT=D:/desenvolvimento/caixa/desafio-caixa-geadi

# Linux/Mac  
PROJECT_ROOT=/home/usuario/projetos/desafio-caixa-geadi
PROJECT_ROOT=/Users/usuario/desenvolvimento/desafio-caixa-geadi
```

## 🛠️ Cenários de Desenvolvimento

Escolha o script que melhor se adapta ao seu ambiente:

### 🐳 **Cenário 1: Tudo Docker** (Produção/Demonstração)
```powershell
.\Scripts\start_full_docker.ps1
```
**Quando usar:**
- ✅ Demonstrações e testes finais
- ✅ Ambiente idêntico à produção
- ✅ Setup sem dependências locais

**O que faz:**
- Inicia SQL Server + API em containers
- Configura ambiente automaticamente
- Aplica migrations e testa conectividade

---

### 🏗️ **Cenário 2: API Local + Banco Docker** (Desenvolvimento)
```powershell
.\Scripts\start_apiDotnet_dbDocker.ps1
```
**Quando usar:**
- ✅ **Recomendado para desenvolvimento**
- ✅ Debugging completo com breakpoints
- ✅ Hot reload durante codificação

**O que faz:**
- Inicia apenas SQL Server no Docker
- Roda API localmente via `dotnet run`
- Permite debugging completo no VS Code

---

### 🎯 **Cenário 3: API Local + Banco Servidor** (Corporativo)
```powershell
.\Scripts\start_apiDotnet_dbServer.ps1
```
**Quando usar:**
- ✅ Banco SQL Server já disponível na rede
- ✅ Ambientes corporativos com BD centralizado
- ✅ Desenvolvimento com dados reais

**O que faz:**
- Conecta no banco configurado em `appsettings.json`
- Valida conectividade antes de iniciar
- Roda API localmente para debugging

---

### ⚙️ **Configuração Manual** (Avançado)

#### Para configurar manualmente:

##### 1. Configurar ambiente
```powershell
# Apenas se necessário configurar caminhos
.\Scripts\setup-env.ps1
```

##### 2. Iniciar componentes individuais
```powershell
# Apenas SQL Server no Docker
docker-compose up -d sqlserver

# Apenas API local
cd ControleArquivosGEADI.API
dotnet run --urls "http://localhost:8080"
```

##### 3. Aplicar migrations manualmente
```powershell
cd ControleArquivosGEADI.API
dotnet ef database update
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
A aplicação mantém todos os dados após reinicialização. Para verificar, acesse:
- **Swagger UI**: http://localhost:8080/swagger  
- **Endpoint**: GET `/arquivos` para ver arquivos mapeados

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

# Testar conexão via API
curl http://localhost:8080/arquivos
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
├── Scripts/                      # 🔧 Scripts de automação
│   ├── verify.ps1                # Verificação de dependências
│   ├── setup-env.ps1             # Configuração automática
│   ├── env-utils.ps1             # Funções utilitárias e segurança
│   ├── start_full_docker.ps1     # Cenário 1: Tudo Docker
│   ├── start_apiDotnet_dbDocker.ps1  # Cenário 2: API local + DB Docker
│   ├── start_apiDotnet_dbServer.ps1  # Cenário 3: API local + DB servidor
│   └── ARQUITETURA_SCRIPTS.md    # Documentação detalhada dos scripts
├── database/                     # 🗄️ Scripts e dados para desenvolvimento
│   ├── script-manual/            # Script de teste do banco
│   │   └── import_ETL_BASE_MENSAL.ps1  # Teste isolado do banco
│   ├── massa-de-teste-db/        # Dados CSV para rota ETLBaseMensal
│   └── docker-compose.yml       # Configuração SQL Server
├── .env                          # 🔒 Variáveis de ambiente (credenciais)
├── Dockerfile                    # 🐳 Configuração Docker da aplicação
├── docker-compose.yml           # 🎯 Orquestração dos serviços
└── README.md                    # 📖 Esta documentação
```

## 📋 Scripts Disponíveis

| Script | Tempo | Propósito | Quando Usar |
|--------|-------|-----------|-------------|
| `Scripts\verify.ps1` | ~5s | Verifica dependências (Docker/.NET) | Antes de iniciar |
| `Scripts\setup-env.ps1` | ~1s | Configura ambiente automaticamente | Primeira vez |
| `Scripts\start_full_docker.ps1` | ~30s | Tudo Docker (API + DB) | ⭐ **Produção/Demo** |
| `Scripts\start_apiDotnet_dbDocker.ps1` | ~20s | API local + DB Docker | ⭐ **Desenvolvimento** |
| `Scripts\start_apiDotnet_dbServer.ps1` | ~15s | API local + DB servidor | **Corporativo** |

### 🔒 **Segurança Implementada**
- **Credenciais via .env**: Todas as senhas vêm exclusivamente do arquivo `.env`
- **Validação obrigatória**: Scripts falham se variáveis estão ausentes
- **Output mascarado**: Credenciais nunca aparecem nos logs (`user/***`)
- **Sem hardcoding**: Zero credenciais no código fonte

## 🎯 Fluxos Recomendados

### 🚀 **Desenvolvimento Rápido**
```powershell
.\Scripts\start_apiDotnet_dbDocker.ps1  # 20s - API local + DB Docker (recomendado)
```

### 🔍 **Primeira Vez/Troubleshooting** 
```powershell
.\Scripts\verify.ps1                    # 5s  - Verificar dependências
.\Scripts\start_full_docker.ps1         # 30s - Inicialização completa
```

### 🏢 **Ambiente Corporativo**
```powershell
# 1. Configure appsettings.json com seu servidor SQL
# 2. Execute:
.\Scripts\start_apiDotnet_dbServer.ps1   # 15s - API local + servidor
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
.\Scripts\start_full_docker.ps1         # Reconstruir do zero
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
- **Credenciais de desenvolvimento**: Definidas no arquivo `.env` (não hardcoded)
- **Segurança**: Scripts validam variáveis obrigatórias e mascaram credenciais no output
- Os dados ficam persistidos no volume Docker `sqlserver_data`
- Para produção, considere usar Docker Secrets para senhas
- **env-utils.ps1**: Fornece funções seguras para gerenciamento de credenciais