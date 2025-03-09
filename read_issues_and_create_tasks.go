package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"
)

// Estruturas para representar os dados da API do GitHub
type Label struct {
	ID          int64  `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Color       string `json:"color"`
}

type User struct {
	Login string `json:"login"`
	ID    int64  `json:"id"`
}

type Issue struct {
	URL           string  `json:"url"`
	HTMLURL       string  `json:"html_url"`
	ID            int64   `json:"id"`
	Number        int     `json:"number"`
	Title         string  `json:"title"`
	State         string  `json:"state"`
	Body          string  `json:"body"`
	User          User    `json:"user"`
	Labels        []Label `json:"labels"`
	CreatedAt     string  `json:"created_at"`
	UpdatedAt     string  `json:"updated_at"`
	ClosedAt      string  `json:"closed_at"`
	CommentsCount int     `json:"comments"`
}

// Função para ler variáveis do arquivo .env
func getEnvVariable(name string, defaultValue string) string {
	// Verificar se o arquivo .env existe
	if _, err := os.Stat(".env"); os.IsNotExist(err) {
		fmt.Println("Arquivo .env não encontrado. Crie o arquivo .env baseado no .env.example.")
		os.Exit(1)
	}

	// Abrir o arquivo .env
	file, err := os.Open(".env")
	if err != nil {
		fmt.Printf("Erro ao abrir o arquivo .env: %v\n", err)
		os.Exit(1)
	}
	defer file.Close()

	// Ler o arquivo linha por linha
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		// Ignorar linhas de comentário
		if strings.HasPrefix(line, "#") {
			continue
		}

		// Procurar pela variável
		parts := strings.SplitN(line, "=", 2)
		if len(parts) == 2 && strings.TrimSpace(parts[0]) == name {
			return strings.TrimSpace(parts[1])
		}
	}

	// Verificar se houve erro durante a leitura
	if err := scanner.Err(); err != nil {
		fmt.Printf("Erro ao ler o arquivo .env: %v\n", err)
		os.Exit(1)
	}

	// Retornar o valor padrão se a variável não for encontrada
	return defaultValue
}

// Função para obter as issues do GitHub
func getGitHubIssues(owner, repo, token, state string) ([]Issue, error) {
	url := fmt.Sprintf("https://api.github.com/repos/%s/%s/issues?state=%s", owner, repo, state)

	// Criar a requisição
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("erro ao criar requisição: %v", err)
	}

	// Adicionar os headers
	req.Header.Add("Authorization", "token "+token)
	req.Header.Add("Accept", "application/vnd.github+json")
	req.Header.Add("X-GitHub-Api-Version", "2022-11-28")

	// Enviar a requisição
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("erro ao enviar requisição: %v", err)
	}
	defer resp.Body.Close()

	// Verificar o código de status
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("erro na requisição: %s", resp.Status)
	}

	// Ler o corpo da resposta
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("erro ao ler resposta: %v", err)
	}

	// Decodificar o JSON
	var issues []Issue
	err = json.Unmarshal(body, &issues)
	if err != nil {
		return nil, fmt.Errorf("erro ao decodificar JSON: %v", err)
	}

	return issues, nil
}

// Função para extrair tarefas do corpo da issue
func extractTasks(body string) []string {
	var tasks []string
	scanner := bufio.NewScanner(strings.NewReader(body))
	re := regexp.MustCompile(`^\s*-\s+(.+)$`)

	for scanner.Scan() {
		line := scanner.Text()
		matches := re.FindStringSubmatch(line)
		if len(matches) > 1 {
			tasks = append(tasks, matches[1])
		}
	}

	return tasks
}

// Função para criar um arquivo Markdown com a lista de tarefas
func createTaskList(issues []Issue, repo, outputFile string) error {
	// Criar o arquivo
	file, err := os.Create(outputFile)
	if err != nil {
		return fmt.Errorf("erro ao criar arquivo: %v", err)
	}
	defer file.Close()

	// Escrever o cabeçalho
	now := time.Now().Format("02/01/2006 15:04:05")
	fmt.Fprintf(file, "# Lista de Tarefas do Projeto %s\n\n", repo)
	fmt.Fprintf(file, "Este documento foi gerado automaticamente a partir das issues do GitHub em %s.\n\n", now)

	// Agrupar issues por labels
	groupedIssues := make(map[string][]Issue)
	for _, issue := range issues {
		var labelNames []string
		for _, label := range issue.Labels {
			labelNames = append(labelNames, label.Name)
		}
		labelGroup := strings.Join(labelNames, ", ")
		groupedIssues[labelGroup] = append(groupedIssues[labelGroup], issue)
	}

	// Adicionar as issues agrupadas por labels
	for labelGroup, groupIssues := range groupedIssues {
		fmt.Fprintf(file, "## Categoria: %s\n\n", labelGroup)

		for _, issue := range groupIssues {
			fmt.Fprintf(file, "### %s (Issue #%d)\n\n", issue.Title, issue.Number)
			fmt.Fprintf(file, "%s\n\n", issue.Body)
			fmt.Fprintf(file, "**Link:** %s\n\n", issue.HTMLURL)
			fmt.Fprintf(file, "**Tarefas:**\n")

			// Extrair tarefas do corpo da issue
			tasks := extractTasks(issue.Body)
			for _, task := range tasks {
				fmt.Fprintf(file, "- [ ] %s\n", task)
			}

			fmt.Fprintf(file, "\n---\n\n")
		}
	}

	return nil
}

func main() {
	// Obter as configurações do arquivo .env
	token := getEnvVariable("GITHUB_TOKEN", "")
	owner := getEnvVariable("GITHUB_OWNER", "")
	repo := getEnvVariable("GITHUB_REPO", "")

	// Verificar se as variáveis obrigatórias estão definidas
	if token == "" {
		fmt.Println("Token do GitHub não encontrado no arquivo .env. Adicione GITHUB_TOKEN=seu_token_aqui ao arquivo .env.")
		os.Exit(1)
	}

	if owner == "" {
		fmt.Println("Proprietário do repositório não encontrado no arquivo .env. Adicione GITHUB_OWNER=seu_usuario_github ao arquivo .env.")
		os.Exit(1)
	}

	if repo == "" {
		fmt.Println("Nome do repositório não encontrado no arquivo .env. Adicione GITHUB_REPO=nome_do_repositorio ao arquivo .env.")
		os.Exit(1)
	}

	// Obter as issues do GitHub
	fmt.Printf("Obtendo issues do repositório %s/%s...\n", owner, repo)
	issues, err := getGitHubIssues(owner, repo, token, "open")
	if err != nil {
		fmt.Printf("Erro ao obter issues: %v\n", err)
		os.Exit(1)
	}

	if len(issues) == 0 {
		fmt.Println("Nenhuma issue encontrada.")
		os.Exit(0)
	}

	fmt.Printf("Encontradas %d issues.\n", len(issues))

	// Criar a lista de tarefas
	now := time.Now().Format("20060102")
	outputFile := fmt.Sprintf("tarefas-%s.md", now)
	err = createTaskList(issues, repo, outputFile)
	if err != nil {
		fmt.Printf("Erro ao criar lista de tarefas: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Lista de tarefas criada com sucesso em %s\n", outputFile)

	// Tentar abrir o arquivo no navegador padrão (isso pode variar dependendo do sistema operacional)
	fmt.Println("Tente abrir o arquivo manualmente para visualizar as tarefas.")
}
