# Script para criar issues no GitHub usando variáveis do arquivo .env
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

# Lista de issues para criar
$issues = @(
    @{
        title = "Implementar funcionalidade de adicionar novas tarefas"
        body = "Atualmente o frontend apenas exibe as tarefas existentes, mas não permite adicionar novas tarefas. Devemos implementar um formulário para adicionar novas tarefas com os seguintes campos:

- Título da tarefa
- Status (concluída ou pendente)

O formulário deve enviar os dados para a API e atualizar a lista de tarefas após o envio bem-sucedido."
        labels = @("enhancement", "frontend")
    },
    @{
        title = "Implementar funcionalidade de editar tarefas existentes"
        body = "Precisamos adicionar a capacidade de editar tarefas existentes. Ao clicar em uma tarefa, o usuário deve poder:

- Editar o título da tarefa
- Alterar o status (concluída/pendente)
- Salvar as alterações ou cancelar a edição

A API também precisará ser atualizada para suportar a edição de tarefas."
        labels = @("enhancement", "frontend")
    },
    @{
        title = "Implementar funcionalidade de excluir tarefas"
        body = "Adicionar a capacidade de excluir tarefas existentes. Cada tarefa deve ter um botão de exclusão que, quando clicado:

- Exibe uma confirmação para evitar exclusões acidentais
- Remove a tarefa da lista após confirmação
- Envia a solicitação de exclusão para a API"
        labels = @("enhancement", "frontend")
    },
    @{
        title = "Melhorar a responsividade do layout"
        body = "O layout atual precisa ser melhorado para funcionar bem em dispositivos móveis e telas de diferentes tamanhos. Devemos:

- Ajustar o CSS para usar unidades relativas (%, rem, em) em vez de pixels fixos
- Implementar media queries para diferentes tamanhos de tela
- Garantir que todos os elementos se ajustem corretamente em telas pequenas
- Testar em diferentes dispositivos e navegadores"
        labels = @("enhancement", "frontend", "UI/UX")
    },
    @{
        title = "Adicionar feedback visual para operações assíncronas"
        body = "Atualmente não há feedback visual quando o frontend está carregando dados da API ou realizando operações. Devemos adicionar:

- Indicadores de carregamento (spinners) durante a busca de dados
- Mensagens de sucesso após operações bem-sucedidas
- Mensagens de erro quando as operações falham
- Desabilitar botões durante operações em andamento para evitar cliques duplos"
        labels = @("enhancement", "frontend", "UX")
    },
    @{
        title = "Implementar testes de componentes"
        body = "Atualmente só temos um teste básico para o endpoint de saúde. Precisamos expandir a cobertura de testes para incluir:

- Testes para todos os componentes do frontend
- Testes de integração para as interações com a API
- Mocks para simular respostas da API
- Testes para cenários de erro e casos de borda"
        labels = @("enhancement", "testing", "frontend")
    },
    @{
        title = "Adicionar tema escuro (Dark Mode)"
        body = "Implementar um tema escuro para melhorar a experiência do usuário, especialmente em ambientes com pouca luz:

- Criar variáveis CSS para cores
- Implementar alternância entre tema claro e escuro
- Respeitar a preferência do sistema do usuário (prefers-color-scheme)
- Salvar a preferência do usuário no localStorage"
        labels = @("enhancement", "frontend", "UI/UX")
    },
    @{
        title = "Melhorar a estrutura do código"
        body = "O código atual tem toda a lógica no arquivo main.go. Devemos refatorar para uma estrutura mais organizada:

- Separar componentes em arquivos diferentes
- Criar pacotes para diferentes funcionalidades (API, UI, etc.)
- Implementar um gerenciamento de estado mais robusto
- Melhorar o tratamento de erros e logging"
        labels = @("enhancement", "refactoring", "frontend")
    }
)

# Criar as issues
Write-Host "Iniciando a criação de issues no GitHub..." -ForegroundColor Cyan
Write-Host "Repositório: $owner/$repo" -ForegroundColor Cyan
Write-Host "Total de issues a serem criadas: $($issues.Count)" -ForegroundColor Cyan
Write-Host ""

# Perguntar ao usuário se deseja continuar
$confirmation = Read-Host "Você está prestes a criar $($issues.Count) issues no repositório $owner/$repo. Continuar? (S/N)"
if ($confirmation -ne "S" -and $confirmation -ne "s") {
    Write-Host "Operação cancelada pelo usuário." -ForegroundColor Yellow
    exit 0
}

foreach ($issue in $issues) {
    Write-Host "Criando issue: $($issue.title)" -ForegroundColor Yellow
    $result = Create-GitHubIssue -title $issue.title -body $issue.body -labels $issue.labels
    
    if ($result -ne $null) {
        Write-Host "Issue criada com sucesso: $($result.html_url)" -ForegroundColor Green
    }
    
    # Pequena pausa para evitar limitação de taxa da API
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "Processo concluído!" -ForegroundColor Green 