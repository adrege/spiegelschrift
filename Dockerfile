FROM node:25-bookworm AS web-builder
WORKDIR /build
COPY web/package*.json ./
RUN npm ci
COPY web .
RUN npm run build

FROM golang:1.25-bookworm AS bin-builder
WORKDIR /build
COPY . .
RUN go build .

FROM debian:bookworm
RUN apt-get update && \
    apt-get install -y --no-install-recommends libreoffice && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=web-builder /build/dist /web/dist
COPY --from=bin-builder /build/adrege-spiegelschrift /usr/bin/adrege-spiegelschrift
EXPOSE 1235
CMD ["adrege-spiegelschrift"]
