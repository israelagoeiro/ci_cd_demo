# Script para ler as issues do GitHub e criar uma lista de tarefas
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

# Função para obter as issues do GitHub
function Get-GitHubIssues {
    param (
        [string]$owner,
        [string]$repo,
        [string]$token,
        [string]$state = "open"
    )
    
    $url = "https://api.github.com/repos/$owner/$repo/issues?state=$state"
    
    $headers = @{
        "Authorization" = "token $token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers
        return $response
    }
    catch {
        Write-Host "Erro ao obter issues: $_" -ForegroundColor Red
        return $null
    }
}

# Função para criar um arquivo Markdown com a lista de tarefas
function Create-TaskList {
    param (
        [array]$issues,
        [string]$outputFile = "tarefas.md"
    )
    
    # Criar o conteúdo do arquivo Markdown
    $content = "# Lista de Tarefas do Projeto $repo`n`n"
    $content += "Este documento foi gerado automaticamente a partir das issues do GitHub em $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss').`n`n"
    
    # Agrupar issues por labels
    $groupedIssues = @{}
    
    foreach ($issue in $issues) {
        $labels = $issue.labels.name -join ", "
        if (-not $groupedIssues.ContainsKey($labels)) {
            $groupedIssues[$labels] = @()
        }
        $groupedIssues[$labels] += $issue
    }
    
    # Adicionar as issues agrupadas por labels
    foreach ($labelGroup in $groupedIssues.Keys) {
        $content += "## Categoria: $labelGroup`n`n"
        
        foreach ($issue in $groupedIssues[$labelGroup]) {
            $content += "### $($issue.title) (Issue #$($issue.number))`n`n"
            $content += "$($issue.body)`n`n"
            $content += "**Link:** $($issue.html_url)`n`n"
            $content += "**Tarefas:**`n"
            
            # Extrair tarefas do corpo da issue (linhas que começam com '- ')
            $tasks = $issue.body -split "`r?`n" | Where-Object { $_ -match '^\s*-\s+' }
            
            foreach ($task in $tasks) {
                $taskText = $task -replace '^\s*-\s+', ''
                $content += "- [ ] $taskText`n"
            }
            
            $content += "`n---`n`n"
        }
    }
    
    # Salvar o conteúdo no arquivo
    $content | Out-File -FilePath $outputFile -Encoding utf8
    
    Write-Host "Lista de tarefas criada com sucesso em $outputFile" -ForegroundColor Green
    return $outputFile
}

# Obter as issues do GitHub
Write-Host "Obtendo issues do repositório $owner/$repo..." -ForegroundColor Cyan
$issues = Get-GitHubIssues -owner $owner -repo $repo -token $token -state "open"

if ($issues -eq $null -or $issues.Count -eq 0) {
    Write-Host "Nenhuma issue encontrada." -ForegroundColor Yellow
    exit 0
}

Write-Host "Encontradas $($issues.Count) issues." -ForegroundColor Green

# Criar a lista de tarefas
$outputFile = "tarefas-$(Get-Date -Format 'yyyyMMdd').md"
Create-TaskList -issues $issues -outputFile $outputFile

# Abrir o arquivo no navegador padrão
Invoke-Item $outputFile 