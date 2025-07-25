# Dockerfile (only if needed for Raspberry Pi ARM64)
FROM node:18-bullseye

ENV N8N_VERSION=1.46.0

RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN npm install -g n8n@$N8N_VERSION

EXPOSE 5678

ENTRYPOINT ["n8n"]

