# Script de automação do fluxo completo de CI/CD
param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "test", "prod")]
    [string]$targetEnvironment = "dev",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("api", "frontend", "all")]
    [string]$component = "all",
    
    [Parameter(Mandatory=$false)]
    [string]$version = "latest",
    
    [Parameter(Mandatory=$false)]
    [switch]$skipTests = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$skipBuild = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$skipDeploy = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$useGitHubActions = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$pushToGitHub = $false
)

$ErrorActionPreference = "Stop"
$startTime = Get-Date

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  INICIANDO FLUXO AUTOMATIZADO DE CI/CD" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Ambiente alvo: $targetEnvironment" -ForegroundColor Cyan
Write-Host "Componente: $component" -ForegroundColor Cyan
Write-Host "Versão: $version" -ForegroundColor Cyan
if ($useGitHubActions) {
    Write-Host "Modo: GitHub Actions" -ForegroundColor Cyan
} else {
    Write-Host "Modo: Local" -ForegroundColor Cyan
}
Write-Host "==================================================" -ForegroundColor Cyan

# Função para executar comandos com tratamento de erro
function Exec-Command {
    param (
        [string]$command,
        [string]$errorMessage
    )
    
    Write-Host "Executando: $command" -ForegroundColor DarkCyan
    try {
        Invoke-Expression $command
        if ($LASTEXITCODE -ne 0) {
            throw "Comando retornou código de erro: $LASTEXITCODE"
        }
    } catch {
        Write-Host $errorMessage -ForegroundColor Red
        Write-Host "Erro: $_" -ForegroundColor Red
        exit 1
    }
}

# Função para exibir o tempo decorrido
function Show-ElapsedTime {
    param (
        [DateTime]$startTime,
        [string]$stepName
    )
    
    $elapsedTime = (Get-Date) - $startTime
    $minutes = [math]::Floor($elapsedTime.TotalMinutes)
    $seconds = [math]::Floor($elapsedTime.TotalSeconds) % 60
    
    Write-Host "Tempo decorrido para $stepName: $minutes minutos e $seconds segundos" -ForegroundColor DarkGray
}

