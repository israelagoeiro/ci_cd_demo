/**
 * HRISELINK - Sistema de Gerenciamento de RH
 * Arquivo JavaScript principal
 */

document.addEventListener('DOMContentLoaded', function() {
    // Inicialização do aplicativo
    initApp();
});

/**
 * Inicializa o aplicativo
 */
function initApp() {
    // Inicializa os componentes da interface
    initSidebar();
    initTabs();
    initTableActions();
    initPagination();
    
    // Adiciona dados de exemplo se necessário
    if (document.querySelector('.no-data')) {
        loadSampleData();
    }
}

/**
 * Inicializa a funcionalidade da barra lateral
 */
function initSidebar() {
    // Manipuladores de eventos para itens do menu
    const menuItems = document.querySelectorAll('.menu-item');
    
    menuItems.forEach(item => {
        item.addEventListener('click', function() {
            // Remove a classe 'active' de todos os itens
            menuItems.forEach(i => i.classList.remove('active'));
            
            // Adiciona a classe 'active' ao item clicado
            this.classList.add('active');
            
            // Verifica se o item tem um submenu (tem o ícone chevron)
            const chevron = this.querySelector('.chevron');
            if (chevron) {
                // Alterna a rotação do ícone chevron
                if (chevron.textContent === 'expand_more') {
                    chevron.textContent = 'expand_less';
                } else {
                    chevron.textContent = 'expand_more';
                }
                
                // Aqui poderia expandir/colapsar um submenu
                // Por enquanto, apenas simulamos a mudança de página
                updatePageTitle(this.querySelector('span:nth-child(2)').textContent);
            } else {
                // Simula a mudança de página
                updatePageTitle(this.querySelector('span:nth-child(2)').textContent);
            }
        });
    });
}

/**
 * Inicializa a funcionalidade das abas
 */
function initTabs() {
    const tabs = document.querySelectorAll('.tab');
    
    tabs.forEach(tab => {
        tab.addEventListener('click', function() {
            // Remove a classe 'active' de todas as abas
            tabs.forEach(t => t.classList.remove('active'));
            
            // Adiciona a classe 'active' à aba clicada
            this.classList.add('active');
            
            // Aqui poderia filtrar os dados da tabela com base na aba selecionada
            filterTableByTab(this.textContent);
        });
    });
}

/**
 * Inicializa as ações da tabela
 */
function initTableActions() {
    // Checkbox principal (no cabeçalho da tabela)
    const headerCheckbox = document.querySelector('thead .checkbox');
    if (headerCheckbox) {
        headerCheckbox.addEventListener('change', function() {
            // Seleciona ou desmarca todos os checkboxes da tabela
            const checkboxes = document.querySelectorAll('tbody .checkbox');
            checkboxes.forEach(checkbox => {
                checkbox.checked = this.checked;
            });
            
            // Adiciona ou remove a classe 'selected' das linhas
            const rows = document.querySelectorAll('tbody tr');
            rows.forEach(row => {
                if (this.checked) {
                    row.classList.add('selected');
                } else {
                    row.classList.remove('selected');
                }
            });
        });
    }
    
    // Checkboxes individuais
    const rowCheckboxes = document.querySelectorAll('tbody .checkbox');
    rowCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            const row = this.closest('tr');
            if (this.checked) {
                row.classList.add('selected');
            } else {
                row.classList.remove('selected');
                
                // Desmarca o checkbox principal se algum checkbox individual for desmarcado
                if (headerCheckbox) {
                    headerCheckbox.checked = false;
                }
            }
            
            // Verifica se todos os checkboxes estão marcados
            const allChecked = Array.from(rowCheckboxes).every(cb => cb.checked);
            if (headerCheckbox && allChecked) {
                headerCheckbox.checked = true;
            }
        });
    });
    
    // Menus de ação
    const actionMenus = document.querySelectorAll('.action-menu');
    actionMenus.forEach(menu => {
        menu.addEventListener('click', function(e) {
            e.stopPropagation();
            
            // Aqui poderia abrir um menu dropdown com ações
            // Por enquanto, apenas mostramos um alerta
            const row = this.closest('tr');
            const name = row.querySelector('.employee-name')?.textContent || 'Funcionário';
            alert(`Ações para ${name}`);
        });
    });
}

/**
 * Inicializa a funcionalidade de paginação
 */
function initPagination() {
    const pageBtns = document.querySelectorAll('.page-btn');
    
    pageBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            // Ignora se for um botão de navegação (anterior/próximo)
            if (this.classList.contains('nav-btn')) {
                // Aqui implementaria a navegação entre páginas
                return;
            }
            
            // Remove a classe 'active' de todos os botões
            pageBtns.forEach(b => b.classList.remove('active'));
            
            // Adiciona a classe 'active' ao botão clicado
            this.classList.add('active');
            
            // Aqui carregaria os dados da página selecionada
            // Por enquanto, apenas atualizamos o indicador de registros
            document.querySelector('.total-records span').textContent = 
                `${(parseInt(this.textContent) - 1) * 10 + 1}-${parseInt(this.textContent) * 10} de 194`;
        });
    });
    
    // Seletor de registros por página
    const recordsSelector = document.querySelector('.records-selector');
    if (recordsSelector) {
        recordsSelector.addEventListener('click', function() {
            // Aqui abriria um dropdown para selecionar o número de registros por página
            alert('Selecione o número de registros por página: 10, 20, 50, 100');
        });
    }
}

