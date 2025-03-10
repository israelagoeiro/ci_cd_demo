# Especificação Completa da Interface HRISELINK

## 1. Visão Geral

O HRISELINK é um sistema de gerenciamento de recursos humanos (HRMS) com interface moderna e funcional. A aplicação apresenta uma estrutura com barra lateral de navegação, área principal de conteúdo e cabeçalho superior, otimizada para gerenciamento eficiente de dados de funcionários.

## 2. Estrutura da Interface

### 2.1 Layout Principal
- **Container Principal**: 100% da largura da viewport, altura mínima de 100vh
- **Grid Layout**: Divisão em 3 áreas principais:
  - Barra lateral: 240px de largura fixa (colapsável em dispositivos móveis)
  - Área de conteúdo: Largura flexível (calc(100% - 240px))
  - Altura do header: 64px fixos no topo

### 2.2 Barra Lateral (Sidebar)
- **Dimensões**: 240px × 100vh
- **Background**: #F8FAFC
- **Borda direita**: 1px solid #E5E7EB
- **Padding interno**: 16px
- **Espaçamento entre seções**: 24px

- **Logo HRISELINK**:
  - Posição: Topo da sidebar, centralizado horizontalmente
  - Tamanho: 140px × 32px
  - Cor do logotipo: #0F172A
  - Ícone: 24px × 24px, à esquerda do texto

- **Campo de pesquisa global**:
  - Altura: 38px
  - Border-radius: 6px
  - Background: #FFFFFF
  - Border: 1px solid #E5E7EB
  - Placeholder: "Search..."
  - Ícone de lupa: 16px × 16px, #6B7280
  - Atalho de teclado: "⌘ F" (exibido à direita)
  - Margin: 16px 0

- **Menu de Navegação**:
  - Itens principais: 36px de altura
  - Padding: 8px 12px
  - Border-radius: 6px
  - Ícones: 20px × 20px, alinhados à esquerda, #4B5563
  - Texto: 14px, 500 weight, #111827
  - Espaçamento entre ícone e texto: 12px
  - Indicador de expansão: Seta (chevron-down), 14px × 14px
  
  - **Item ativo**:
    - Background: #EFF6FF
    - Texto: #0F172A (mais escuro)
    - Borda esquerda: 3px solid #3B82F6
    
  - **Subitens** (quando expandido):
    - Margin-left: 28px
    - Altura: 32px
    - Sem ícones
    - Texto: 13px, 400 weight
    - Item ativo: Texto #3B82F6, background transparente

- **Rodapé da Sidebar**:
  - Avatar da empresa: 32px × 32px, circular
  - Nome "Wishbone": 14px, 600 weight
  - Texto "61 members": 12px, #6B7280
  - Posicionamento: 16px do fundo da sidebar

### 2.3 Cabeçalho Superior
- **Altura**: 64px
- **Background**: #FFFFFF
- **Borda inferior**: 1px solid #E5E7EB
- **Padding horizontal**: 24px
- **Display**: Flex com justify-content: space-between

- **Título da seção**:
  - Texto "Employee": 18px, 700 weight, #111827
  - Margin-right: auto

- **Botões de ação**:
  - "Export CSV": 
    - Tipo: Secundário
    - Dimensão: 120px × 40px
    - Background: #FFFFFF
    - Border: 1px solid #E5E7EB
    - Texto: 14px, 500 weight, #111827
    - Border-radius: 6px
    - Margin-right: 12px
    
  - "Add new": 
    - Tipo: Primário
    - Dimensão: 100px × 40px
    - Background: #0F172A
    - Texto: 14px, 500 weight, #FFFFFF
    - Border-radius: 6px

- **Ícones de utilidade**:
  - Mensagens: 20px × 20px, #4B5563
  - Notificações: 20px × 20px, #4B5563
  - Espaçamento entre ícones: 16px
  - Badge de notificação: 8px × 8px, circular, #F43F5E 
  - Posição: 2px acima, 2px à direita do ícone de notificação

### 2.4 Área Principal de Conteúdo
- **Padding**: 24px
- **Background**: #FFFFFF

- **Navegação por abas**:
  - Altura: 48px
  - Border-bottom: 1px solid #E5E7EB
  - Margin-bottom: 24px
  
  - **Abas individuais**:
    - Padding: 12px 16px
    - Texto: 14px, 600 weight
    - Aba inativa: Texto #6B7280
    - Aba ativa: Texto #0F172A, border-bottom 2px solid #0F172A
    - Hover: Texto #374151

