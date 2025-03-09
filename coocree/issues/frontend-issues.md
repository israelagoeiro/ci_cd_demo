# Melhorias para o Frontend - Issues para o GitHub

## Issue 1: Implementar funcionalidade de adicionar novas tarefas
**Título:** Implementar funcionalidade de adicionar novas tarefas
**Descrição:**
Atualmente o frontend apenas exibe as tarefas existentes, mas não permite adicionar novas tarefas. Devemos implementar um formulário para adicionar novas tarefas com os seguintes campos:

- Título da tarefa
- Status (concluída ou pendente)

O formulário deve enviar os dados para a API e atualizar a lista de tarefas após o envio bem-sucedido.

**Labels sugeridas:** enhancement, frontend

## Issue 2: Implementar funcionalidade de editar tarefas existentes
**Título:** Implementar funcionalidade de editar tarefas existentes
**Descrição:**
Precisamos adicionar a capacidade de editar tarefas existentes. Ao clicar em uma tarefa, o usuário deve poder:

- Editar o título da tarefa
- Alterar o status (concluída/pendente)
- Salvar as alterações ou cancelar a edição

A API também precisará ser atualizada para suportar a edição de tarefas.

**Labels sugeridas:** enhancement, frontend

## Issue 3: Implementar funcionalidade de excluir tarefas
**Título:** Implementar funcionalidade de excluir tarefas
**Descrição:**
Adicionar a capacidade de excluir tarefas existentes. Cada tarefa deve ter um botão de exclusão que, quando clicado:

- Exibe uma confirmação para evitar exclusões acidentais
- Remove a tarefa da lista após confirmação
- Envia a solicitação de exclusão para a API

**Labels sugeridas:** enhancement, frontend

## Issue 4: Melhorar a responsividade do layout
**Título:** Melhorar a responsividade do layout
**Descrição:**
O layout atual precisa ser melhorado para funcionar bem em dispositivos móveis e telas de diferentes tamanhos. Devemos:

- Ajustar o CSS para usar unidades relativas (%, rem, em) em vez de pixels fixos
- Implementar media queries para diferentes tamanhos de tela
- Garantir que todos os elementos se ajustem corretamente em telas pequenas
- Testar em diferentes dispositivos e navegadores

**Labels sugeridas:** enhancement, frontend, UI/UX

## Issue 5: Adicionar feedback visual para operações assíncronas
**Título:** Adicionar feedback visual para operações assíncronas
**Descrição:**
Atualmente não há feedback visual quando o frontend está carregando dados da API ou realizando operações. Devemos adicionar:

- Indicadores de carregamento (spinners) durante a busca de dados
- Mensagens de sucesso após operações bem-sucedidas
- Mensagens de erro quando as operações falham
- Desabilitar botões durante operações em andamento para evitar cliques duplos

**Labels sugeridas:** enhancement, frontend, UX

## Issue 6: Implementar testes de componentes
**Título:** Implementar testes de componentes
**Descrição:**
Atualmente só temos um teste básico para o endpoint de saúde. Precisamos expandir a cobertura de testes para incluir:

- Testes para todos os componentes do frontend
- Testes de integração para as interações com a API
- Mocks para simular respostas da API
- Testes para cenários de erro e casos de borda

**Labels sugeridas:** enhancement, testing, frontend

## Issue 7: Adicionar tema escuro (Dark Mode)
**Título:** Adicionar tema escuro (Dark Mode)
**Descrição:**
Implementar um tema escuro para melhorar a experiência do usuário, especialmente em ambientes com pouca luz:

- Criar variáveis CSS para cores
- Implementar alternância entre tema claro e escuro
- Respeitar a preferência do sistema do usuário (prefers-color-scheme)
- Salvar a preferência do usuário no localStorage

**Labels sugeridas:** enhancement, frontend, UI/UX

## Issue 8: Melhorar a estrutura do código
**Título:** Melhorar a estrutura do código
**Descrição:**
O código atual tem toda a lógica no arquivo main.go. Devemos refatorar para uma estrutura mais organizada:

- Separar componentes em arquivos diferentes
- Criar pacotes para diferentes funcionalidades (API, UI, etc.)
- Implementar um gerenciamento de estado mais robusto
- Melhorar o tratamento de erros e logging

**Labels sugeridas:** enhancement, refactoring, frontend 