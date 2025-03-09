# Demonstração de CI/CD com Go

Este projeto é uma demonstração de implementação de CI/CD para aplicações Go, utilizando Docker e GitHub Actions. O projeto consiste em duas aplicações:

1. **API REST em Go**: Um servidor backend simples que fornece dados de tarefas.
2. **Frontend em Go/Fiber**: Uma aplicação web que consome a API e renderiza os dados usando templates Mustache.

## Estrutura do Projeto

```
ci-cd-demo/
│
├── api/                    # Servidor API REST em Go
│   ├── main.go             # Código principal da API
│   ├── main_test.go        # Testes da API
│   ├── go.mod              # Dependências da API
│   └── Dockerfile          # Dockerfile para a API
│
├── frontend/               # Aplicação frontend em Go/Fiber
│   ├── main.go             # Código principal do frontend
│   ├── main_test.go        # Testes do frontend
│   ├── go.mod              # Dependências do frontend
│   ├── Dockerfile          # Dockerfile para o frontend
│   ├── views/              # Templates Mustache
│   │   └── index.mustache  # Template da página inicial
│   └── public/             # Arquivos estáticos
│       └── css/            # Estilos CSS
│           └── styles.css  # Arquivo de estilos
│
├── .github/                # Configurações do GitHub
│   └── workflows/          # Workflows do GitHub Actions
│       ├── ci.yml          # Workflow de Integração Contínua
│       └── cd.yml          # Workflow de Entrega Contínua
│
├── docker-compose.yml      # Configuração do Docker Compose
├── dev-env-setup.ps1       # Script para configuração do ambiente de desenvolvimento
├── run-tests.ps1           # Script para execução de testes
├── ci.ps1                  # Script para automação de integração contínua
├── deploy.ps1              # Script para automação de implantação
├── auto-cicd.ps1           # Script para automação completa do fluxo de CI/CD
├── github-sync.ps1         # Script para sincronizar workflows com GitHub
├── github-actions-integration.ps1 # Script para integração com GitHub Actions
└── local-ci-cd.ps1         # Script PowerShell para execução local de workflows
```

## Pré-requisitos

- Go 1.21 ou superior
- Docker e Docker Compose
- Git
- Act (para execução local de GitHub Actions)
- GitHub CLI (para integração com GitHub Actions)
- PowerShell 5.1 ou superior

## Scripts de Automação

Este projeto inclui vários scripts PowerShell para automatizar todo o processo de desenvolvimento, teste e implantação:

### 1. Configuração do Ambiente de Desenvolvimento

```powershell
.\dev-env-setup.ps1
```

Este script automatiza:
- Verificação e inicialização do Docker
- Download de dependências
- Construção e inicialização dos contêineres
- Verificação da saúde dos serviços
- Abertura automática do navegador

### 2. Execução de Testes

```powershell
# Executar todos os testes
.\run-tests.ps1

# Executar apenas testes da API
.\run-tests.ps1 -api

# Executar apenas testes do Frontend
.\run-tests.ps1 -frontend
```

### 3. Integração Contínua

```powershell
# Executar CI completo na branch develop
.\ci.ps1

# Executar CI apenas para a API na branch main
.\ci.ps1 -component api -branch main

# Executar CI apenas para o Frontend
.\ci.ps1 -component frontend
```

### 4. Implantação

```powershell
# Implantar no ambiente de desenvolvimento
.\deploy.ps1 -environment dev

# Implantar no ambiente de teste
.\deploy.ps1 -environment test

# Implantar no ambiente de produção com versão específica
.\deploy.ps1 -environment prod -version 1.0.0
```

### 5. Automação Completa do Fluxo de CI/CD

```powershell
# Executar o fluxo completo de CI/CD para o ambiente de desenvolvimento
.\auto-cicd.ps1

# Executar o fluxo completo para o ambiente de produção com versão específica
.\auto-cicd.ps1 -targetEnvironment prod -version 1.0.0

# Executar apenas para o componente API, pulando testes
.\auto-cicd.ps1 -component api -skipTests

# Executar apenas para o componente Frontend, pulando a implantação
.\auto-cicd.ps1 -component frontend -skipDeploy

# Executar apenas a construção de imagens para o ambiente de teste
.\auto-cicd.ps1 -targetEnvironment test -skipTests -skipDeploy
```

