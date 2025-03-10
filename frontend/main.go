package main

import (
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/template/mustache/v2"
)

// Funcionario representa um funcionário no sistema
type Funcionario struct {
	ID           string `json:"id"`
	Nome         string `json:"nome"`
	Iniciais     string `json:"iniciais"`
	Email        string `json:"email"`
	Departamento string `json:"departamento"`
	Cargo        string `json:"cargo"`
	DataAdmissao string `json:"dataAdmissao"`
	Status       string `json:"status"`
	StatusClasse string `json:"statusClasse"`
}

// Função principal da aplicação
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
		// Renderizar o template com os dados
		return c.Render("index", fiber.Map{
			"Titulo":       "HRISELINK - Sistema de Gerenciamento de RH",
			"Funcionarios": obterFuncionarios(),
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

// obterFuncionarios retorna uma lista de funcionários de exemplo
func obterFuncionarios() []Funcionario {
	return []Funcionario{
		{
			ID:           "EMP001",
			Nome:         "Ana Silva",
			Iniciais:     "AS",
			Email:        "ana.silva@empresa.com",
			Departamento: "Tecnologia",
			Cargo:        "Desenvolvedora Frontend",
			DataAdmissao: "15/03/2022",
			Status:       "Ativo",
			StatusClasse: "active",
		},
		{
			ID:           "EMP002",
			Nome:         "Carlos Oliveira",
			Iniciais:     "CO",
			Email:        "carlos.oliveira@empresa.com",
			Departamento: "Marketing",
			Cargo:        "Analista de Marketing",
			DataAdmissao: "05/01/2023",
			Status:       "Ativo",
			StatusClasse: "active",
		},
		{
			ID:           "EMP003",
			Nome:         "Mariana Costa",
			Iniciais:     "MC",
			Email:        "mariana.costa@empresa.com",
			Departamento: "Recursos Humanos",
			Cargo:        "Gerente de RH",
			DataAdmissao: "10/06/2021",
			Status:       "Ativo",
			StatusClasse: "active",
		},
		{
			ID:           "EMP004",
			Nome:         "Pedro Santos",
			Iniciais:     "PS",
			Email:        "pedro.santos@empresa.com",
			Departamento: "Financeiro",
			Cargo:        "Analista Financeiro",
			DataAdmissao: "22/09/2022",
			Status:       "Onboarding",
			StatusClasse: "onboarding",
		},
		{
			ID:           "EMP005",
			Nome:         "Juliana Lima",
			Iniciais:     "JL",
			Email:        "juliana.lima@empresa.com",
			Departamento: "Vendas",
			Cargo:        "Representante de Vendas",
			DataAdmissao: "14/02/2023",
			Status:       "Ativo",
			StatusClasse: "active",
		},
		{
			ID:           "EMP006",
			Nome:         "Roberto Almeida",
			Iniciais:     "RA",
			Email:        "roberto.almeida@empresa.com",
			Departamento: "Tecnologia",
			Cargo:        "Desenvolvedor Backend",
			DataAdmissao: "03/08/2021",
			Status:       "Inativo",
			StatusClasse: "inactive",
		},
		{
			ID:           "EMP007",
			Nome:         "Fernanda Martins",
			Iniciais:     "FM",
			Email:        "fernanda.martins@empresa.com",
			Departamento: "Design",
			Cargo:        "UI/UX Designer",
			DataAdmissao: "19/04/2022",
			Status:       "Ativo",
			StatusClasse: "active",
		},
		{
			ID:           "EMP008",
			Nome:         "Lucas Pereira",
			Iniciais:     "LP",
			Email:        "lucas.pereira@empresa.com",
			Departamento: "Suporte",
			Cargo:        "Analista de Suporte",
			DataAdmissao: "08/11/2022",
			Status:       "Onboarding",
			StatusClasse: "onboarding",
		},
		{
			ID:           "EMP009",
			Nome:         "Camila Rodrigues",
			Iniciais:     "CR",
			Email:        "camila.rodrigues@empresa.com",
			Departamento: "Administrativo",
			Cargo:        "Assistente Administrativo",
			DataAdmissao: "25/07/2021",
			Status:       "Ativo",
			StatusClasse: "active",
		},
		{
			ID:           "EMP010",
			Nome:         "Gabriel Ferreira",
			Iniciais:     "GF",
			Email:        "gabriel.ferreira@empresa.com",
			Departamento: "Tecnologia",
			Cargo:        "Arquiteto de Software",
			DataAdmissao: "12/05/2020",
			Status:       "Ativo",
			StatusClasse: "active",
		},
	}
}
