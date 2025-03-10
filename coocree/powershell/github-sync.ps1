# Script para sincronizar workflows locais com GitHub Actions
param (
    [Parameter(Mandatory=$false)]
    [string]$githubRepo = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$push = $false
)

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  SINCRONIZAÇÃO COM GITHUB ACTIONS" -ForegroundColor Cyan
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

# Verificar se o diretório .github/workflows existe
if (-not (Test-Path ".github/workflows")) {
    Write-Host "Diretório .github/workflows não encontrado. Criando..." -ForegroundColor Yellow
    New-Item -Path ".github/workflows" -ItemType Directory -Force | Out-Null
}

# Verificar se os arquivos de workflow existem
$ciWorkflow = ".github/workflows/ci.yml"
$cdWorkflow = ".github/workflows/cd.yml"

if (-not (Test-Path $ciWorkflow) -or -not (Test-Path $cdWorkflow)) {
    Write-Host "Arquivos de workflow não encontrados. Criando..." -ForegroundColor Yellow
    
    # Criar workflow de CI
    if (-not (Test-Path $ciWorkflow)) {
        Write-Host "Criando workflow de CI..." -ForegroundColor Cyan
        $ciContent = @"
name: CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  workflow_dispatch:

jobs:
  test-api:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.21'
        cache: true
    
    - name: Install dependencies for API
      run: |
        cd api
        go mod download
    
    - name: Run tests for API
      run: |
        cd api
        go test -v ./...
  
  test-frontend:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.21'
        cache: true
    
    - name: Install dependencies for Frontend
      run: |
        cd frontend
        go mod download
    
    - name: Run tests for Frontend
      run: |
        cd frontend
        go test -v ./...
  
  build-images:
    runs-on: ubuntu-latest
    needs: [test-api, test-frontend]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Build API Docker image
      uses: docker/build-push-action@v4
      with:
        context: ./api
        push: false
        tags: ci-cd-demo-api:latest
        cache-from: type=gha
        cache-to: type=gha,mode=max
    
    - name: Build Frontend Docker image
      uses: docker/build-push-action@v4
      with:
        context: ./frontend
        push: false
        tags: ci-cd-demo-frontend:latest
        cache-from: type=gha
        cache-to: type=gha,mode=max
"@
        $ciContent | Out-File -FilePath $ciWorkflow -Encoding utf8
    }
    
    # Criar workflow de CD
    if (-not (Test-Path $cdWorkflow)) {
        Write-Host "Criando workflow de CD..." -ForegroundColor Cyan
        $cdContent = @"
name: CD Pipeline

on:
  push:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Ambiente para implantação'
        required: true
        default: 'dev'
        type: choice
        options:
        - dev
        - test
        - prod
      version:
        description: 'Versão para implantação (apenas para prod)'
        required: false
        default: 'latest'

jobs:
  deploy-dev:
    if: github.event.inputs.environment == 'dev' || (github.ref == 'refs/heads/develop' && github.event_name == 'push')
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: `${{ secrets.DOCKERHUB_USERNAME }}
        password: `${{ secrets.DOCKERHUB_TOKEN }}
    
    - name: Build and push API image
      uses: docker/build-push-action@v4
      with:
        context: ./api
        push: true
        tags: `${{ secrets.DOCKERHUB_USERNAME }}/ci-cd-demo-api:develop
    
    - name: Build and push Frontend image
      uses: docker/build-push-action@v4
      with:
        context: ./frontend
        push: true
        tags: `${{ secrets.DOCKERHUB_USERNAME }}/ci-cd-demo-frontend:develop
    
    - name: Deploy to Development Environment
      run: |
        echo "Deploying to development environment..."
        # Aqui você adicionaria comandos para deploy no ambiente de desenvolvimento
        # Por exemplo, usando SSH para acessar o servidor e executar docker-compose
  
  deploy-test:
    if: github.event.inputs.environment == 'test'
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: `${{ secrets.DOCKERHUB_USERNAME }}
        password: `${{ secrets.DOCKERHUB_TOKEN }}
    
    - name: Build and push API image
      uses: docker/build-push-action@v4
      with:
        context: ./api
        push: true
        tags: `${{ secrets.DOCKERHUB_USERNAME }}/ci-cd-demo-api:test
    
    - name: Build and push Frontend image
      uses: docker/build-push-action@v4
      with:
        context: ./frontend
        push: true
        tags: `${{ secrets.DOCKERHUB_USERNAME }}/ci-cd-demo-frontend:test
    
    - name: Deploy to Test Environment
      run: |
        echo "Deploying to test environment..."
        # Aqui você adicionaria comandos para deploy no ambiente de teste
  
  deploy-prod:
    if: github.event.inputs.environment == 'prod' || github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: `${{ secrets.DOCKERHUB_USERNAME }}
        password: `${{ secrets.DOCKERHUB_TOKEN }}
    
    - name: Set version tag
      id: set-version
      run: |
        if [ "`${{ github.event.inputs.version }}" != "" ] && [ "`${{ github.event.inputs.version }}" != "latest" ]; then
          echo "VERSION=`${{ github.event.inputs.version }}" >> `$GITHUB_OUTPUT
        else
          echo "VERSION=latest" >> `$GITHUB_OUTPUT
        fi
    
    - name: Build and push API image
      uses: docker/build-push-action@v4
      with:
        context: ./api
        push: true
        tags: `${{ secrets.DOCKERHUB_USERNAME }}/ci-cd-demo-api:`${{ steps.set-version.outputs.VERSION }}
    
    - name: Build and push Frontend image
      uses: docker/build-push-action@v4
      with:
        context: ./frontend
        push: true
        tags: `${{ secrets.DOCKERHUB_USERNAME }}/ci-cd-demo-frontend:`${{ steps.set-version.outputs.VERSION }}
    
    - name: Deploy to Production Environment
      run: |
        echo "Deploying to production environment with version `${{ steps.set-version.outputs.VERSION }}..."
        # Aqui você adicionaria comandos para deploy no ambiente de produção
"@
        $cdContent | Out-File -FilePath $cdWorkflow -Encoding utf8
    }
}

