.PHONY: help infra-up infra-down infra-restart infra-logs infra-clean
.PHONY: deps contracts-build contracts-test contracts-compile typechain
.PHONY: dev backend backend-worker frontend
.PHONY: db-migrate db-migrate-up db-migrate-down db-reset
.PHONY: deploy-sepolia fund-pool verify-contract
.PHONY: health docker-status

# ─────────────────────────────────────────────────────────────────────────────
# Defaults
# ─────────────────────────────────────────────────────────────────────────────
COMPOSE_FILE := docker-compose.yml
COMPOSE_ENV  := docker.env

# ─────────────────────────────────────────────────────────────────────────────
# Help
# ─────────────────────────────────────────────────────────────────────────────

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# ─────────────────────────────────────────────────────────────────────────────
# Infrastructure
# ─────────────────────────────────────────────────────────────────────────────

infra-up: ## Start all infrastructure services (Postgres, Redis, Kafka, MinIO)
	docker compose --env-file $(COMPOSE_ENV) up -d
	@echo "Waiting for services to be healthy..."
	@sleep 5 && docker compose --env-file $(COMPOSE_ENV) ps

infra-down: ## Stop all infrastructure services
	docker compose --env-file $(COMPOSE_ENV) down

infra-restart: infra-down infra-up ## Restart all infrastructure services

infra-logs: ## Tail logs from all infrastructure services
	docker compose --env-file $(COMPOSE_ENV) logs -f

infra-clean: ## Stop services AND remove volumes (loses all data!)
	docker compose --env-file $(COMPOSE_ENV) down -v

docker-status: ## Show status of all Docker services
	docker compose --env-file $(COMPOSE_ENV) ps

# ─────────────────────────────────────────────────────────────────────────────
# Dependencies
# ─────────────────────────────────────────────────────────────────────────────

deps: ## Install all workspace dependencies
	yarn install

# ─────────────────────────────────────────────────────────────────────────────
# Contracts
# ─────────────────────────────────────────────────────────────────────────────

contracts-build: ## Build contracts with Foundry (ABI + evm)
	forge build

contracts-test: ## Run Foundry tests
	forge test -vv

contracts-compile: ## Compile with Hardhat (for typechain input)
	cd apps/contracts && forge build && yarn compile

typechain: ## Generate TypeScript bindings from compiled artifacts
	cd apps/contracts && yarn typechain:gen

# shorthand: build + compile + typechain in one shot
contracts-full: contracts-build contracts-compile typechain ## Full contract pipeline: build + compile + typechain

# ─────────────────────────────────────────────────────────────────────────────
# Database (Postgres must be running)
# ─────────────────────────────────────────────────────────────────────────────

db-migrate: ## Generate a new TypeORM migration (pass NAME=SomeName)
	cd apps/backend && yarn migration:generate src/migrations/$(NAME)

db-migrate-up: ## Run all pending migrations
	cd apps/backend && yarn migration:up

db-migrate-down: ## Roll back last migration
	cd apps/backend && yarn migration:down

db-reset: db-migrate-down db-migrate-up ## Full reset: rollback then re-apply

# ─────────────────────────────────────────────────────────────────────────────
# Dev servers
# ─────────────────────────────────────────────────────────────────────────────

dev: deps infra-up contracts-full db-migrate-up ## Full local setup: deps + infra + contracts + migrations
	@echo ""
	@echo "Ready! Start services with:"
	@echo "  make backend       # API server on :3001"
	@echo "  make backend-worker # Settlement worker on :3002"
	@echo "  make frontend      # Next.js on :3000"

backend: ## Start NestJS API server
	cd apps/backend && yarn dev

backend-worker: ## Start settlement/price worker
	cd apps/backend && yarn dev:worker

frontend: ## Start Next.js frontend
	cd apps/frontend && yarn dev

# ─────────────────────────────────────────────────────────────────────────────
# Deploy
# ─────────────────────────────────────────────────────────────────────────────

deploy-sepolia: ## Deploy contracts to BASE Sepolia
	cd apps/contracts && yarn hardhat run scripts/deploy.ts --network base-sepolia

fund-pool: ## Fund PayoutPool on Sepolia (amount in ETH, e.g. make fund-pool AMOUNT=0.5)
	cd apps/contracts && yarn hardhat run scripts/fund-pool.ts --network base-sepolia -- --amount $(or $(AMOUNT),0.5)

verify-contract: ## Verify a contract on Basescan (pass ADDR=0x... and CHAIN=base-sepolia)
	cd apps/contracts && yarn hardhat verify --network $(or $(CHAIN),base-sepolia) $(ADDR) $(ARGS)

# ─────────────────────────────────────────────────────────────────────────────
# Health checks
# ─────────────────────────────────────────────────────────────────────────────

health: docker-status ## Show health of all services
	@echo ""
	@echo "── Redis ──────────────────────────────────"
	@docker compose --env-file $(COMPOSE_ENV) exec -T redis redis-cli -a foobared ping 2>/dev/null || echo "Redis: not running"
	@echo ""
	@echo "── Kafka ─────────────────────────────────"
	@docker compose --env-file $(COMPOSE_ENV) exec -T kafka kafka-topics --bootstrap-server localhost:29092 --list 2>/dev/null || echo "Kafka: not running"
	@echo ""
	@echo "── MinIO ─────────────────────────────────"
	@docker compose --env-file $(COMPOSE_ENV) exec -T minio mc ready local 2>/dev/null || echo "MinIO: not running"
