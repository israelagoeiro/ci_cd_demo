# Script de automação de integração contínua
param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("api", "frontend", "all")]
    [string]$component = "all",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("develop", "main")]
    [string]$branch = "develop"
)

Write-Host "Iniciando processo de integração contínua para $component na branch $branch..." -ForegroundColor Green

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

# Definir a branch atual para simular
$env:GITHUB_REF = "refs/heads/$branch"

# Verificar se o Act está instalado
try {
    $actVersion = act --version
    Write-Host "Act encontrado: $actVersion" -ForegroundColor Green
} catch {
    Write-Host "Act não encontrado. Instalando..." -ForegroundColor Yellow
    
    # Verificar se o Chocolatey está instalado
    try {
        $chocoVersion = choco --version
        Write-Host "Chocolatey encontrado: $chocoVersion" -ForegroundColor Green
        
        # Instalar Act usando Chocolatey
        Exec-Command -command "choco install act-cli -y" -errorMessage "Falha ao instalar Act."
    } catch {
        Write-Host "Chocolatey não encontrado. Por favor, instale o Chocolatey e tente novamente." -ForegroundColor Red
        Write-Host "Instruções: https://chocolatey.org/install" -ForegroundColor Yellow
        exit 1
    }
}

# Executar testes locais antes de iniciar o CI
Write-Host "Executando testes locais antes de iniciar o CI..." -ForegroundColor Cyan

if ($component -eq "all" -or $component -eq "api") {
    Write-Host "Executando testes da API..." -ForegroundColor Cyan
    Push-Location api
    go test -v ./...
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Falha nos testes da API. Corrigindo os problemas antes de continuar." -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Pop-Location
}

if ($component -eq "all" -or $component -eq "frontend") {
    Write-Host "Executando testes do Frontend..." -ForegroundColor Cyan
    Push-Location frontend
    go test -v ./...
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Falha nos testes do Frontend. Corrigindo os problemas antes de continuar." -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Pop-Location
}

# Executar o workflow de CI
Write-Host "Executando workflow de CI com Act..." -ForegroundColor Cyan

if ($component -eq "all") {
    # Executar todo o workflow de CI
    Exec-Command -command "act push -W .github/workflows/ci.yml" -errorMessage "Falha ao executar o workflow de CI."
} else {
    # Executar apenas o job específico
    $job = "test-$component"
    Exec-Command -command "act push -W .github/workflows/ci.yml -j $job" -errorMessage "Falha ao executar o job $job."
}

# Limpar
Remove-Item Env:\GITHUB_REF

Write-Host "Processo de integração contínua concluído com sucesso!" -ForegroundColor Green 