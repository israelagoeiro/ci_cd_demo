# Estágio de build
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copiar arquivos de dependência
COPY go.mod ./
# Copiar o código fonte
COPY *.go ./

# Compilar a aplicação
RUN CGO_ENABLED=0 GOOS=linux go build -o api-server .

# Estágio de execução
FROM alpine:latest

WORKDIR /app

# Copiar o binário compilado do estágio de build
COPY --from=builder /app/api-server .

# Expor a porta que a aplicação usa
EXPOSE 8080

# Comando para executar a aplicação
CMD ["./api-server"] 