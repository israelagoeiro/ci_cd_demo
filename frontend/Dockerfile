# Estágio de build
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copiar arquivos de dependência
COPY go.mod ./
# Baixar dependências
RUN go mod download

# Copiar o código fonte
COPY *.go ./
COPY views/ ./views/
COPY public/ ./public/

# Compilar a aplicação
RUN CGO_ENABLED=0 GOOS=linux go build -o frontend-server .

# Estágio de execução
FROM alpine:latest

WORKDIR /app

# Copiar o binário compilado do estágio de build
COPY --from=builder /app/frontend-server .
# Copiar arquivos estáticos e templates
COPY --from=builder /app/views/ ./views/
COPY --from=builder /app/public/ ./public/

# Expor a porta que a aplicação usa
EXPOSE 3000

# Variáveis de ambiente
ENV PORT=3000
ENV API_URL=http://api:8080

# Comando para executar a aplicação
CMD ["./frontend-server"] 