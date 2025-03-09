# Script para integrar o fluxo de CI/CD local com GitHub Actions
param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "test", "prod")]
    [string]$environment = "dev",
    
    [Parameter(Mandatory=$false)]
    [string]$version = "latest",
    
    [Parameter(Mandatory=$false)]
    [switch]$triggerRemote = $false
)

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  INTEGRAÇÃO COM GITHUB ACTIONS" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Ambiente: $environment" -ForegroundColor Cyan
Write-Host "Versão: $version" -ForegroundColor Cyan
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

# Verificar se o repositório Git está inicializado
if (-not (Test-Path ".git")) {
    Write-Host "Repositório Git não inicializado. Execute o script github-sync.ps1 primeiro." -ForegroundColor Red
    exit 1
}

# Verificar se os arquivos de workflow existem
$ciWorkflow = ".github/workflows/ci.yml"
$cdWorkflow = ".github/workflows/cd.yml"

if (-not (Test-Path $ciWorkflow) -or -not (Test-Path $cdWorkflow)) {
    Write-Host "Arquivos de workflow não encontrados. Execute o script github-sync.ps1 primeiro." -ForegroundColor Red
    exit 1
}

# Verificar se há alterações não commitadas
$status = git status --porcelain
if ($status) {
    Write-Host "Existem alterações não commitadas no repositório:" -ForegroundColor Yellow
    Write-Host $status -ForegroundColor Yellow
    
    $commitChanges = Read-Host "Deseja commitar essas alterações antes de continuar? (S/N)"
    if ($commitChanges -eq "S" -or $commitChanges -eq "s") {
        $commitMessage = Read-Host "Digite a mensagem do commit"
        Exec-Command -command "git add ." -errorMessage "Falha ao adicionar arquivos ao Git."
        Exec-Command -command "git commit -m `"$commitMessage`"" -errorMessage "Falha ao commitar alterações."
    } else {
        Write-Host "Continuando sem commitar alterações..." -ForegroundColor Yellow
    }
}

# Determinar a branch atual
$currentBranch = git branch --show-current
Write-Host "Branch atual: $currentBranch" -ForegroundColor Cyan

# Determinar a branch de destino com base no ambiente
$targetBranch = switch ($environment) {
    "dev" { "develop" }
    "test" { "develop" }
    "prod" { "main" }
}

# Verificar se a branch atual é diferente da branch de destino
if ($currentBranch -ne $targetBranch) {
    Write-Host "A branch atual ($currentBranch) é diferente da branch de destino ($targetBranch) para o ambiente $environment." -ForegroundColor Yellow
    
    # Verificar se a branch de destino existe
    $branchExists = git branch --list $targetBranch
    if (-not $branchExists) {
        Write-Host "A branch $targetBranch não existe. Criando..." -ForegroundColor Yellow
        Exec-Command -command "git checkout -b $targetBranch" -errorMessage "Falha ao criar a branch $targetBranch."
    } else {
        $switchBranch = Read-Host "Deseja mudar para a branch $targetBranch? (S/N)"
        if ($switchBranch -eq "S" -or $switchBranch -eq "s") {
            Exec-Command -command "git checkout $targetBranch" -errorMessage "Falha ao mudar para a branch $targetBranch."
        } else {
            Write-Host "Continuando na branch atual..." -ForegroundColor Yellow
            Write-Host "AVISO: Isso pode causar problemas se você estiver tentando implantar em um ambiente que espera uma branch específica." -ForegroundColor Red
        }
    }
}

# Verificar se há alterações para enviar
$localCommits = git log origin/$currentBranch..$currentBranch --oneline 2>$null
if ($localCommits) {
    Write-Host "Existem commits locais que não foram enviados para o repositório remoto:" -ForegroundColor Yellow
    Write-Host $localCommits -ForegroundColor Yellow
    
    $pushChanges = Read-Host "Deseja enviar esses commits para o repositório remoto? (S/N)"
    if ($pushChanges -eq "S" -or $pushChanges -eq "s") {
        Exec-Command -command "git push origin $currentBranch" -errorMessage "Falha ao enviar commits para o repositório remoto."
    } else {
        Write-Host "Continuando sem enviar commits..." -ForegroundColor Yellow
        Write-Host "AVISO: O GitHub Actions só será acionado quando os commits forem enviados para o repositório remoto." -ForegroundColor Red
    }
}

# Se solicitado, acionar o workflow remotamente
if ($triggerRemote) {
    # Verificar se o GitHub CLI está instalado
    $ghInstalled = $null
    try {
        $ghInstalled = gh --version
    } catch {
        Write-Host "GitHub CLI não encontrado. Instalando..." -ForegroundColor Yellow
        
        # Verificar se o Chocolatey está instalado
        try {
            $chocoVersion = choco --version
            Write-Host "Chocolatey encontrado: $chocoVersion" -ForegroundColor Green
            
            # Instalar GitHub CLI usando Chocolatey
            Exec-Command -command "choco install gh -y" -errorMessage "Falha ao instalar GitHub CLI."
        } catch {
            Write-Host "Chocolatey não encontrado. Por favor, instale o GitHub CLI manualmente:" -ForegroundColor Red
            Write-Host "https://cli.github.com/manual/installation" -ForegroundColor Yellow
            Write-Host "Após a instalação, execute este script novamente." -ForegroundColor Yellow
            exit 1
        }
    }
    
    # Verificar se o usuário está autenticado no GitHub CLI
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Você não está autenticado no GitHub CLI. Autenticando..." -ForegroundColor Yellow
        Exec-Command -command "gh auth login" -errorMessage "Falha ao autenticar no GitHub CLI."
    }
    
    # Acionar o workflow de CD remotamente
    Write-Host "Acionando workflow de CD remotamente para o ambiente $environment..." -ForegroundColor Cyan
    
    $workflowCommand = "gh workflow run cd.yml"
    if ($environment -eq "prod") {
        $workflowCommand += " --ref main"
    } else {
        $workflowCommand += " --ref develop"
    }
    
    $workflowCommand += " -f environment=$environment"
    
    if ($environment -eq "prod" -and $version -ne "latest") {
        $workflowCommand += " -f version=$version"
    }
    
    Exec-Command -command $workflowCommand -errorMessage "Falha ao acionar workflow remotamente."
    
    Write-Host "`nWorkflow de CD acionado com sucesso!" -ForegroundColor Green
    Write-Host "Você pode acompanhar o progresso na aba 'Actions' do seu repositório GitHub." -ForegroundColor Cyan
} else {
    Write-Host "`nPara acionar o workflow remotamente, execute este script com o parâmetro -triggerRemote" -ForegroundColor Cyan
    Write-Host "Exemplo: .\github-actions-integration.ps1 -environment prod -version 1.0.0 -triggerRemote" -ForegroundColor Yellow
    
    Write-Host "`nAlternativamente, você pode acionar o workflow manualmente no GitHub:" -ForegroundColor Cyan
    Write-Host "1. Acesse a aba 'Actions' do seu repositório" -ForegroundColor Yellow
    Write-Host "2. Selecione o workflow 'CD Pipeline'" -ForegroundColor Yellow
    Write-Host "3. Clique em 'Run workflow'" -ForegroundColor Yellow
    Write-Host "4. Selecione o ambiente e a versão (se aplicável)" -ForegroundColor Yellow
    Write-Host "5. Clique em 'Run workflow'" -ForegroundColor Yellow
}

Write-Host "`nPara verificar o status da implantação, você pode usar o GitHub CLI:" -ForegroundColor Cyan
Write-Host "gh run list --workflow=cd.yml" -ForegroundColor Yellow 