- **Barra de funcionalidades**:
  - Altura: 48px
  - Display: Flex, justify-content: space-between
  - Margin-bottom: 24px
  
  - **Campo de pesquisa localizado**:
    - Width: 280px
    - Height: 38px
    - Border: 1px solid #E5E7EB
    - Border-radius: 6px
    - Padding: 0 12px
    - Placeholder: "Search..."
    - Ícone de lupa: 16px × 16px, #6B7280
  
  - **Controles de visualização**:
    - Botão "Filter": 
      - Height: 38px
      - Border: 1px solid #E5E7EB
      - Border-radius: 6px
      - Padding: 0 12px
      - Texto: 14px, #4B5563
      - Ícone: 16px × 16px
    
    - Botão "Sort": 
      - Height: 38px
      - Border: 1px solid #E5E7EB
      - Border-radius: 6px
      - Padding: 0 12px
      - Texto: 14px, #4B5563
      - Ícone: 16px × 16px

### 2.5 Cards de Resumo
- **Container**: Display grid, grid-template-columns: repeat(4, 1fr)
- **Gap**: 16px
- **Margin-bottom**: 24px

- **Card individual**:
  - Height: 120px
  - Background: #FFFFFF
  - Border: 1px solid #E5E7EB
  - Border-radius: 8px
  - Padding: 16px
  - Display: Flex, flex-direction: column
  
  - **Ícone do card**:
    - Dimensão: 40px × 40px
    - Border-radius: 8px
    - Background: #F8FAFC
    - Ícone interno: 20px × 20px, #4B5563
    - Margin-bottom: 12px
  
  - **Valor numérico**:
    - Texto: 24px, 700 weight, #111827
    - Margin-bottom: 4px
    - Display: Flex, align-items: center
  
  - **Indicador de variação**:
    - Texto: 13px, 500 weight
    - Positivo: ↑ texto #10B981 (verde)
    - Negativo: ↓ texto #F43F5E (vermelho)
    - Margin-left: 8px
  
  - **Legenda**:
    - Texto: 14px, 400 weight, #6B7280

### 2.6 Tabela de Funcionários
- **Container**: Width: 100%
- **Border**: 1px solid #E5E7EB
- **Border-radius**: 8px
- **Overflow**: hidden

- **Cabeçalho da tabela**:
  - Height: 48px
  - Background: #F8FAFC
  - Border-bottom: 1px solid #E5E7EB
  
  - **Célula de cabeçalho**:
    - Texto: 13px, 600 weight, #4B5563
    - Padding: 0 16px
    - Text-align: left
    - White-space: nowrap
    - Cursor: pointer (para ordenação)
    
  - **Ícone de ordenação**:
    - Tamanho: 12px × 12px
    - Margin-left: 4px
    - Cor: #6B7280

- **Linhas de dados**:
  - Height: 72px
  - Border-bottom: 1px solid #E5E7EB
  - Hover: Background #F8FAFC
  
  - **Células de dados**:
    - Padding: 16px
    - Vertical-align: middle
    
  - **Checkbox de seleção**:
    - Tamanho: 18px × 18px
    - Border: 1.5px solid #6B7280
    - Border-radius: 4px
    - Background quando checked: #0F172A
    - Checkmark: Branco, 10px × 10px
    
  - **Avatar de funcionário**:
    - Tamanho: 32px × 32px
    - Border-radius: 16px (circular)
    - Border: 1px solid #E5E7EB

  - **Informações do funcionário**:
    - Nome: 14px, 600 weight, #111827
    - Email: 13px, 400 weight, #6B7280
    - Display: Flex, flex-direction: column
    
  - **Dados de tabela**:
    - Texto principal: 14px, 400 weight, #111827
    - Alinhamento variável:
      - ID, Nome: Left
      - Data: Center
    
  - **Status (Pills)**:
    - Width: 100px
    - Height: 28px
    - Border-radius: 14px
    - Texto: 13px, 500 weight
    - Text-align: center
    - Display: flex, align-items: center, justify-content: center
    
    - **Variantes**:
      - Active: Background #DCFCE7, texto #10B981
      - Inactive: Background #FFECEC, texto #F43F5E
      - Onboarding: Background #FEF3C7, texto #F59E0B
      
  - **Menu de ações**:
    - Ícone: três pontos verticais, 16px × 16px, #6B7280
    - Cursor: pointer
    - Hover: Background #F1F5F9, border-radius: 4px
    - Dropdown: Width 180px, background #FFFFFF, border 1px solid #E5E7EB, border-radius 6px, box-shadow 0 4px 6px -1px rgba(0,0,0,0.1)

### 2.7 Paginação
- **Container**: Display flex, justify-content: space-between, align-items: center
- **Margin-top**: 16px
- **Padding**: 16px 0

