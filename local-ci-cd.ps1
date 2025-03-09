param (
    [string]$workflow = "ci.yml",
    [string]$event = "push",
    [string]$branch = "develop"
)

Write-Host "Executando workflow $workflow com evento $event na branch $branch" -ForegroundColor Green

# Definir a branch atual para simular
$env:GITHUB_REF = "refs/heads/$branch"

# Executar o workflow
act $event -W .github/workflows/$workflow

# Limpar
Remove-Item Env:\GITHUB_REF 