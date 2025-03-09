# Script para executar a aplicação localmente para testes
Write-Host "Iniciando a aplicação CI/CD Demo para testes locais..." -ForegroundColor Green

# Verificar se o Docker está em execução
try {
    docker info | Out-Null
}
catch {
    Write-Host "Erro: Docker não está em execução. Por favor, inicie o Docker Desktop." -ForegroundColor Red
    exit 1
}

# Parar contêineres existentes, se houver
Write-Host "Parando contêineres existentes, se houver..." -ForegroundColor Yellow
docker-compose down

# Construir e iniciar os contêineres
Write-Host "Construindo e iniciando os contêineres..." -ForegroundColor Yellow
docker-compose up -d --build

# Verificar se os contêineres estão em execução
$apiRunning = $false
$frontendRunning = $false
$maxAttempts = 10
$attempts = 0

Write-Host "Verificando se os contêineres estão em execução..." -ForegroundColor Yellow

while (($apiRunning -eq $false -or $frontendRunning -eq $false) -and $attempts -lt $maxAttempts) {
    $attempts++
    
    # Verificar API
    try {
        $apiResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/health" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($apiResponse.StatusCode -eq 200) {
            $apiRunning = $true
            Write-Host "API está em execução!" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "API ainda não está pronta. Tentativa $attempts de $maxAttempts..." -ForegroundColor Yellow
    }
    
    # Verificar Frontend
    try {
        $frontendResponse = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($frontendResponse.StatusCode -eq 200) {
            $frontendRunning = $true
            Write-Host "Frontend está em execução!" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Frontend ainda não está pronto. Tentativa $attempts de $maxAttempts..." -ForegroundColor Yellow
    }
    
    if ($apiRunning -eq $false -or $frontendRunning -eq $false) {
        Start-Sleep -Seconds 3
    }
}

if ($apiRunning -and $frontendRunning) {
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host "Aplicação CI/CD Demo está pronta para testes!" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "API: http://localhost:8080/api/tarefas" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Green
    
    # Abrir o navegador com o frontend
    Start-Process "http://localhost:3000"
}
else {
    Write-Host "Erro: Não foi possível iniciar todos os contêineres após $maxAttempts tentativas." -ForegroundColor Red
    Write-Host "Verifique os logs dos contêineres para mais detalhes:" -ForegroundColor Yellow
    Write-Host "docker-compose logs" -ForegroundColor Yellow
}

Write-Host "Para parar a aplicação, execute: docker-compose down" -ForegroundColor Yellow 