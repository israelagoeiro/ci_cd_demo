# Script para criar issues no GitHub a partir dos arquivos de definições
# Este script lê as credenciais do arquivo .env

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

# Função para criar uma issue
function Create-GitHubIssue {
    param (
        [string]$title,
        [string]$body,
        [string[]]$labels
    )
    
    $url = "https://api.github.com/repos/$owner/$repo/issues"
    
    $headers = @{
        "Authorization" = "token $token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    $payload = @{
        title = $title
        body = $body
        labels = $labels
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $payload -ContentType "application/json"
        Write-Host "Issue criada com sucesso: $($response.html_url)" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "Erro ao criar issue: $_" -ForegroundColor Red
        return $null
    }
}

# Função para ler as definições de issues de um arquivo Markdown
function Read-IssueDefinitions {
    param (
        [string]$filePath
    )
    
    if (-not (Test-Path $filePath)) {
        Write-Host "Arquivo $filePath não encontrado." -ForegroundColor Red
        return @()
    }
    
    $content = Get-Content $filePath -Raw
    $issueBlocks = $content -split "## Issue \d+: "
    
    $issues = @()
    
    foreach ($block in $issueBlocks) {
        if ([string]::IsNullOrWhiteSpace($block) -or $block.StartsWith("# ")) {
            continue
        }
        
        $lines = $block -split "`n"
        $title = $lines[0].Trim()
        
        $bodyStart = $lines.IndexOf("**Descrição:**") + 1
        $bodyEnd = $lines.IndexOf("**Labels sugeridas:**") - 1
        
        if ($bodyStart -gt 0 -and $bodyEnd -gt $bodyStart) {
            $body = ($lines[$bodyStart..$bodyEnd] -join "`n").Trim()
            
            $labelsLine = $lines | Where-Object { $_ -match "^\*\*Labels sugeridas:\*\* (.+)$" }
            $labels = @()
            
            if ($labelsLine) {
                $labelsText = $labelsLine -replace "^\*\*Labels sugeridas:\*\* ", ""
                $labels = $labelsText -split ", " | ForEach-Object { $_.Trim() }
            }
            
            $issues += @{
                title = $title
                body = $body
                labels = $labels
            }
        }
    }
    
    return $issues
}

# Arquivos de definições de issues
$issueFiles = @(
    "../issues/backend-issues.md",
    "../issues/security-issues.md",
    "../issues/ux-advanced-issues.md",
    "../issues/devops-issues.md"
)

# Criar as issues
foreach ($file in $issueFiles) {
    Write-Host "Processando arquivo $file..." -ForegroundColor Cyan
    $issues = Read-IssueDefinitions -filePath $file
    
    foreach ($issue in $issues) {
        Write-Host "Criando issue: $($issue.title)" -ForegroundColor Yellow
        Create-GitHubIssue -title $issue.title -body $issue.body -labels $issue.labels
        
        # Aguardar um pouco para evitar rate limiting
        Start-Sleep -Seconds 2
    }
}

Write-Host "Todas as issues foram criadas com sucesso!" -ForegroundColor Green

# Atualizar a lista de tarefas
Write-Host "Atualizando a lista de tarefas..." -ForegroundColor Cyan
try {
    # Verificar se o script read-issues-and-create-tasks.ps1 existe
    if (Test-Path "read-issues-and-create-tasks.ps1") {
        & .\read-issues-and-create-tasks.ps1
        
        # Mover o arquivo para o diretório task
        Move-Item -Force tarefas-*.md ../task/
        
        Write-Host "Lista de tarefas atualizada com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Script read-issues-and-create-tasks.ps1 não encontrado. A lista de tarefas não foi atualizada." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erro ao atualizar a lista de tarefas: $_" -ForegroundColor Red
} 