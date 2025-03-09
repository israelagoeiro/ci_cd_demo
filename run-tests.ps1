# Script de automação de testes
param (
    [switch]$api,
    [switch]$frontend,
    [switch]$all = $true
)

# Se api ou frontend for especificado, desativar all
if ($api -or $frontend) {
    $all = $false
}

# Função para executar testes
function Run-Tests {
    param (
        [string]$component,
        [string]$directory
    )
    
    Write-Host "Executando testes para $component..." -ForegroundColor Cyan
    
    # Mudar para o diretório do componente
    Push-Location $directory
    
    # Executar testes
    go test -v ./...
    $testResult = $LASTEXITCODE
    
    # Voltar ao diretório anterior
    Pop-Location
    
    # Verificar resultado
    if ($testResult -eq 0) {
        Write-Host "Testes para $component concluídos com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Falha nos testes para $component." -ForegroundColor Red
        return $false
    }
    
    return $true
}

# Inicializar variáveis de resultado
$apiSuccess = $true
$frontendSuccess = $true

# Executar testes da API
if ($all -or $api) {
    $apiSuccess = Run-Tests -component "API" -directory "api"
}

# Executar testes do Frontend
if ($all -or $frontend) {
    $frontendSuccess = Run-Tests -component "Frontend" -directory "frontend"
}

# Verificar resultados gerais
if ($apiSuccess -and $frontendSuccess) {
    Write-Host "Todos os testes foram concluídos com sucesso!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Alguns testes falharam. Verifique os logs acima." -ForegroundColor Red
    exit 1
} 