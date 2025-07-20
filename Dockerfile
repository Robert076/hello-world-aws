FROM golang:1.24-alpine AS build

WORKDIR /src

COPY go.mod  .

COPY . .

# CGO_ENABLED=0 means a static build, so there is no dynamic linking

RUN CGO_ENABLED=0 GOOS=linux go build -o hello-world ./cmd/hello-world-aws

FROM alpine:edge

WORKDIR /src

COPY --from=build /src/hello-world .

RUN chmod +x /src/hello-world

RUN apk --no-cache add ca-certificates

EXPOSE 8080

ENTRYPOINT [ "/src/hello-world" ]