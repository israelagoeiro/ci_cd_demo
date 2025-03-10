# Script para fechar uma issue específica no GitHub
param (
    [Parameter(Mandatory=$false)]
    [int]$issueNumber = 0
)

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  FECHAMENTO DE ISSUE NO GITHUB" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Função para ler o arquivo .env
function Get-EnvVariable {
    param (
        [string]$name,
        [string]$default = ""
    )
    
    # Verificar se o arquivo .env existe
    if (-not (Test-Path ".env")) {
        Write-Host "Arquivo .env não encontrado. Crie o arquivo .env baseado no .env.example." -ForegroundColor Red
        exit 1
    }
    
    # Ler o arquivo .env
    $envContent = Get-Content ".env" -ErrorAction SilentlyContinue
    
    # Procurar pela variável
    foreach ($line in $envContent) {
        if ($line -match "^\s*$name\s*=\s*(.+)\s*$") {
            return $matches[1]
        }
    }
    
    # Retornar o valor padrão se a variável não for encontrada
    return $default
}

# Obter as configurações do arquivo .env
$token = Get-EnvVariable "GITHUB_TOKEN"
$owner = Get-EnvVariable "GITHUB_OWNER"
$repo = Get-EnvVariable "GITHUB_REPO"

# Verificar se as variáveis obrigatórias estão definidas
if ([string]::IsNullOrEmpty($token)) {
    Write-Host "Token do GitHub não encontrado no arquivo .env. Adicione GITHUB_TOKEN=seu_token_aqui ao arquivo .env." -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrEmpty($owner)) {
    Write-Host "Proprietário do repositório não encontrado no arquivo .env. Adicione GITHUB_OWNER=seu_usuario_github ao arquivo .env." -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrEmpty($repo)) {
    Write-Host "Nome do repositório não encontrado no arquivo .env. Adicione GITHUB_REPO=nome_do_repositorio ao arquivo .env." -ForegroundColor Red
    exit 1
}

# Solicitar o número da issue se não foi fornecido como parâmetro
if ($issueNumber -eq 0) {
    $issueNumber = Read-Host "Digite o número da issue que deseja fechar"
    if (-not [int]::TryParse($issueNumber, [ref]$null)) {
        Write-Host "Número de issue inválido." -ForegroundColor Red
        exit 1
    }
}

# Função para fechar uma issue no GitHub
function Close-GitHubIssue {
    param (
        [int]$issueNumber
    )
    
    $url = "https://api.github.com/repos/$owner/$repo/issues/$issueNumber"
    
    $headers = @{
        "Authorization" = "token $token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    $payload = @{
        state = "closed"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Patch -Headers $headers -Body $payload -ContentType "application/json"
        Write-Host "Issue #$issueNumber fechada com sucesso: $($response.html_url)" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "Erro ao fechar issue: $_" -ForegroundColor Red
        return $null
    }
}

# Fechar a issue
Write-Host "Fechando issue #$issueNumber no repositório $owner/$repo..." -ForegroundColor Cyan
$result = Close-GitHubIssue -issueNumber $issueNumber

if ($result -ne $null) {
    Write-Host "Issue fechada com sucesso!" -ForegroundColor Green
    Write-Host "Título: $($result.title)" -ForegroundColor Cyan
    Write-Host "URL: $($result.html_url)" -ForegroundColor Cyan
} else {
    Write-Host "Falha ao fechar a issue." -ForegroundColor Red
    exit 1
}

# Atualizar a lista de tarefas
Write-Host "Atualizando a lista de tarefas..." -ForegroundColor Cyan
try {
    # Verificar se o script read-issues-and-create-tasks.ps1 existe
    if (Test-Path "read-issues-and-create-tasks.ps1") {
        & .\read-issues-and-create-tasks.ps1
        Write-Host "Lista de tarefas atualizada com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Script read-issues-and-create-tasks.ps1 não encontrado. A lista de tarefas não foi atualizada." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erro ao atualizar a lista de tarefas: $_" -ForegroundColor Red
} 