- **Seletor de registros por página**:
  - Display: Flex, align-items: center
  - Texto "10 records": 14px, 400 weight, #4B5563
  - Dropdown arrow: 14px × 14px, #6B7280
  
- **Navegador de páginas**:
  - Display: Flex, align-items: center
  - Gap: 4px
  
  - **Botões de navegação** (anterior/próximo):
    - Width: 32px
    - Height: 32px
    - Border: 1px solid #E5E7EB
    - Border-radius: 6px
    - Display: flex, align-items: center, justify-content: center
    - Ícone: 16px × 16px, #4B5563
    
  - **Botões de página**:
    - Width: 32px
    - Height: 32px
    - Border: 1px solid #E5E7EB
    - Border-radius: 6px
    - Texto: 14px, 400 weight, #4B5563
    - Display: flex, align-items: center, justify-content: center
    
  - **Página ativa**:
    - Background: #0F172A
    - Texto: 14px, 400 weight, #FFFFFF
    - Border: none
    
  - **Indicador de ellipsis** (...):
    - Texto: 14px, 400 weight, #4B5563
    
- **Indicador de total de registros**:
  - Texto "10 - 194": 14px, 400 weight, #4B5563

## 3. Esquema de Cores

### 3.1 Cores Primárias
- **Navy/Azul escuro (#0F172A)**: 
  - Botões primários
  - Elementos ativos
  - Cabeçalho de páginas
  
- **Azul (#3B82F6)**:
  - Indicadores de seleção
  - Links
  - Destaques interativos
  
- **Branco (#FFFFFF)**:
  - Background principal
  - Texto em botões primários
  
- **Cinza muito claro (#F8FAFC)**:
  - Background secundário
  - Background da sidebar
  - Background de cabeçalhos de tabelas

### 3.2 Cores de Status
- **Verde (#10B981)**:
  - Status "Active"
  - Indicadores positivos
  - Background verde claro (#DCFCE7) para pills
  
- **Vermelho (#F43F5E)**:
  - Status "Inactive"
  - Indicadores negativos
  - Background vermelho claro (#FFECEC) para pills
  
- **Laranja/Âmbar (#F59E0B)**:
  - Status "Onboarding"
  - Alertas
  - Background âmbar claro (#FEF3C7) para pills

### 3.3 Cores de Texto
- **Preto (#111827)**:
  - Títulos principais
  - Texto de destaque
  - Valores importantes
  
- **Cinza escuro (#374151)**:
  - Texto principal do corpo
  - Labels
  
- **Cinza médio (#4B5563)**:
  - Texto secundário
  - Cabeçalhos de tabela
  - Ícones
  
- **Cinza claro (#6B7280)**:
  - Texto terciário
  - Placeholders
  - Legendas

### 3.4 Cores de Elementos UI
- **Cinza de bordas (#E5E7EB)**:
  - Bordas
  - Separadores
  - Outlines
  
- **Azul claro (#EFF6FF)**:
  - Background de itens selecionados no menu
  - Highlight de elementos interativos

## 4. Tipografia

### 4.1 Família de Fonte
- **Principal**: Inter (sans-serif)
- **Fallback**: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif

### 4.2 Tamanhos de Fonte
- **Títulos principais**: 18px, 700 weight (bold)
- **Subtítulos/Cabeçalhos de seção**: 16px, 600 weight (semibold)
- **Texto normal/Dados principais**: 14px, 400 weight (regular)
- **Texto secundário/Email/Informações adicionais**: 13px, 400 weight (regular)
- **Texto terciário/Legenda/Notas**: 12px, 400 weight (regular)
- **Valores de métricas/KPIs**: 24px, 700 weight (bold)

### 4.3 Line-heights
- **Headers**: 1.2
- **Corpo de texto**: 1.5
- **Elementos compactos**: 1.25

### 4.4 Estilos Específicos
- **Texto truncado**: 
  - white-space: nowrap
  - overflow: hidden
  - text-overflow: ellipsis
  
- **Texto interativo**:
  - Hover: text-decoration: none, color muda para mais escuro
  - Links: color: #3B82F6
  
- **Formatação de texto**:
  - Capitalização em botões: text-transform: none
  - Capitalização em cabeçalhos de tabela: text-transform: none

## 5. Elementos Visuais

### 5.1 Sombras
- **Dropdown menus**: box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06)
- **Cards**: box-shadow: 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06)
- **Modais**: box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05)
- **Botões hover**: box-shadow: 0 1px 2px rgba(0,0,0,0.05)

### 5.2 Bordas e Cantos
- **Border-radius padrão**: 6px
- **Border-radius para botões**: 6px
- **Border-radius para cards**: 8px
- **Border-radius para pills**: 14px (28px/2)
- **Border-radius para avatares**: 50% (circular)

- **Espessura de bordas**:
  - Padrão: 1px
  - Foco: 2px
  - Destaque: 3px

### 5.3 Ícones
- **Família**: Material Design Icons ou similar
- **Estilo**: Outline (não solid)
- **Tamanhos**:
  - Extra pequeno: 12px × 12px (indicadores, badges)
  - Pequeno: 16px × 16px (botões compactos, indicadores)
  - Médio: 20px × 20px (navegação, funcionalidades)
  - Grande: 24px × 24px (destaque, header)
  
- **Peso da linha**: 1.5px
- **Corner radius**: 2px
- **Cores**: Herdam a cor do texto ou definidas como #4B5563 (cinza médio)

### 5.4 Efeitos de Interação
- **Hover em botões**:
  - Primário: Diminui opacidade para 90%
  - Secundário: Background muda para #F8FAFC
  
- **Hover em linhas de tabela**:
  - Background: #F8FAFC
  
- **Hover em menu items**:
  - Background: #EFF6FF
  
- **Transições**:
  - Duração: 150ms
  - Timing-function: ease-in-out
  - Propriedades: color, background-color, border-color, box-shadow

### 5.5 Espaçamento
- **Grid base**: 4px
- **Padding padrão**: 16px
- **Margens**:
  - Entre seções: 24px
  - Entre elementos relacionados: 16px
  - Entre elementos agrupados: 8px
  
- **Layout vertical**:
  - Cabeçalhos de seção: 24px de margin-bottom
  - Cards: 16px de gap

## 6. Comportamentos e Estados Interativos

### 6.1 Estados de Botões
- **Default**: Cor padrão, sem sombra
- **Hover**: Mudança de background/opacidade, leve sombra
- **Active/Pressed**: Escurece 10%, sem sombra, scale(0.98)
- **Disabled**: Opacidade 50%, cursor: not-allowed
- **Loading**: Exibe spinner de 16px × 16px, texto invisível, mantém largura

### 6.2 Estados de Formulários
- **Input default**: Border 1px solid #E5E7EB
- **Input hover**: Border 1px solid #D1D5DB
- **Input focus**: Border 2px solid #3B82F6, outline: none
- **Input error**: Border 2px solid #F43F5E
- **Input success**: Border 2px solid #10B981
- **Input disabled**: Background #F8FAFC, opacity 0.6

### 6.3 Estados de Navegação
- **Item default**: Texto #4B5563
- **Item hover**: Texto #374151, background #F8FAFC
- **Item active**: Texto #0F172A, background #EFF6FF, borda esquerda 3px #3B82F6
- **Item expanded**: Semelhante ao active, mas com ícone de seta virado

### 6.4 Estados de Tabela
- **Row default**: Background #FFFFFF
- **Row hover**: Background #F8FAFC
- **Row selected**: Background #EFF6FF
- **Row disabled**: Opacity 0.6

### 6.5 Animações e Transições
- **Menu expansão/colapso**: height transition 200ms ease
- **Tooltips**: fade-in 150ms, slide-up 5px
- **Modais**: fade-in 200ms, scale from 0.95 to 1
- **Notificações**: slide-in from right, 300ms

## 7. Layout Responsivo e Breakpoints

### 7.1 Breakpoints
- **Mobile**: < 640px
- **Tablet**: 640px - 1023px
- **Desktop**: ≥ 1024px

### 7.2 Adaptações para Mobile
- **Sidebar**: Colapsa para um menu de hambúrguer
- **Table**: Células menos importantes se escondem, layout simplificado
- **Cards**: Empilham verticalmente em uma coluna única
- **Botões**: Full-width em viewports estreitas

### 7.3 Adaptações para Tablet
- **Layout**: Sidebar estreita com apenas ícones (80px)
- **Table**: Layout ligeiramente compacto
- **Cards**: 2x2 grid

## 8. Considerações de Acessibilidade

### 8.1 Contraste
- **Texto normal sobre fundo claro**: ≥ 4.5:1
- **Texto grande/títulos sobre fundo claro**: ≥ 3:1
- **Elementos interativos/Botões**: ≥ 3:1

### 8.2 Tamanho dos Alvos de Toque
- **Mínimo**: 44px × 44px para elementos interativos primários
- **Espaçamento**: Mínimo 8px entre elementos tocáveis

### 8.3 Estados Focáveis
- **Outline visível**: 2px solid #3B82F6
- **Ordem de tabulação**: Lógica e sequencial

### 8.4 Textos Alternativos
- **Ícones interativos**: Todos possuem texto alternativo via aria-label
- **Imagens**: Alt text descritivo
- **Elementos visuais**: Equivalentes textuais apropriados
