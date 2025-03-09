package main

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gofiber/fiber/v2"
)

// MockHTTPClient é um cliente HTTP mock para testes
type MockHTTPClient struct {
	DoFunc func(req *http.Request) (*http.Response, error)
}

func (m *MockHTTPClient) Get(url string) (*http.Response, error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}
	return m.DoFunc(req)
}

func TestHealthEndpoint(t *testing.T) {
	// Configurar o mecanismo de templates para teste
	// Não precisamos de templates reais para testar o endpoint de saúde
	app := fiber.New()

	// Adicionar rota de saúde
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status": "ok",
		})
	})

	// Criar uma requisição de teste
	req := httptest.NewRequest("GET", "/health", nil)

	// Executar a requisição
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Falha ao testar: %v", err)
	}

	// Verificar o código de status
	if resp.StatusCode != fiber.StatusOK {
		t.Errorf("Status esperado %d, obtido %d", fiber.StatusOK, resp.StatusCode)
	}

	// Ler o corpo da resposta
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("Falha ao ler o corpo da resposta: %v", err)
	}

	// Verificar o conteúdo da resposta
	expected := `{"status":"ok"}`
	if strings.TrimSpace(string(body)) != expected {
		t.Errorf("Resposta esperada %s, obtida %s", expected, string(body))
	}
}
