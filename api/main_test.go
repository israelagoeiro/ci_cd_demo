package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestManipuladorHealth(t *testing.T) {
	// Criar uma requisição HTTP GET para o endpoint /api/health
	req, err := http.NewRequest("GET", "/api/health", nil)
	if err != nil {
		t.Fatal(err)
	}

	// Criar um ResponseRecorder para gravar a resposta
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(manipuladorHealth)

	// Chamar o manipulador com a requisição e o response recorder
	handler.ServeHTTP(rr, req)

	// Verificar o código de status
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler retornou código de status errado: obtido %v esperado %v",
			status, http.StatusOK)
	}

	// Verificar o corpo da resposta
	var resposta map[string]string
	err = json.Unmarshal(rr.Body.Bytes(), &resposta)
	if err != nil {
		t.Fatal(err)
	}

	// Verificar se o status é "ok"
	if resposta["status"] != "ok" {
		t.Errorf("handler retornou status inesperado: obtido %v esperado %v",
			resposta["status"], "ok")
	}
}

func TestManipuladorTarefas(t *testing.T) {
	// Criar uma requisição HTTP GET para o endpoint /api/tarefas
	req, err := http.NewRequest("GET", "/api/tarefas", nil)
	if err != nil {
		t.Fatal(err)
	}

	// Criar um ResponseRecorder para gravar a resposta
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(manipuladorTarefas)

	// Chamar o manipulador com a requisição e o response recorder
	handler.ServeHTTP(rr, req)

	// Verificar o código de status
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler retornou código de status errado: obtido %v esperado %v",
			status, http.StatusOK)
	}

	// Verificar o corpo da resposta
	var tarefasResposta []Tarefa
	err = json.Unmarshal(rr.Body.Bytes(), &tarefasResposta)
	if err != nil {
		t.Fatal(err)
	}

	// Verificar se retornou pelo menos uma tarefa
	if len(tarefasResposta) == 0 {
		t.Errorf("handler retornou lista de tarefas vazia")
	}
}
