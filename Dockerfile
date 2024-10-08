# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install git and templ
RUN apk add --no-cache git && \
    go install github.com/a-h/templ/cmd/templ@latest

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies
RUN go mod download

# Copy the source code
COPY *.go *.templ ./

# Generate Go code from templ files
RUN templ generate

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Final stage
FROM alpine:latest  

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the pre-built binary file from the previous stage
COPY --from=builder /app/main .

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./main"]
