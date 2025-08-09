# Banco de Dados - Ambiente de Desenvolvimento

Este diretório contém os arquivos necessários para configurar o ambiente de banco de dados para desenvolvimento e testes da aplicação ControleArquivosGEADI.

## Pré-requisitos

- Docker Desktop instalado
- Docker Compose disponível

## Como inicializar

1. Navegue até este diretório:
   ```bash
   cd database
   ```

2. Execute o comando para subir o container:
   ```bash
   docker-compose up -d
   ```

3. Aguarde alguns segundos para o SQL Server inicializar completamente.

4. Verifique se o container está rodando:
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

## Migrations

Após subir o banco, execute as migrations da aplicação:

```bash
cd ../ControleArquivosGEADI.API
dotnet ef database update
```

## Observações

- Os dados são persistidos em um volume Docker (`sqlserver_data`)
- Para resetar completamente, use `docker-compose down -v` e depois `docker-compose up -d`
- Este ambiente é apenas para desenvolvimento/testes locais
