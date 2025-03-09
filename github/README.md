# Script para Recuperar Issues do GitHub

Este script em Go recupera todas as issues do repositório GitHub especificado no arquivo `.env`.

## Requisitos

- Go 1.16 ou superior
- Arquivo `.env` com as seguintes variáveis:
  - `GITHUB_TOKEN`: Token de acesso pessoal do GitHub
  - `GITHUB_OWNER`: Nome do usuário ou organização do GitHub
  - `GITHUB_REPO`: Nome do repositório

## Como usar

1. Certifique-se de que o arquivo `.env` está configurado corretamente
2. Execute o script:

```bash
go run get_issues.go
```

Ou use o executável compilado:

```bash
./get_issues.exe
```

## Funcionalidades

- Recupera todas as issues do repositório (abertas e fechadas)
- Exibe informações detalhadas sobre cada issue:
  - Número e título
  - Estado (aberta ou fechada)
  - Data de criação
  - URL
  - Labels
- Salva todas as issues em um arquivo JSON para processamento posterior

## Estrutura do código

- `Issue`: Estrutura que representa uma issue do GitHub
- `Label`: Estrutura que representa uma etiqueta de issue
- `getEnvVariable()`: Função para ler variáveis do arquivo `.env`
- `main()`: Função principal que recupera e exibe as issues

## Exemplo de saída

```
Encontradas 30 issues no repositório israelagoeiro/ci_cd_demo:

Issue #30: Melhorar a estrutura do código
Estado: open
Criada em: 09/03/2025 18:38:04
URL: https://github.com/israelagoeiro/ci_cd_demo/issues/30
Labels: enhancement, frontend, refactoring
---
... 