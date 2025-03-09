// Elementos do DOM
const modal = document.getElementById('modal-confirmacao');
const btnConfirmar = document.getElementById('btn-confirmar');
const btnCancelar = document.getElementById('btn-cancelar');
const botoesExcluir = document.querySelectorAll('.btn-excluir');
const themeToggle = document.getElementById('theme-toggle');
const themeToggleText = document.getElementById('theme-toggle-text');

// ID da tarefa a ser excluída
let tarefaIdParaExcluir = null;

// Função para obter a URL da API
function getApiUrl() {
    // Tentar obter do localStorage (caso tenha sido definido anteriormente)
    const savedApiUrl = localStorage.getItem('apiUrl');
    if (savedApiUrl) {
        return savedApiUrl;
    }
    
    // Caso contrário, usar o padrão
    return 'http://localhost:8080';
}

// Função para gerenciar o tema
function setupThemeToggle() {
    // Verificar se há uma preferência salva
    const savedTheme = localStorage.getItem('theme');
    const prefersDarkScheme = window.matchMedia('(prefers-color-scheme: dark)');
    
    // Aplicar tema salvo ou usar preferência do sistema
    if (savedTheme) {
        document.documentElement.setAttribute('data-theme', savedTheme);
        updateThemeToggleText(savedTheme);
    } else if (prefersDarkScheme.matches) {
        document.documentElement.setAttribute('data-theme', 'dark');
        updateThemeToggleText('dark');
    }
    
    // Adicionar event listener para o botão de alternância de tema
    themeToggle.addEventListener('click', () => {
        const currentTheme = document.documentElement.getAttribute('data-theme');
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        
        // Atualizar o tema
        document.documentElement.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
        updateThemeToggleText(newTheme);
    });
}

// Função para atualizar o texto do botão de alternância de tema
function updateThemeToggleText(theme) {
    if (theme === 'dark') {
        themeToggleText.innerHTML = '☀️ Modo Claro';
    } else {
        themeToggleText.innerHTML = '🌙 Modo Escuro';
    }
}

// Função para mostrar o modal de confirmação
function mostrarModal(id) {
    tarefaIdParaExcluir = id;
    modal.classList.add('ativo');
}

// Função para esconder o modal de confirmação
function esconderModal() {
    modal.classList.remove('ativo');
    tarefaIdParaExcluir = null;
}

// Função para excluir uma tarefa
async function excluirTarefa(id) {
    try {
        const apiUrl = getApiUrl();
        const response = await fetch(`${apiUrl}/api/tarefas/${id}`, {
            method: 'DELETE',
        });
        
        if (!response.ok) {
            throw new Error('Erro ao excluir tarefa');
        }
        
        // Remover a tarefa do DOM
        const tarefa = document.querySelector(`.tarefa[data-id="${id}"]`);
        if (tarefa) {
            tarefa.remove();
        }
        
        // Verificar se ainda existem tarefas
        const tarefas = document.querySelectorAll('.tarefa');
        if (tarefas.length === 0) {
            const tarefasContainer = document.querySelector('.tarefas-container');
            const semTarefas = document.createElement('p');
            semTarefas.className = 'sem-tarefas';
            semTarefas.textContent = 'Nenhuma tarefa encontrada.';
            tarefasContainer.appendChild(semTarefas);
        }
    } catch (error) {
        console.error('Erro ao excluir tarefa:', error);
        alert('Não foi possível excluir a tarefa. Tente novamente mais tarde.');
    }
}

// Inicializar o gerenciamento de tema
document.addEventListener('DOMContentLoaded', () => {
    setupThemeToggle();
});

// Adicionar event listeners aos botões de excluir
botoesExcluir.forEach(botao => {
    botao.addEventListener('click', (e) => {
        e.preventDefault();
        const id = botao.getAttribute('data-id');
        mostrarModal(id);
    });
});

// Event listener para o botão de confirmar exclusão
btnConfirmar.addEventListener('click', () => {
    if (tarefaIdParaExcluir) {
        excluirTarefa(tarefaIdParaExcluir);
        esconderModal();
    }
});

// Event listener para o botão de cancelar exclusão
btnCancelar.addEventListener('click', esconderModal);

// Fechar o modal ao clicar fora dele
window.addEventListener('click', (e) => {
    if (e.target === modal) {
        esconderModal();
    }
}); 