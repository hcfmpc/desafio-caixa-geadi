Write-Host "=== Controle de Arquivos GEADI - Verificacao de Dependencias ===" -ForegroundColor Green
Write-Host ""

Write-Host "Verificando .NET SDK..." -ForegroundColor Yellow
$dotnetOK = $false
try {
    $version = dotnet --version 2>$null
    Write-Host "OK - .NET SDK instalado: $version" -ForegroundColor Green
    $dotnetOK = $true
} catch {
    Write-Host "ERRO - .NET SDK nao encontrado" -ForegroundColor Red
    Write-Host "Download: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Verificando Docker..." -ForegroundColor Yellow
$dockerOK = $false
try {
    $version = docker --version 2>$null
    Write-Host "OK - Docker instalado: $version" -ForegroundColor Green
    $dockerOK = $true
} catch {
    Write-Host "ERRO - Docker nao encontrado" -ForegroundColor Red
    Write-Host "Download: https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "RESUMO:" -ForegroundColor Cyan

if ($dockerOK) {
    Write-Host "Opcao recomendada: Docker" -ForegroundColor Green
    Write-Host "Execute: docker-compose up -d" -ForegroundColor White
} elseif ($dotnetOK) {
    Write-Host "Opcao disponivel: .NET Local" -ForegroundColor Yellow
    Write-Host "Execute: dotnet run (na pasta ControleArquivosGEADI.API)" -ForegroundColor White
} else {
    Write-Host "Instale .NET 8.0 SDK ou Docker Desktop primeiro" -ForegroundColor Red
}

Write-Host ""
Write-Host "Veja README.md para instrucoes completas" -ForegroundColor Cyan