/**
 * Atualiza o título da página
 * @param {string} title - O novo título
 */
function updatePageTitle(title) {
    const sectionTitle = document.querySelector('.section-title');
    if (sectionTitle) {
        sectionTitle.textContent = title;
    }
}

/**
 * Filtra a tabela com base na aba selecionada
 * @param {string} tabName - O nome da aba
 */
function filterTableByTab(tabName) {
    console.log(`Filtrando por: ${tabName}`);
    // Aqui implementaria a lógica de filtro
    // Por enquanto, apenas simulamos a mudança
    
    // Se não houver dados, carrega dados de exemplo
    if (document.querySelector('.no-data')) {
        loadSampleData();
    }
}

/**
 * Carrega dados de exemplo na tabela
 */
function loadSampleData() {
    // Dados de exemplo para a tabela
    const sampleData = [
        {
            id: 'EMP001',
            nome: 'Ana Silva',
            iniciais: 'AS',
            email: 'ana.silva@empresa.com',
            departamento: 'Tecnologia',
            cargo: 'Desenvolvedora Frontend',
            dataAdmissao: '15/03/2022',
            status: 'Ativo',
            statusClasse: 'active'
        },
        {
            id: 'EMP002',
            nome: 'Carlos Oliveira',
            iniciais: 'CO',
            email: 'carlos.oliveira@empresa.com',
            departamento: 'Marketing',
            cargo: 'Analista de Marketing',
            dataAdmissao: '05/01/2023',
            status: 'Ativo',
            statusClasse: 'active'
        },
        {
            id: 'EMP003',
            nome: 'Mariana Costa',
            iniciais: 'MC',
            email: 'mariana.costa@empresa.com',
            departamento: 'Recursos Humanos',
            cargo: 'Gerente de RH',
            dataAdmissao: '10/06/2021',
            status: 'Ativo',
            statusClasse: 'active'
        },
        {
            id: 'EMP004',
            nome: 'Pedro Santos',
            iniciais: 'PS',
            email: 'pedro.santos@empresa.com',
            departamento: 'Financeiro',
            cargo: 'Analista Financeiro',
            dataAdmissao: '22/09/2022',
            status: 'Onboarding',
            statusClasse: 'onboarding'
        },
        {
            id: 'EMP005',
            nome: 'Juliana Lima',
            iniciais: 'JL',
            email: 'juliana.lima@empresa.com',
            departamento: 'Vendas',
            cargo: 'Representante de Vendas',
            dataAdmissao: '14/02/2023',
            status: 'Ativo',
            statusClasse: 'active'
        },
        {
            id: 'EMP006',
            nome: 'Roberto Almeida',
            iniciais: 'RA',
            email: 'roberto.almeida@empresa.com',
            departamento: 'Tecnologia',
            cargo: 'Desenvolvedor Backend',
            dataAdmissao: '03/08/2021',
            status: 'Inativo',
            statusClasse: 'inactive'
        },
        {
            id: 'EMP007',
            nome: 'Fernanda Martins',
            iniciais: 'FM',
            email: 'fernanda.martins@empresa.com',
            departamento: 'Design',
            cargo: 'UI/UX Designer',
            dataAdmissao: '19/04/2022',
            status: 'Ativo',
            statusClasse: 'active'
        },
        {
            id: 'EMP008',
            nome: 'Lucas Pereira',
            iniciais: 'LP',
            email: 'lucas.pereira@empresa.com',
            departamento: 'Suporte',
            cargo: 'Analista de Suporte',
            dataAdmissao: '08/11/2022',
            status: 'Onboarding',
            statusClasse: 'onboarding'
        },
        {
            id: 'EMP009',
            nome: 'Camila Rodrigues',
            iniciais: 'CR',
            email: 'camila.rodrigues@empresa.com',
            departamento: 'Administrativo',
            cargo: 'Assistente Administrativo',
            dataAdmissao: '25/07/2021',
            status: 'Ativo',
            statusClasse: 'active'
        },
        {
            id: 'EMP010',
            nome: 'Gabriel Ferreira',
            iniciais: 'GF',
            email: 'gabriel.ferreira@empresa.com',
            departamento: 'Tecnologia',
            cargo: 'Arquiteto de Software',
            dataAdmissao: '12/05/2020',
            status: 'Ativo',
            statusClasse: 'active'
        }
    ];
    
    // Obtém a referência para o corpo da tabela
    const tableBody = document.querySelector('.employees-table tbody');
    
    // Limpa o conteúdo atual
    tableBody.innerHTML = '';
    
    // Adiciona as linhas com os dados de exemplo
    sampleData.forEach(employee => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>
                <input type="checkbox" class="checkbox">
            </td>
            <td>${employee.id}</td>
            <td class="employee-info">
                <div class="employee-avatar">${employee.iniciais}</div>
                <div class="employee-details">
                    <div class="employee-name">${employee.nome}</div>
                    <div class="employee-email">${employee.email}</div>
                </div>
            </td>
            <td>${employee.departamento}</td>
            <td>${employee.cargo}</td>
            <td>${employee.dataAdmissao}</td>
            <td>
                <span class="status-pill ${employee.statusClasse}">${employee.status}</span>
            </td>
            <td>
                <span class="material-icons-outlined action-menu">more_vert</span>
            </td>
        `;
        
        tableBody.appendChild(row);
    });
    
    // Reinicializa os eventos da tabela
    initTableActions();
} 