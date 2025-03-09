# Manual de Execução da Aplicação com Docker

Este manual descreve como iniciar o Docker e executar a aplicação CI/CD Demo localmente.

## Pré-requisitos

- Docker Desktop instalado
- PowerShell
- Git (para clonar o repositório)
- Go (para desenvolvimento local sem Docker)

## 1. Iniciando o Docker

### Método Automático (usando o script)

O script `dev-env-setup.ps1` verifica se o Docker está em execução e o inicia automaticamente se necessário:

1. Abra o PowerShell como administrador
2. Navegue até o diretório do projeto
3. Execute o script:

```powershell
.\dev-env-setup.ps1
```

### Método Manual

Se preferir iniciar o Docker manualmente:

1. Procure por "Docker Desktop" no menu Iniciar
2. Clique para iniciar o Docker Desktop
3. Aguarde até que o ícone do Docker na barra de tarefas indique que está pronto (sem animação)

## 2. Executando a Aplicação

### Usando o Script de Configuração do Ambiente

O script `dev-env-setup.ps1` configura todo o ambiente de desenvolvimento:

1. Inicia o Docker (se necessário)
2. Baixa as dependências da API e do Frontend
3. Constrói e inicia os contêineres Docker
4. Verifica se os serviços estão em execução
5. Abre o navegador com a aplicação

Para executar:

```powershell
.\dev-env-setup.ps1
```

### Usando o Script de Teste Local

O script `run-local-test.ps1` é mais focado em testes:

1. Verifica se o Docker está em execução
2. Para contêineres existentes (se houver)
3. Constrói e inicia os contêineres
4. Verifica se os serviços estão em execução
5. Abre o navegador com a aplicação

Para executar:

```powershell
.\run-local-test.ps1
```

### Usando Docker Compose Diretamente

Se preferir usar os comandos Docker diretamente:

1. Para construir e iniciar os contêineres:

```powershell
docker-compose up --build -d
```

2. Para verificar os logs:

```powershell
docker-compose logs
```

3. Para parar os contêineres:

```powershell
docker-compose down
```

## 3. Verificando se a Aplicação está Funcionando

Após iniciar a aplicação, você pode verificar se está funcionando corretamente:

1. Frontend: http://localhost:3000
2. API: http://localhost:8080/api/tarefas
3. Verificação de saúde da API: http://localhost:8080/api/health
4. Verificação de saúde do Frontend: http://localhost:3000/health

## 4. Executando CI/CD Local

Para testar o pipeline de CI/CD localmente:

1. Certifique-se de que o Docker está em execução
2. Execute o script `local-ci-cd.ps1`:

```powershell
.\local-ci-cd.ps1 -workflow "ci.yml" -event "push" -branch "develop"
```

Parâmetros:
- `workflow`: Nome do arquivo de workflow (padrão: "ci.yml")
- `event`: Evento do GitHub a ser simulado (padrão: "push")
- `branch`: Branch a ser simulada (padrão: "develop")

## 5. Solução de Problemas

### Docker não inicia

Se o Docker não iniciar automaticamente:
1. Verifique se o Docker Desktop está instalado
2. Inicie o Docker Desktop manualmente
3. Verifique se o serviço Docker está em execução nos Serviços do Windows

### Contêineres não iniciam

Se os contêineres não iniciarem:
1. Verifique os logs: `docker-compose logs`
2. Verifique se as portas 8080 e 3000 não estão sendo usadas por outros aplicativos
3. Tente parar e reiniciar os contêineres: `docker-compose down` seguido de `docker-compose up -d`

### Problemas com o PowerShell

Se encontrar erros relacionados ao operador `&&` no PowerShell:
1. Use o ponto e vírgula (`;`) como separador de comandos em vez de `&&`
2. Exemplo: `cd api; go run main.go` em vez de `cd api && go run main.go`

## 6. Comandos Úteis

- Listar contêineres em execução: `docker ps`
- Ver logs da API: `docker-compose logs api`
- Ver logs do Frontend: `docker-compose logs frontend`
- Reiniciar um contêiner específico: `docker-compose restart api` ou `docker-compose restart frontend`
- Entrar em um contêiner: `docker exec -it ci-cd-demo-api bash` ou `docker exec -it ci-cd-demo-frontend bash` 