# Canonical Configs

## Dockerfile (single file, multi-stage)

```dockerfile
FROM oven/bun:1 AS base
WORKDIR /app
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile

FROM base AS dev
COPY . .
EXPOSE 3001 5173

FROM base AS prod
COPY . .
RUN bun run build
EXPOSE 3001
CMD ["bun", "run", "start"]
```

**Gotchas:**
- `COPY . .` before `bun install` busts cache on every code change — always install deps first
- Missing `--frozen-lockfile` → non-deterministic installs
- Not setting `EXPOSE` for all ports used in compose

## docker-compose.yml

```yaml
services:
  db:
    image: postgres:18.3
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - db_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 10
    networks:
      - app_network

  backend:
    build:
      context: .
      dockerfile: Dockerfile
      target: dev
    command: bun run dev:backend
    restart: unless-stopped
    env_file:
      - .env
    ports:
      - "3001:3001"
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      db:
        condition: service_healthy
    networks:
      - app_network

  frontend:
    build:
      context: .
      dockerfile: Dockerfile
      target: dev
    command: bun run dev:frontend
    env_file:
      - .env
    ports:
      - "5173:5173"
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      - backend
    networks:
      - app_network

volumes:
  db_data:

networks:
  app_network:
    driver: bridge
```
