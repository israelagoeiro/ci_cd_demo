# Configuração de Variáveis de Ambiente

Este projeto utiliza um arquivo `.env` para armazenar informações sensíveis como tokens, senhas e configurações específicas do ambiente. Este arquivo **não deve ser commitado** no repositório Git por razões de segurança.

## Configuração Inicial

1. Copie o arquivo `.env.example` para criar seu próprio arquivo `.env`:

```bash
cp .env.example .env
```

2. Edite o arquivo `.env` e preencha com suas informações:

```
# GitHub
GITHUB_TOKEN=seu_token_aqui
GITHUB_OWNER=seu_usuario_github
GITHUB_REPO=nome_do_repositorio

# Docker Hub
DOCKERHUB_USERNAME=seu_usuario_dockerhub
DOCKERHUB_TOKEN=seu_token_dockerhub

# Outras configurações...
```

## Obtenção de Tokens

### GitHub Token

1. Acesse https://github.com/settings/tokens
2. Clique em "Generate new token" (Generate new token (classic))
3. Dê um nome ao token (por exemplo, "CI/CD Demo Issues")
4. Selecione o escopo "repo" para permitir acesso completo ao repositório
5. Clique em "Generate token"
6. Copie o token gerado e adicione-o ao arquivo `.env`

### Docker Hub Token

1. Acesse https://hub.docker.com/settings/security
2. Clique em "New Access Token"
3. Dê um nome ao token e selecione as permissões necessárias
4. Clique em "Generate"
5. Copie o token gerado e adicione-o ao arquivo `.env`

## Uso nos Scripts

Os scripts do projeto foram configurados para ler as variáveis do arquivo `.env`. Por exemplo, o script `create-issues-env.ps1` usa as variáveis `GITHUB_TOKEN`, `GITHUB_OWNER` e `GITHUB_REPO` para criar issues no GitHub.

## Segurança

- **Nunca** comite o arquivo `.env` no Git
- **Nunca** compartilhe seus tokens ou senhas
- Revogue tokens que não são mais necessários
- Use tokens com o mínimo de permissões necessárias
- Considere usar tokens com expiração para maior segurança

## Solução de Problemas

Se você encontrar erros relacionados a variáveis de ambiente:

1. Verifique se o arquivo `.env` existe na raiz do projeto
2. Verifique se as variáveis necessárias estão definidas no arquivo `.env`
3. Verifique se os tokens são válidos e não expiraram
4. Verifique se os tokens têm as permissões necessárias 