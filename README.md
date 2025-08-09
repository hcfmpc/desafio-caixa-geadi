# ControleArquivosGEADI

**Versão:** 1.0.003

API para controle de arquivos do sistema GEADI.

## Estrutura do Projeto

- **ControleArquivosGEADI.API/** - Projeto principal da Web API
- **database/** - Configurações de banco de dados para desenvolvimento

## Executando o Projeto

### 1. Banco de Dados

Primeiro, configure o ambiente de banco de dados:

```bash
cd database
docker-compose up -d
```

Para mais detalhes, consulte o [README do banco de dados](./database/README.md).

### 2. Aplicação

```bash
cd ControleArquivosGEADI.API
dotnet ef database update  # Aplica as migrations
dotnet run                 # Executa a aplicação
```

A API estará disponível em: `https://localhost:7xxx` (porta gerada automaticamente)

## Tecnologias Utilizadas

- .NET 8
- Entity Framework Core
- SQL Server
- AutoMapper
- Swagger/OpenAPI