# Se estiver usando GitHub Actions, redirecionar para o script de integração
if ($useGitHubActions) {
    Write-Host "Redirecionando para o script de integração com GitHub Actions..." -ForegroundColor Cyan
    
    $integrationParams = @{
        environment = $targetEnvironment
        version = $version
    }
    
    if ($pushToGitHub) {
        $integrationParams.Add("triggerRemote", $true)
    }
    
    $paramString = ""
    foreach ($key in $integrationParams.Keys) {
        if ($integrationParams[$key] -is [bool] -or $integrationParams[$key] -is [switch]) {
            if ($integrationParams[$key]) {
                $paramString += " -$key"
            }
        } else {
            $paramString += " -$key `"$($integrationParams[$key])`""
        }
    }
    
    $command = ".\github-actions-integration.ps1$paramString"
    Exec-Command -command $command -errorMessage "Falha ao executar o script de integração com GitHub Actions."
    
    exit 0
}

# ETAPA 1: Configuração do ambiente de desenvolvimento
$step1Time = Get-Date
Write-Host "`n[ETAPA 1] Configurando ambiente de desenvolvimento..." -ForegroundColor Green

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
if ($component -eq "all" -or $component -eq "api") {
    Write-Host "Baixando dependências da API..." -ForegroundColor Cyan
    Push-Location api
    Exec-Command -command "go mod tidy" -errorMessage "Falha ao baixar dependências da API."
    Pop-Location
}

if ($component -eq "all" -or $component -eq "frontend") {
    Write-Host "Baixando dependências do Frontend..." -ForegroundColor Cyan
    Push-Location frontend
    Exec-Command -command "go mod tidy" -errorMessage "Falha ao baixar dependências do Frontend."
    Pop-Location
}

Show-ElapsedTime -startTime $step1Time -stepName "configuração do ambiente"

# ETAPA 2: Execução de testes
if (-not $skipTests) {
    $step2Time = Get-Date
    Write-Host "`n[ETAPA 2] Executando testes..." -ForegroundColor Green
    
    if ($component -eq "all" -or $component -eq "api") {
        Write-Host "Executando testes da API..." -ForegroundColor Cyan
        Push-Location api
        Exec-Command -command "go test -v ./..." -errorMessage "Falha nos testes da API."
        Pop-Location
    }
    
    if ($component -eq "all" -or $component -eq "frontend") {
        Write-Host "Executando testes do Frontend..." -ForegroundColor Cyan
        Push-Location frontend
        Exec-Command -command "go test -v ./..." -errorMessage "Falha nos testes do Frontend."
        Pop-Location
    }
    
    Show-ElapsedTime -startTime $step2Time -stepName "execução de testes"
} else {
    Write-Host "`n[ETAPA 2] Execução de testes ignorada." -ForegroundColor Yellow
}

# ETAPA 3: Construção de imagens Docker
if (-not $skipBuild) {
    $step3Time = Get-Date
    Write-Host "`n[ETAPA 3] Construindo imagens Docker..." -ForegroundColor Green
    
    # Construir imagens
    if ($component -eq "all") {
        Exec-Command -command "docker-compose build" -errorMessage "Falha ao construir imagens Docker."
    } else {
        Exec-Command -command "docker-compose build $component" -errorMessage "Falha ao construir imagem Docker para $component."
    }
    
    Show-ElapsedTime -startTime $step3Time -stepName "construção de imagens"
} else {
    Write-Host "`n[ETAPA 3] Construção de imagens ignorada." -ForegroundColor Yellow
}

# ETAPA 4: Implantação
if (-not $skipDeploy) {
    $step4Time = Get-Date
    Write-Host "`n[ETAPA 4] Implantando no ambiente $targetEnvironment..." -ForegroundColor Green
    
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
    $tag = switch ($targetEnvironment) {
        "dev" { "develop" }
        "test" { "test" }
        "prod" { $version }
    }
    
    # Login no Docker Hub
    Write-Host "Fazendo login no Docker Hub..." -ForegroundColor Cyan
    $loginCmd = "echo $env:DOCKERHUB_TOKEN | docker login --username $env:DOCKERHUB_USERNAME --password-stdin"
    Exec-Command -command $loginCmd -errorMessage "Falha ao fazer login no Docker Hub."
    
    # Marcar e enviar imagens
    if ($component -eq "all" -or $component -eq "api") {
        $apiImageName = "$env:DOCKERHUB_USERNAME/ci-cd-demo-api:$tag"
        Write-Host "Marcando e enviando imagem da API..." -ForegroundColor Cyan
        Exec-Command -command "docker tag ci-cd-demo-api:latest $apiImageName" -errorMessage "Falha ao marcar imagem da API."
        Exec-Command -command "docker push $apiImageName" -errorMessage "Falha ao enviar imagem da API para o Docker Hub."
    }
    
    if ($component -eq "all" -or $component -eq "frontend") {
        $frontendImageName = "$env:DOCKERHUB_USERNAME/ci-cd-demo-frontend:$tag"
        Write-Host "Marcando e enviando imagem do Frontend..." -ForegroundColor Cyan
        Exec-Command -command "docker tag ci-cd-demo-frontend:latest $frontendImageName" -errorMessage "Falha ao marcar imagem do Frontend."
        Exec-Command -command "docker push $frontendImageName" -errorMessage "Falha ao enviar imagem do Frontend para o Docker Hub."
    }
    
    # Criar arquivo docker-compose específico para o ambiente
    $composeFile = "docker-compose.$targetEnvironment.yml"
    
    Write-Host "Criando arquivo docker-compose para o ambiente $targetEnvironment..." -ForegroundColor Cyan
    
    # Criar o conteúdo do arquivo docker-compose
    $composeContent = "version: '3.8'`n`n"
    $composeContent += "services:`n"
    
    if ($component -eq "all" -or $component -eq "api") {
        $apiImageName = "$env:DOCKERHUB_USERNAME/ci-cd-demo-api:$tag"
        $composeContent += "  api:`n"
        $composeContent += "    image: $apiImageName`n"
        $composeContent += "    container_name: ci-cd-demo-api-$targetEnvironment`n"
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
    }
    
    if ($component -eq "all" -or $component -eq "frontend") {
        $frontendImageName = "$env:DOCKERHUB_USERNAME/ci-cd-demo-frontend:$tag"
        $composeContent += "  frontend:`n"
        $composeContent += "    image: $frontendImageName`n"
        $composeContent += "    container_name: ci-cd-demo-frontend-$targetEnvironment`n"
        $composeContent += "    ports:`n"
        $composeContent += "      - `"3000:3000`"`n"
        if ($component -eq "all") {
            $composeContent += "    depends_on:`n"
            $composeContent += "      - api`n"
        }
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
    }
    
    $composeContent += "networks:`n"
    $composeContent += "  ci-cd-network:`n"
    $composeContent += "    driver: bridge`n"
    
    # Escrever o conteúdo no arquivo
    $composeContent | Out-File -FilePath $composeFile -Encoding utf8
    
    # Implantar localmente para demonstração
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
        
        if ($component -eq "all" -or $component -eq "api") {
            try {
                $apiResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/health" -UseBasicParsing -ErrorAction SilentlyContinue
                if ($apiResponse.StatusCode -eq 200) {
                    $apiRunning = $true
                    Write-Host "API está em execução!" -ForegroundColor Green
                }
            } catch {
                Write-Host "Aguardando API iniciar... ($retries/$maxRetries)" -ForegroundColor Yellow
            }
        } else {
            $apiRunning = $true
        }
        
        if ($component -eq "all" -or $component -eq "frontend") {
            try {
                $frontendResponse = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -ErrorAction SilentlyContinue
                if ($frontendResponse.StatusCode -eq 200) {
                    $frontendRunning = $true
                    Write-Host "Frontend está em execução!" -ForegroundColor Green
                }
            } catch {
                Write-Host "Aguardando Frontend iniciar... ($retries/$maxRetries)" -ForegroundColor Yellow
            }
        } else {
            $frontendRunning = $true
        }
    }
    
    if (($component -eq "all" -and $apiRunning -and $frontendRunning) -or 
        ($component -eq "api" -and $apiRunning) -or 
        ($component -eq "frontend" -and $frontendRunning)) {
        Write-Host "Implantação para o ambiente $targetEnvironment concluída com sucesso!" -ForegroundColor Green
        
        if ($component -eq "all" -or $component -eq "api") {
            Write-Host "API: http://localhost:8080" -ForegroundColor Cyan
        }
        
        if ($component -eq "all" -or $component -eq "frontend") {
            Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
            # Abrir o navegador automaticamente
            Start-Process "http://localhost:3000"
        }
    } else {
        Write-Host "Falha na implantação para o ambiente $targetEnvironment." -ForegroundColor Red
        exit 1
    }
    
    Show-ElapsedTime -startTime $step4Time -stepName "implantação"
} else {
    Write-Host "`n[ETAPA 4] Implantação ignorada." -ForegroundColor Yellow
}

# Resumo final
$totalTime = (Get-Date) - $startTime
$totalMinutes = [math]::Floor($totalTime.TotalMinutes)
$totalSeconds = [math]::Floor($totalTime.TotalSeconds) % 60

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "  FLUXO DE CI/CD CONCLUÍDO COM SUCESSO" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Ambiente: $targetEnvironment" -ForegroundColor Cyan
Write-Host "Componente: $component" -ForegroundColor Cyan
Write-Host "Tempo total: $totalMinutes minutos e $totalSeconds segundos" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Sugestão para usar GitHub Actions
Write-Host "`nPara executar este fluxo usando GitHub Actions, execute:" -ForegroundColor Cyan
Write-Host ".\auto-cicd.ps1 -targetEnvironment $targetEnvironment -component $component -version $version -useGitHubActions -pushToGitHub" -ForegroundColor Yellow 