# Verificar se o repositório Git está inicializado
if (-not (Test-Path ".git")) {
    Write-Host "Repositório Git não inicializado. Inicializando..." -ForegroundColor Yellow
    Exec-Command -command "git init" -errorMessage "Falha ao inicializar repositório Git."
}

# Se o repositório GitHub não foi especificado, perguntar ao usuário
if (-not $githubRepo) {
    $githubRepo = Read-Host -Prompt "Digite o URL do repositório GitHub (ex: https://github.com/usuario/repo)"
}

# Verificar se o repositório remoto já está configurado
$remoteExists = git remote -v | Select-String -Pattern "origin" -Quiet

if (-not $remoteExists) {
    Write-Host "Configurando repositório remoto..." -ForegroundColor Yellow
    Exec-Command -command "git remote add origin $githubRepo" -errorMessage "Falha ao adicionar repositório remoto."
}

# Adicionar arquivos ao Git
Write-Host "Adicionando arquivos ao Git..." -ForegroundColor Cyan
Exec-Command -command "git add .github/workflows/" -errorMessage "Falha ao adicionar arquivos ao Git."

# Commit das alterações
Write-Host "Commitando alterações..." -ForegroundColor Cyan
Exec-Command -command "git commit -m 'Configuração de GitHub Actions para CI/CD'" -errorMessage "Falha ao commitar alterações."

# Push para o GitHub se solicitado
if ($push) {
    Write-Host "Enviando alterações para o GitHub..." -ForegroundColor Cyan
    Exec-Command -command "git push -u origin main" -errorMessage "Falha ao enviar alterações para o GitHub."
    
    Write-Host "`nWorkflows do GitHub Actions configurados e enviados com sucesso!" -ForegroundColor Green
    Write-Host "Acesse a aba 'Actions' no seu repositório GitHub para visualizar os workflows." -ForegroundColor Cyan
} else {
    Write-Host "`nWorkflows do GitHub Actions configurados com sucesso!" -ForegroundColor Green
    Write-Host "Para enviar as alterações para o GitHub, execute:" -ForegroundColor Cyan
    Write-Host "git push -u origin main" -ForegroundColor Yellow
    Write-Host "Ou execute este script novamente com o parâmetro -push" -ForegroundColor Yellow
}

Write-Host "`nPara que os workflows funcionem corretamente, configure os seguintes segredos no GitHub:" -ForegroundColor Cyan
Write-Host "1. DOCKERHUB_USERNAME: Seu nome de usuário do Docker Hub" -ForegroundColor Yellow
Write-Host "2. DOCKERHUB_TOKEN: Token de acesso ao Docker Hub" -ForegroundColor Yellow
Write-Host "`nPara configurar os segredos, acesse:" -ForegroundColor Cyan
Write-Host "$githubRepo/settings/secrets/actions" -ForegroundColor Yellow 