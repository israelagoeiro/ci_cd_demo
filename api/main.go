package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strings"
)

// Tarefa representa uma tarefa no sistema
type Tarefa struct {
	ID        string `json:"id"`
	Titulo    string `json:"titulo"`
	Concluida bool   `json:"concluida"`
}

// Armazenamento em memória para tarefas
var tarefas = []Tarefa{
	{ID: "1", Titulo: "Aprender Go", Concluida: false},
	{ID: "2", Titulo: "Implementar CI/CD", Concluida: false},
}

func main() {
	// Configurar rotas
	http.HandleFunc("/api/tarefas", manipuladorTarefas)
	http.HandleFunc("/api/tarefas/", manipuladorTarefasPorID)
	http.HandleFunc("/api/health", manipuladorHealth)

	// Iniciar servidor
	log.Println("Servidor API iniciando na porta 8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func manipuladorTarefas(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	// Permitir CORS para desenvolvimento
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	// Apenas implementando GET para simplificar
	if r.Method == "GET" {
		json.NewEncoder(w).Encode(tarefas)
		return
	}

	// Método não suportado
	w.WriteHeader(http.StatusMethodNotAllowed)
}

func manipuladorTarefasPorID(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	// Permitir CORS para desenvolvimento
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, DELETE, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	// Extrair ID da URL
	path := strings.TrimPrefix(r.URL.Path, "/api/tarefas/")
	id := strings.TrimSpace(path)

	if id == "" {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"erro": "ID não fornecido"})
		return
	}

	// Manipular DELETE para excluir tarefa
	if r.Method == "DELETE" {
		var tarefasAtualizadas []Tarefa
		encontrada := false

		for _, t := range tarefas {
			if t.ID != id {
				tarefasAtualizadas = append(tarefasAtualizadas, t)
			} else {
				encontrada = true
			}
		}

		if !encontrada {
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(map[string]string{"erro": "Tarefa não encontrada"})
			return
		}

		tarefas = tarefasAtualizadas
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"mensagem": "Tarefa excluída com sucesso"})
		return
	}

	// Método não suportado
	w.WriteHeader(http.StatusMethodNotAllowed)
}

func manipuladorHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}
