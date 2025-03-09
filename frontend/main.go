package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/template/mustache/v2"
)

// Tarefa representa uma tarefa no sistema
type Tarefa struct {
	ID        string `json:"id"`
	Titulo    string `json:"titulo"`
	Concluida bool   `json:"concluida"`
}

// Função principal da aplicação
// Teste de CI/CD - Verificando se o fluxo está funcionando corretamente
func main() {
	// Configurar o mecanismo de templates Mustache
	engine := mustache.New("./views", ".mustache")

	// Criar uma nova instância do Fiber
	app := fiber.New(fiber.Config{
		Views: engine,
	})

	// Servir arquivos estáticos
	app.Static("/", "./public")

	// Rota principal
	app.Get("/", func(c *fiber.Ctx) error {
		// Obter o endereço da API do ambiente ou usar o padrão
		apiURL := os.Getenv("API_URL")
		if apiURL == "" {
			apiURL = "http://localhost:8080"
		}

		// Buscar tarefas da API
		tarefas, err := buscarTarefas(apiURL)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).SendString("Erro ao buscar tarefas: " + err.Error())
		}

		// Renderizar o template com os dados
		return c.Render("index", fiber.Map{
			"Titulo":  "Gerenciador de Tarefas",
			"Tarefas": tarefas,
		})
	})

	// Rota de verificação de saúde
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status": "ok",
		})
	})

	// Iniciar o servidor
	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}
	log.Println("Servidor Frontend iniciando na porta " + port + "...")
	log.Fatal(app.Listen(":" + port))
}

// buscarTarefas busca tarefas da API
func buscarTarefas(apiURL string) ([]Tarefa, error) {
	// Fazer requisição HTTP para a API
	resp, err := http.Get(apiURL + "/api/tarefas")
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	// Decodificar a resposta JSON
	var tarefas []Tarefa
	err = json.NewDecoder(resp.Body).Decode(&tarefas)
	if err != nil {
		return nil, err
	}

	return tarefas, nil
}
