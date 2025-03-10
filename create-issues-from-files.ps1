# Script para criar issues no GitHub a partir dos arquivos de definições
# Você precisa gerar um token de acesso pessoal no GitHub com permissão para "repo"
# https://github.com/settings/tokens

# Configurações
$owner = "israelagoeiro" # Substitua pelo seu nome de usuário do GitHub
$repo = "ci_cd_demo" # Substitua pelo nome do seu repositório
$token = "" # Substitua pelo seu token de acesso pessoal do GitHub

# Verificar se o token foi fornecido
if ([string]::IsNullOrEmpty($token)) {
    # Tentar ler o token do arquivo .env
    if (Test-Path "../../.env") {
        $envContent = Get-Content "../../.env" -ErrorAction SilentlyContinue
        foreach ($line in $envContent) {
            if ($line -match "^\s*GITHUB_TOKEN\s*=\s*(.+)\s*$") {
                $token = $matches[1]
                break
            }
        }
    }
    
    # Se ainda estiver vazio, solicitar ao usuário
    if ([string]::IsNullOrEmpty($token)) {
        Write-Host "Por favor, edite este script e adicione seu token de acesso pessoal do GitHub." -ForegroundColor Red
        Write-Host "Você pode gerar um token em: https://github.com/settings/tokens" -ForegroundColor Yellow
        exit 1
    }
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
    # Backend Issues
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
    @{
        title = "Implementar validação de dados nas requisições"
        body = "Atualmente, não há validação adequada dos dados recebidos nas requisições. Precisamos implementar validação para garantir que os dados estejam no formato correto e sejam válidos.

Tarefas:
- Implementar validação para o campo 'título' (não vazio, tamanho máximo)
- Implementar validação para o campo 'concluída' (booleano)
- Retornar mensagens de erro claras quando a validação falhar
- Implementar middleware de validação para reutilização em diferentes endpoints"
        labels = @("enhancement", "backend", "validation")
    },
    @{
        title = "Implementar documentação da API com Swagger/OpenAPI"
        body = "Não há documentação da API, o que dificulta seu uso por outros desenvolvedores. Precisamos implementar documentação usando Swagger/OpenAPI.

Tarefas:
- Configurar Swagger/OpenAPI no projeto
- Documentar todos os endpoints existentes
- Incluir exemplos de requisição e resposta
- Disponibilizar interface interativa para testar a API
- Manter a documentação atualizada com as mudanças na API"
        labels = @("enhancement", "backend", "documentation")
    }
)

# Adicionar issues de segurança
$securityIssues = @(
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
    @{
        title = "Implementar proteção contra ataques comuns"
        body = "A aplicação precisa ser protegida contra ataques comuns da web para garantir a segurança dos dados dos usuários.

Tarefas:
- Implementar proteção contra Cross-Site Scripting (XSS)
- Implementar proteção contra Cross-Site Request Forgery (CSRF)
- Implementar proteção contra SQL Injection
- Implementar cabeçalhos de segurança (Content-Security-Policy, X-XSS-Protection, etc.)
- Implementar HTTPS em todos os ambientes"
        labels = @("enhancement", "security")
    }
)

# Adicionar issues de UX e funcionalidades avançadas
$uxIssues = @(
    @{
        title = "Implementar filtros e ordenação de tarefas"
        body = "Atualmente, a aplicação exibe todas as tarefas sem opção de filtrar ou ordenar. Precisamos implementar funcionalidades para melhorar a organização e visualização das tarefas.

Tarefas:
- Implementar filtros por status (concluídas, pendentes, todas)
- Implementar ordenação por título (A-Z, Z-A)
- Implementar ordenação por data de criação (mais recentes, mais antigas)
- Implementar pesquisa por texto no título da tarefa
- Atualizar a API para suportar parâmetros de filtro e ordenação
- Atualizar o frontend para incluir controles de filtro e ordenação"
        labels = @("enhancement", "frontend", "UX")
    },
    @{
        title = "Implementar sistema de categorização de tarefas"
        body = "Para melhorar a organização das tarefas, precisamos implementar um sistema de categorias ou tags.

Tarefas:
- Adicionar campo de categoria/tag às tarefas
- Implementar CRUD de categorias
- Permitir atribuir múltiplas categorias a uma tarefa
- Implementar filtro por categoria
- Implementar visualização de tarefas agrupadas por categoria
- Atualizar a API e o frontend para suportar categorias"
        labels = @("enhancement", "frontend", "backend")
    }
)

# Adicionar issues de DevOps
$devopsIssues = @(
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

# Combinar todas as issues
$issues += $securityIssues
$issues += $uxIssues
$issues += $devopsIssues

# Criar as issues
Write-Host "Iniciando a criação de issues no GitHub..." -ForegroundColor Cyan
Write-Host "Repositório: $owner/$repo" -ForegroundColor Cyan
Write-Host "Total de issues a serem criadas: $($issues.Count)" -ForegroundColor Cyan
Write-Host ""

foreach ($issue in $issues) {
    Write-Host "Criando issue: $($issue.title)" -ForegroundColor Yellow
    $result = Create-GitHubIssue -title $issue.title -body $issue.body -labels $issue.labels
    
    if ($result -ne $null) {
        Write-Host "Issue criada com sucesso: $($result.html_url)" -ForegroundColor Green
    }
    
    # Pequena pausa para evitar limitação de taxa da API
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "Processo concluído!" -ForegroundColor Green

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