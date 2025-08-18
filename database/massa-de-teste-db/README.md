# Massa de Teste - GEADI

Esta pasta contém dados de exemplo para popul- **Reset:** Para reimportar, limpe a tabela primeiro ou recrie o bancos com informações de teste.

## 📁 Arquivos

### 📄 `BASE_MENSAL.csv`
- **Descrição:** Dados de exemplo da base mensal ETL (100+ registros)
- **Formato:** CSV com separador `;` (ponto e vírgula)
- **Uso:** Importação via API endpoint ETL ou script manual

## � Como Importar os Dados

### **Método Recomendado: Via API**

1. **Inicie o ambiente completo:**
   ```bash
   # Na raiz do projeto
   docker-compose up
   ```

2. **Aguarde a API ficar disponível** (http://localhost:8080)

3. **Faça uma requisição POST para o endpoint ETL:**
   ```http
   POST http://localhost:8080/capturasEtlBaseMensal?pasta=C:\LocalGit\Caixa\desafio-caixa-geadi\database\massa-de-teste-db
   ```

## 🧪 Testando a Importação

### **Via Postman**
1. **Importe a collection:** `../script-manual/PSI_GEADI.postman_collection.json`
2. **Configure o ambiente:** `http://localhost:8080`
3. **Execute o request ETL** para importar os dados

### **Via curl**
```bash
curl -X POST "http://localhost:8080/capturasEtlBaseMensal?pasta=C:\LocalGit\Caixa\desafio-caixa-geadi\database\massa-de-teste-db"
```

## 📊 Estrutura dos Dados

O arquivo `BASE_MENSAL.csv` contém registros com as seguintes colunas:
- **am_honrado**: Valor honrado
- **base_calculo**: Base de cálculo
- **cart**: Carteira
- **co_ag_relac**: Código agência relacionada
- **co_cart**: Código carteira
- **co_mod**: Código modalidade
- **cpf_cnpj**: CPF/CNPJ do cliente
- **dt_mov**: Data movimento
- **vlr_conce**: Valor concedido
- E outros campos específicos do domínio

## ✅ Validação

Após a importação, você pode verificar:
1. **Quantidade de registros:** Endpoint para contar registros na tabela
2. **Dados específicos:** Queries para validar integridade
3. **Performance:** Tempo de importação e consulta

## ⚠️ Notas Importantes

- **Ambiente recomendado:** Use sempre a API para importação em desenvolvimento
- **Script PowerShell:** Apenas para testes manuais isolados do banco
- **Dados de exemplo:** Não são dados reais, apenas para validação da estrutura
- **Reset:** Para reimportar, limpe a tabela primeiro ou recrie o banco

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
