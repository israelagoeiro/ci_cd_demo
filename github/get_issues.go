package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

// Issue representa uma issue do GitHub
type Issue struct {
	Number    int       `json:"number"`
	Title     string    `json:"title"`
	Body      string    `json:"body"`
	State     string    `json:"state"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	URL       string    `json:"html_url"`
	Labels    []Label   `json:"labels"`
}

// Label representa uma etiqueta de issue
type Label struct {
	Name  string `json:"name"`
	Color string `json:"color"`
}

// Função para ler variáveis do arquivo .env
func getEnvVariable(name string) string {
	file, err := os.Open(".env")
	if err != nil {
		fmt.Printf("Erro ao abrir arquivo .env: %v\n", err)
		return ""
	}
	defer file.Close()

	content, err := io.ReadAll(file)
	if err != nil {
		fmt.Printf("Erro ao ler arquivo .env: %v\n", err)
		return ""
	}

	lines := strings.Split(string(content), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "#") || line == "" {
			continue
		}

		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}

		key := strings.TrimSpace(parts[0])
		value := strings.TrimSpace(parts[1])

		if key == name {
			return value
		}
	}

	return ""
}

func main() {
	// Obter variáveis do arquivo .env
	token := getEnvVariable("GITHUB_TOKEN")
	owner := getEnvVariable("GITHUB_OWNER")
	repo := getEnvVariable("GITHUB_REPO")

	if token == "" || owner == "" || repo == "" {
		fmt.Println("Erro: Variáveis de ambiente não encontradas no arquivo .env")
		fmt.Println("Certifique-se de que GITHUB_TOKEN, GITHUB_OWNER e GITHUB_REPO estão definidos")
		os.Exit(1)
	}

	// Construir a URL da API do GitHub
	url := fmt.Sprintf("https://api.github.com/repos/%s/%s/issues?state=all", owner, repo)

	// Criar a requisição
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		fmt.Printf("Erro ao criar requisição: %v\n", err)
		os.Exit(1)
	}

	// Adicionar cabeçalhos
	req.Header.Add("Authorization", "token "+token)
	req.Header.Add("Accept", "application/vnd.github+json")
	req.Header.Add("X-GitHub-Api-Version", "2022-11-28")

	// Enviar a requisição
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("Erro ao enviar requisição: %v\n", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	// Verificar o código de status
	if resp.StatusCode != http.StatusOK {
		fmt.Printf("Erro na resposta da API: %s\n", resp.Status)
		body, _ := io.ReadAll(resp.Body)
		fmt.Println(string(body))
		os.Exit(1)
	}

	// Ler o corpo da resposta
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("Erro ao ler resposta: %v\n", err)
		os.Exit(1)
	}

	// Decodificar o JSON
	var issues []Issue
	err = json.Unmarshal(body, &issues)
	if err != nil {
		fmt.Printf("Erro ao decodificar JSON: %v\n", err)
		os.Exit(1)
	}

	// Exibir as issues
	fmt.Printf("Encontradas %d issues no repositório %s/%s:\n\n", len(issues), owner, repo)
	for _, issue := range issues {
		fmt.Printf("Issue #%d: %s\n", issue.Number, issue.Title)
		fmt.Printf("Estado: %s\n", issue.State)
		fmt.Printf("Criada em: %s\n", issue.CreatedAt.Format("02/01/2006 15:04:05"))
		fmt.Printf("URL: %s\n", issue.URL)

		if len(issue.Labels) > 0 {
			fmt.Print("Labels: ")
			for i, label := range issue.Labels {
				if i > 0 {
					fmt.Print(", ")
				}
				fmt.Print(label.Name)
			}
			fmt.Println()
		}

		fmt.Println("---")
	}

	// Salvar as issues em um arquivo JSON
	outputFile := "issues.json"
	jsonData, err := json.MarshalIndent(issues, "", "  ")
	if err != nil {
		fmt.Printf("Erro ao gerar JSON: %v\n", err)
	} else {
		err = os.WriteFile(outputFile, jsonData, 0644)
		if err != nil {
			fmt.Printf("Erro ao salvar arquivo JSON: %v\n", err)
		} else {
			fmt.Printf("Issues salvas em %s\n", outputFile)
		}
	}
}
