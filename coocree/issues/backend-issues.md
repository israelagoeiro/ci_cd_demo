# Issues de Backend para o GitHub

## Issue 1: Implementar endpoints para criar novas tarefas (POST)
**Título:** Implementar endpoints para criar novas tarefas (POST)
**Descrição:**
Atualmente, a API só suporta operações GET (listar tarefas) e DELETE (excluir tarefas). Precisamos implementar um endpoint POST para `/api/tarefas` que permita criar novas tarefas com os seguintes campos:

- ID (gerado automaticamente)
- Título da tarefa
- Status (concluída ou pendente)

O endpoint deve validar os dados recebidos, criar a tarefa no sistema e retornar a tarefa criada com status 201 (Created).

**Labels sugeridas:** enhancement, backend, api

## Issue 2: Implementar endpoints para atualizar tarefas (PUT/PATCH)
**Título:** Implementar endpoints para atualizar tarefas (PUT/PATCH)
**Descrição:**
Precisamos implementar um endpoint PUT ou PATCH para `/api/tarefas/{id}` que permita atualizar tarefas existentes. O endpoint deve:

- Validar se a tarefa existe
- Atualizar os campos fornecidos (título e/ou status)
- Retornar a tarefa atualizada com status 200 (OK)
- Retornar erro 404 se a tarefa não existir

Esta funcionalidade é necessária para suportar a edição de tarefas no frontend.

**Labels sugeridas:** enhancement, backend, api

## Issue 3: Implementar persistência de dados com banco de dados
**Título:** Implementar persistência de dados com banco de dados
**Descrição:**
Atualmente, as tarefas são armazenadas apenas em memória, o que significa que todos os dados são perdidos quando o servidor é reiniciado. Precisamos implementar persistência de dados usando um banco de dados.

Tarefas:
- Escolher um banco de dados adequado (SQLite para desenvolvimento, PostgreSQL para produção)
- Implementar conexão com o banco de dados
- Criar esquema de banco de dados para tarefas
- Modificar os handlers da API para usar o banco de dados em vez da memória
- Implementar migrações de banco de dados para facilitar atualizações futuras

**Labels sugeridas:** enhancement, backend, database

## Issue 4: Implementar validação de dados nas requisições
**Título:** Implementar validação de dados nas requisições
**Descrição:**
Atualmente, não há validação adequada dos dados recebidos nas requisições. Precisamos implementar validação para garantir que os dados estejam no formato correto e sejam válidos.

Tarefas:
- Implementar validação para o campo "título" (não vazio, tamanho máximo)
- Implementar validação para o campo "concluída" (booleano)
- Retornar mensagens de erro claras quando a validação falhar
- Implementar middleware de validação para reutilização em diferentes endpoints

**Labels sugeridas:** enhancement, backend, validation

## Issue 5: Implementar documentação da API com Swagger/OpenAPI
**Título:** Implementar documentação da API com Swagger/OpenAPI
**Descrição:**
Não há documentação da API, o que dificulta seu uso por outros desenvolvedores. Precisamos implementar documentação usando Swagger/OpenAPI.

Tarefas:
- Configurar Swagger/OpenAPI no projeto
- Documentar todos os endpoints existentes
- Incluir exemplos de requisição e resposta
- Disponibilizar interface interativa para testar a API
- Manter a documentação atualizada com as mudanças na API

**Labels sugeridas:** enhancement, backend, documentation 