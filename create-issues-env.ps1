# Script para criar issues no GitHub
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
    # Novas issues de backend
    @{
        title = "Implementar endpoints para criar novas tarefas (POST)"
        body = "Atualmente, a API só suporta operações GET (listar tarefas) e DELETE (excluir tarefas). Precisamos implementar um endpoint POST para `/api/tarefas` que permita criar novas tarefas com os seguintes campos:

- ID (gerado automaticamente)
- Título da tarefa
- Status (concluída ou pendente)

O endpoint deve validar os dados recebidos, criar a tarefa no sistema e retornar a tarefa criada com status 201 (Created)."
        labels = @("enhancement", "backend", "api")
    },
    @{
        title = "Implementar endpoints para atualizar tarefas (PUT/PATCH)"
        body = "Precisamos implementar um endpoint PUT ou PATCH para `/api/tarefas/{id}` que permita atualizar tarefas existentes. O endpoint deve:

- Validar se a tarefa existe
- Atualizar os campos fornecidos (título e/ou status)
- Retornar a tarefa atualizada com status 200 (OK)
- Retornar erro 404 se a tarefa não existir

Esta funcionalidade é necessária para suportar a edição de tarefas no frontend."
        labels = @("enhancement", "backend", "api")
    },
    @{
        title = "Implementar persistência de dados com banco de dados"
        body = "Atualmente, as tarefas são armazenadas apenas em memória, o que significa que todos os dados são perdidos quando o servidor é reiniciado. Precisamos implementar persistência de dados usando um banco de dados.

Tarefas:
- Escolher um banco de dados adequado (SQLite para desenvolvimento, PostgreSQL para produção)
- Implementar conexão com o banco de dados
- Criar esquema de banco de dados para tarefas
- Modificar os handlers da API para usar o banco de dados em vez da memória
- Implementar migrações de banco de dados para facilitar atualizações futuras"
        labels = @("enhancement", "backend", "database")
    },
    
    # Novas issues de segurança
    @{
        title = "Implementar sistema de autenticação de usuários"
        body = "Atualmente, a aplicação não possui sistema de autenticação, o que significa que qualquer pessoa pode acessar todas as tarefas. Precisamos implementar um sistema de autenticação para proteger os dados dos usuários.

Tarefas:
- Implementar registro de usuários (nome, email, senha)
- Implementar login com JWT (JSON Web Tokens)
- Implementar logout e renovação de tokens
- Implementar recuperação de senha
- Associar tarefas a usuários específicos
- Atualizar a API para verificar autenticação em todas as rotas"
        labels = @("enhancement", "security", "authentication")
    },
    @{
        title = "Implementar autorização baseada em funções"
        body = "Além da autenticação, precisamos implementar um sistema de autorização para controlar o que cada usuário pode fazer na aplicação.

Tarefas:
- Definir funções de usuário (usuário comum, administrador)
- Implementar middleware de autorização
- Garantir que usuários só possam acessar suas próprias tarefas
- Permitir que administradores acessem todas as tarefas
- Implementar verificações de autorização em todos os endpoints relevantes"
        labels = @("enhancement", "security", "authorization")
    },
    
    # Novas issues de DevOps
    @{
        title = "Implementar monitoramento e logging estruturado"
        body = "Para garantir a confiabilidade e facilitar a depuração da aplicação, precisamos implementar um sistema de monitoramento e logging estruturado.

Tarefas:
- Implementar logging estruturado em JSON
- Configurar níveis de log apropriados (debug, info, warn, error)
- Implementar correlação de logs entre serviços
- Configurar agregação de logs (ELK Stack ou similar)
- Implementar dashboards de monitoramento
- Configurar alertas para erros e problemas de desempenho"
        labels = @("enhancement", "devops", "monitoring")
    },
    @{
        title = "Implementar estratégia de backup e recuperação de dados"
        body = "Para proteger os dados da aplicação, precisamos implementar uma estratégia robusta de backup e recuperação.

Tarefas:
- Definir política de backup (frequência, retenção)
- Implementar backups automáticos do banco de dados
- Configurar armazenamento seguro para backups
- Implementar e testar procedimentos de recuperação
- Documentar o processo de backup e recuperação
- Implementar monitoramento de backups"
        labels = @("enhancement", "devops", "backup")
    }
)

# Criar as issues
Write-Host "Iniciando a criação de issues no GitHub..." -ForegroundColor Cyan
Write-Host "Repositório: $owner/$repo" -ForegroundColor Cyan
Write-Host "Total de issues a serem criadas: $($issues.Count)" -ForegroundColor Cyan
Write-Host ""

# Solicitar confirmação
$confirmacao = Read-Host "Você está prestes a criar $($issues.Count) issues no repositório $owner/$repo. Continuar? (S/N)"
if ($confirmacao -ne "S" -and $confirmacao -ne "s") {
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