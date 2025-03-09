# Script de configuração automatizada do ambiente de desenvolvimento
Write-Host "Iniciando configuração do ambiente de desenvolvimento..." -ForegroundColor Green

# Verificar se o Docker está em execução
$dockerRunning = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
if (-not $dockerRunning) {
    Write-Host "Iniciando Docker Desktop..." -ForegroundColor Yellow
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    
    # Aguardar o Docker iniciar
    Write-Host "Aguardando o Docker iniciar..."
    $retries = 0
    $maxRetries = 30
    $dockerRunning = $false
    
    while (-not $dockerRunning -and $retries -lt $maxRetries) {
        Start-Sleep -Seconds 5
        $retries++
        
        try {
            $dockerInfo = docker info 2>&1
            if ($LASTEXITCODE -eq 0) {
                $dockerRunning = $true
                Write-Host "Docker está pronto!" -ForegroundColor Green
            }
        } catch {
            Write-Host "Aguardando Docker iniciar... ($retries/$maxRetries)" -ForegroundColor Yellow
        }
    }
    
    if (-not $dockerRunning) {
        Write-Host "Falha ao iniciar o Docker. Verifique a instalação." -ForegroundColor Red
        exit 1
    }
}

# Baixar dependências
Write-Host "Baixando dependências da API..." -ForegroundColor Cyan
cd api
go mod tidy
if ($LASTEXITCODE -ne 0) {
    Write-Host "Falha ao baixar dependências da API." -ForegroundColor Red
    exit 1
}

Write-Host "Baixando dependências do Frontend..." -ForegroundColor Cyan
cd ../frontend
go mod tidy
if ($LASTEXITCODE -ne 0) {
    Write-Host "Falha ao baixar dependências do Frontend." -ForegroundColor Red
    exit 1
}

# Voltar para o diretório raiz
cd ..

# Construir e iniciar os contêineres
Write-Host "Construindo e iniciando os contêineres..." -ForegroundColor Cyan
docker-compose up --build -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "Falha ao iniciar os contêineres." -ForegroundColor Red
    exit 1
}

# Verificar se os serviços estão em execução
Write-Host "Verificando se os serviços estão em execução..." -ForegroundColor Cyan
$apiRunning = $false
$frontendRunning = $false
$retries = 0
$maxRetries = 12

while ((-not $apiRunning -or -not $frontendRunning) -and $retries -lt $maxRetries) {
    Start-Sleep -Seconds 5
    $retries++
    
    try {
        $apiResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/health" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($apiResponse.StatusCode -eq 200) {
            $apiRunning = $true
            Write-Host "API está em execução!" -ForegroundColor Green
        }
    } catch {
        Write-Host "Aguardando API iniciar... ($retries/$maxRetries)" -ForegroundColor Yellow
    }
    
    try {
        $frontendResponse = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($frontendResponse.StatusCode -eq 200) {
            $frontendRunning = $true
            Write-Host "Frontend está em execução!" -ForegroundColor Green
        }
    } catch {
        Write-Host "Aguardando Frontend iniciar... ($retries/$maxRetries)" -ForegroundColor Yellow
    }
}

if (-not $apiRunning) {
    Write-Host "Falha ao iniciar a API. Verifique os logs: docker-compose logs api" -ForegroundColor Red
}

if (-not $frontendRunning) {
    Write-Host "Falha ao iniciar o Frontend. Verifique os logs: docker-compose logs frontend" -ForegroundColor Red
}

if ($apiRunning -and $frontendRunning) {
    Write-Host "Ambiente de desenvolvimento configurado com sucesso!" -ForegroundColor Green
    Write-Host "API: http://localhost:8080" -ForegroundColor Cyan
    Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
    
    # Abrir o navegador automaticamente
    Start-Process "http://localhost:3000"
} else {
    Write-Host "Falha na configuração do ambiente de desenvolvimento." -ForegroundColor Red
    exit 1
} 