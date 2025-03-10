# Script de automação de implantação
param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "test", "prod")]
    [string]$environment,
    
    [Parameter(Mandatory=$false)]
    [string]$version = "latest"
)

# Configurações
$dockerHubUsername = $env:DOCKERHUB_USERNAME
if (-not $dockerHubUsername) {
    $dockerHubUsername = Read-Host -Prompt "Digite seu nome de usuário do Docker Hub"
    $env:DOCKERHUB_USERNAME = $dockerHubUsername
}

$dockerHubToken = $env:DOCKERHUB_TOKEN
if (-not $dockerHubToken) {
    $dockerHubToken = Read-Host -Prompt "Digite seu token do Docker Hub" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($dockerHubToken)
    $env:DOCKERHUB_TOKEN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

# Definir tag com base no ambiente
$tag = switch ($environment) {
    "dev" { "develop" }
    "test" { "test" }
    "prod" { $version }
}

Write-Host "Iniciando implantação para o ambiente $environment (tag: $tag)..." -ForegroundColor Green

# Função para executar comandos com tratamento de erro
function Exec-Command {
    param (
        [string]$command,
        [string]$errorMessage
    )
    
    Write-Host "Executando: $command" -ForegroundColor Cyan
    Invoke-Expression $command
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host $errorMessage -ForegroundColor Red
        exit 1
    }
}

# Login no Docker Hub
Write-Host "Fazendo login no Docker Hub..." -ForegroundColor Cyan
$loginCmd = "echo $env:DOCKERHUB_TOKEN | docker login --username $env:DOCKERHUB_USERNAME --password-stdin"
Exec-Command -command $loginCmd -errorMessage "Falha ao fazer login no Docker Hub."

# Construir imagens
Write-Host "Construindo imagens Docker..." -ForegroundColor Cyan
Exec-Command -command "docker-compose build" -errorMessage "Falha ao construir imagens Docker."

# Marcar imagens com tags apropriadas
$apiImageName = "$env:DOCKERHUB_USERNAME/ci-cd-demo-api:$tag"
$frontendImageName = "$env:DOCKERHUB_USERNAME/ci-cd-demo-frontend:$tag"

Write-Host "Marcando imagens com tags apropriadas..." -ForegroundColor Cyan
Exec-Command -command "docker tag ci-cd-demo-api:latest $apiImageName" -errorMessage "Falha ao marcar imagem da API."
Exec-Command -command "docker tag ci-cd-demo-frontend:latest $frontendImageName" -errorMessage "Falha ao marcar imagem do Frontend."

# Enviar imagens para o Docker Hub
Write-Host "Enviando imagens para o Docker Hub..." -ForegroundColor Cyan
Exec-Command -command "docker push $apiImageName" -errorMessage "Falha ao enviar imagem da API para o Docker Hub."
Exec-Command -command "docker push $frontendImageName" -errorMessage "Falha ao enviar imagem do Frontend para o Docker Hub."

# Criar arquivo docker-compose específico para o ambiente
$composeFile = "docker-compose.$environment.yml"

Write-Host "Criando arquivo docker-compose para o ambiente $environment..." -ForegroundColor Cyan

# Criar o conteúdo do arquivo docker-compose
$composeContent = "version: '3.8'`n`n"
$composeContent += "services:`n"
$composeContent += "  api:`n"
$composeContent += "    image: $apiImageName`n"
$composeContent += "    container_name: ci-cd-demo-api-$environment`n"
$composeContent += "    ports:`n"
$composeContent += "      - `"8080:8080`"`n"
$composeContent += "    networks:`n"
$composeContent += "      - ci-cd-network`n"
$composeContent += "    restart: always`n"
$composeContent += "    healthcheck:`n"
$composeContent += "      test: [`"CMD`", `"curl`", `"-f`", `"http://localhost:8080/api/health`"]`n"
$composeContent += "      interval: 30s`n"
$composeContent += "      timeout: 10s`n"
$composeContent += "      retries: 3`n"
$composeContent += "      start_period: 10s`n`n"
$composeContent += "  frontend:`n"
$composeContent += "    image: $frontendImageName`n"
$composeContent += "    container_name: ci-cd-demo-frontend-$environment`n"
$composeContent += "    ports:`n"
$composeContent += "      - `"3000:3000`"`n"
$composeContent += "    depends_on:`n"
$composeContent += "      - api`n"
$composeContent += "    environment:`n"
$composeContent += "      - API_URL=http://api:8080`n"
$composeContent += "    networks:`n"
$composeContent += "      - ci-cd-network`n"
$composeContent += "    restart: always`n"
$composeContent += "    healthcheck:`n"
$composeContent += "      test: [`"CMD`", `"curl`", `"-f`", `"http://localhost:3000/health`"]`n"
$composeContent += "      interval: 30s`n"
$composeContent += "      timeout: 10s`n"
$composeContent += "      retries: 3`n"
$composeContent += "      start_period: 10s`n`n"
$composeContent += "networks:`n"
$composeContent += "  ci-cd-network:`n"
$composeContent += "    driver: bridge`n"

# Escrever o conteúdo no arquivo
$composeContent | Out-File -FilePath $composeFile -Encoding utf8

# Simular implantação em servidor remoto
Write-Host "Simulando implantação em servidor remoto para o ambiente $environment..." -ForegroundColor Cyan

# Em um cenário real, você usaria SSH para se conectar ao servidor e executar comandos
# Por exemplo:
# ssh user@server "mkdir -p /opt/ci-cd-demo/$environment"
# scp $composeFile user@server:/opt/ci-cd-demo/$environment/docker-compose.yml
# ssh user@server "cd /opt/ci-cd-demo/$environment && docker-compose pull && docker-compose up -d"

# Para fins de demonstração, vamos apenas simular a implantação localmente
Write-Host "Implantando localmente para demonstração..." -ForegroundColor Yellow
Exec-Command -command "docker-compose -f $composeFile up -d" -errorMessage "Falha ao implantar serviços localmente."

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

if ($apiRunning -and $frontendRunning) {
    Write-Host "Implantação para o ambiente $environment concluída com sucesso!" -ForegroundColor Green
    Write-Host "API: http://localhost:8080" -ForegroundColor Cyan
    Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
    
    # Abrir o navegador automaticamente
    Start-Process "http://localhost:3000"
} else {
    Write-Host "Falha na implantação para o ambiente $environment." -ForegroundColor Red
    exit 1
} 