O script `auto-cicd.ps1` automatiza todo o fluxo de CI/CD em uma única execução:

1. **Configuração do ambiente**: Verifica e inicia o Docker, baixa dependências
2. **Execução de testes**: Executa testes automatizados para os componentes selecionados
3. **Construção de imagens**: Constrói imagens Docker para os componentes selecionados
4. **Implantação**: Marca, envia e implanta as imagens no ambiente selecionado

Cada etapa pode ser ignorada usando os parâmetros `-skipTests`, `-skipBuild` e `-skipDeploy`.

### 6. Integração com GitHub Actions

```powershell
# Sincronizar workflows com GitHub
.\github-sync.ps1 -githubRepo "https://github.com/seu-usuario/seu-repo"

# Sincronizar e enviar para o GitHub
.\github-sync.ps1 -githubRepo "https://github.com/seu-usuario/seu-repo" -push

# Integrar com GitHub Actions sem acionar workflow
.\github-actions-integration.ps1 -environment prod -version 1.0.0

# Integrar com GitHub Actions e acionar workflow remotamente
.\github-actions-integration.ps1 -environment prod -version 1.0.0 -triggerRemote

# Executar o fluxo completo usando GitHub Actions
.\auto-cicd.ps1 -targetEnvironment prod -version 1.0.0 -useGitHubActions -pushToGitHub
```

A integração com GitHub Actions permite:

1. **Sincronização de Workflows**: Cria e atualiza os arquivos de workflow do GitHub Actions
2. **Execução Remota**: Aciona workflows remotamente usando GitHub CLI
3. **Modo Híbrido**: Executa testes localmente e implanta usando GitHub Actions

## Modos de Execução

### Modo Desenvolvimento

Para configurar e iniciar o ambiente de desenvolvimento automaticamente:

```powershell
.\dev-env-setup.ps1
```

### Modo Teste

Para executar os testes automaticamente:

```powershell
.\run-tests.ps1
```

Para executar os workflows de CI/CD localmente:

```powershell
# Executar o workflow de CI
.\ci.ps1

# Executar o workflow de CD
.\deploy.ps1 -environment dev
```

### Modo Operação (Produção)

Para implantar em produção:

```powershell
.\deploy.ps1 -environment prod
```

Ou para executar o fluxo completo de CI/CD para produção:

```powershell
.\auto-cicd.ps1 -targetEnvironment prod -version 1.0.0
```

Para implantar usando GitHub Actions:

```powershell
.\auto-cicd.ps1 -targetEnvironment prod -version 1.0.0 -useGitHubActions -pushToGitHub
```

## Fluxo de CI/CD

1. **Integração Contínua (CI)**:
   - Execução de testes automatizados
   - Verificação de qualidade de código
   - Construção de imagens Docker

2. **Entrega Contínua (CD)**:
   - Publicação de imagens Docker
   - Implantação em ambiente de desenvolvimento (branch `develop`)
   - Implantação em ambiente de produção (branch `main`)

## Configuração de Segredos

Para que os workflows funcionem corretamente, é necessário configurar os seguintes segredos:

- `DOCKERHUB_USERNAME`: Seu nome de usuário no Docker Hub
- `DOCKERHUB_TOKEN`: Token de acesso ao Docker Hub

Você pode configurá-los como variáveis de ambiente ou serão solicitados durante a execução dos scripts.

Para GitHub Actions, configure esses segredos no repositório GitHub:
1. Acesse seu repositório no GitHub
2. Vá para "Settings" > "Secrets and variables" > "Actions"
3. Clique em "New repository secret"
4. Adicione os segredos `DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN`

## Acionamento Automático de Workflows

Os workflows do GitHub Actions são acionados automaticamente nos seguintes eventos:

- **CI Pipeline**: Acionado em push para as branches `main` e `develop`, pull requests para essas branches, ou manualmente
- **CD Pipeline**: Acionado em push para a branch `main` ou manualmente com seleção de ambiente e versão

Para acionar manualmente um workflow no GitHub:
1. Acesse seu repositório no GitHub
2. Vá para a aba "Actions"
3. Selecione o workflow desejado
4. Clique em "Run workflow"
5. Selecione a branch e os parâmetros desejados
6. Clique em "Run workflow" 