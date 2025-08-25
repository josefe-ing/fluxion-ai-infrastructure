# =============================================================================
# FLUXION AI - MAKEFILE
# =============================================================================
# Comandos para desarrollo, testing y deployment

.PHONY: help setup dev dev-logs build test clean docker-clean reset install-backend install-ai install-frontend install-all lint format check-deps security-scan backup

# Variables
DOCKER_COMPOSE = docker-compose
DOCKER_COMPOSE_PROD = docker-compose -f docker-compose.prod.yml
BACKEND_DIR = backend
AI_ENGINE_DIR = ai-engine
FRONTEND_DIR = frontend

# Colors for pretty output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

# =============================================================================
# HELP & DOCUMENTATION
# =============================================================================

help: ## Mostrar esta ayuda
	@echo "${GREEN}===============================================${NC}"
	@echo "${GREEN}           FLUXION AI - COMANDOS               ${NC}"
	@echo "${GREEN}===============================================${NC}"
	@echo ""
	@echo "${BLUE}🚀 Comandos principales:${NC}"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  ${GREEN}%-20s${NC} %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "${YELLOW}📝 Ejemplos de uso:${NC}"
	@echo "  make setup     # Configuración inicial completa"
	@echo "  make dev       # Iniciar desarrollo"
	@echo "  make test      # Ejecutar todos los tests"
	@echo "  make reset     # Reiniciar completamente"
	@echo ""

# =============================================================================
# SETUP & INSTALLATION
# =============================================================================

setup: ## Configuración inicial completa del proyecto
	@echo "${GREEN}🚀 Iniciando setup completo de Fluxion AI...${NC}"
	@$(MAKE) check-deps
	@$(MAKE) create-env
	@$(MAKE) install-all
	@$(MAKE) docker-build
	@$(MAKE) db-setup
	@echo "${GREEN}✅ Setup completado! Usa 'make dev' para iniciar desarrollo.${NC}"

check-deps: ## Verificar dependencias instaladas
	@echo "${BLUE}🔍 Verificando dependencias...${NC}"
	@command -v node >/dev/null 2>&1 || { echo "${RED}❌ Node.js no encontrado${NC}"; exit 1; }
	@command -v python >/dev/null 2>&1 || { echo "${RED}❌ Python no encontrado${NC}"; exit 1; }
	@command -v docker >/dev/null 2>&1 || { echo "${RED}❌ Docker no encontrado${NC}"; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo "${RED}❌ Git no encontrado${NC}"; exit 1; }
	@echo "${GREEN}✅ Todas las dependencias están instaladas${NC}"

create-env: ## Crear archivo .env desde .env.example
	@if [ ! -f .env ]; then \
		echo "${YELLOW}📝 Creando archivo .env...${NC}"; \
		cp .env.example .env; \
		echo "${GREEN}✅ Archivo .env creado. Revisa y ajusta las variables.${NC}"; \
	else \
		echo "${BLUE}ℹ️ Archivo .env ya existe.${NC}"; \
	fi

install-all: ## Instalar dependencias de todos los servicios
	@echo "${BLUE}📦 Instalando dependencias...${NC}"
	@$(MAKE) install-backend
	@$(MAKE) install-ai
	@$(MAKE) install-frontend

install-backend: ## Instalar dependencias del backend
	@echo "${BLUE}📦 Instalando dependencias del backend...${NC}"
	@if [ -f $(BACKEND_DIR)/package.json ]; then \
		cd $(BACKEND_DIR) && npm install; \
	else \
		echo "${YELLOW}⚠️ Backend package.json no encontrado, saltando...${NC}"; \
	fi

install-ai: ## Instalar dependencias del AI engine
	@echo "${BLUE}📦 Instalando dependencias del AI engine...${NC}"
	@if [ -f $(AI_ENGINE_DIR)/pyproject.toml ]; then \
		cd $(AI_ENGINE_DIR) && python -m pip install -e .; \
	elif [ -f $(AI_ENGINE_DIR)/requirements.txt ]; then \
		cd $(AI_ENGINE_DIR) && pip install -r requirements.txt; \
	else \
		echo "${YELLOW}⚠️ AI engine requirements no encontrados, saltando...${NC}"; \
	fi

install-frontend: ## Instalar dependencias del frontend
	@echo "${BLUE}📦 Instalando dependencias del frontend...${NC}"
	@if [ -f $(FRONTEND_DIR)/package.json ]; then \
		cd $(FRONTEND_DIR) && npm install; \
	else \
		echo "${YELLOW}⚠️ Frontend package.json no encontrado, saltando...${NC}"; \
	fi

# =============================================================================
# DEVELOPMENT
# =============================================================================

dev: ## Iniciar desarrollo (todos los servicios)
	@echo "${GREEN}🚀 Iniciando servicios de desarrollo...${NC}"
	@$(DOCKER_COMPOSE) up -d postgres redis pubsub-emulator
	@sleep 5
	@echo "${GREEN}✅ Servicios base iniciados. Logs disponibles con 'make dev-logs'${NC}"
	@echo "${BLUE}📡 Servicios disponibles:${NC}"
	@echo "  • PostgreSQL: localhost:5432"
	@echo "  • Redis: localhost:6379" 
	@echo "  • Pub/Sub Emulator: localhost:8085"
	@echo ""
	@echo "${YELLOW}💡 Para iniciar backend/AI/frontend, desarrolla en cada directorio o usa:${NC}"
	@echo "  make dev-backend"
	@echo "  make dev-ai"
	@echo "  make dev-frontend"

dev-full: ## Iniciar desarrollo completo (incluyendo aplicaciones)
	@echo "${GREEN}🚀 Iniciando desarrollo completo...${NC}"
	@$(DOCKER_COMPOSE) up -d

dev-logs: ## Ver logs de desarrollo en tiempo real
	@echo "${BLUE}📋 Logs de desarrollo (Ctrl+C para salir):${NC}"
	@$(DOCKER_COMPOSE) logs -f

dev-backend: ## Iniciar solo el backend en modo desarrollo
	@echo "${GREEN}🚀 Iniciando backend...${NC}"
	@cd $(BACKEND_DIR) && npm run dev

dev-ai: ## Iniciar solo el AI engine en modo desarrollo  
	@echo "${GREEN}🤖 Iniciando AI engine...${NC}"
	@cd $(AI_ENGINE_DIR) && python -m uvicorn src.main:app --reload --host 0.0.0.0 --port 8000

dev-frontend: ## Iniciar solo el frontend en modo desarrollo
	@echo "${GREEN}💻 Iniciando frontend...${NC}"
	@cd $(FRONTEND_DIR) && npm run dev

# =============================================================================
# DOCKER OPERATIONS
# =============================================================================

docker-build: ## Construir todas las imágenes Docker
	@echo "${BLUE}🔨 Construyendo imágenes Docker...${NC}"
	@$(DOCKER_COMPOSE) build --no-cache

docker-up: ## Levantar todos los servicios Docker
	@echo "${GREEN}🐳 Levantando servicios Docker...${NC}"
	@$(DOCKER_COMPOSE) up -d

docker-down: ## Bajar todos los servicios Docker
	@echo "${YELLOW}🔻 Bajando servicios Docker...${NC}"
	@$(DOCKER_COMPOSE) down

docker-restart: ## Reiniciar todos los servicios Docker
	@$(MAKE) docker-down
	@$(MAKE) docker-up

docker-clean: ## Limpiar containers, volúmenes e imágenes Docker
	@echo "${RED}🧹 Limpiando Docker...${NC}"
	@$(DOCKER_COMPOSE) down -v --remove-orphans
	@docker system prune -f
	@docker volume prune -f

docker-logs: ## Ver logs de Docker
	@$(DOCKER_COMPOSE) logs -f

# =============================================================================
# DATABASE OPERATIONS
# =============================================================================

db-setup: ## Configurar base de datos (migraciones + seeds)
	@echo "${BLUE}🗄️ Configurando base de datos...${NC}"
	@$(MAKE) db-migrate
	@$(MAKE) db-seed

db-migrate: ## Ejecutar migraciones de base de datos
	@echo "${BLUE}📊 Ejecutando migraciones...${NC}"
	@if [ -f $(BACKEND_DIR)/package.json ]; then \
		cd $(BACKEND_DIR) && npm run migrate; \
	else \
		echo "${YELLOW}⚠️ Migraciones no disponibles aún${NC}"; \
	fi

db-seed: ## Cargar datos de prueba
	@echo "${BLUE}🌱 Cargando datos de prueba...${NC}"
	@if [ -f $(BACKEND_DIR)/package.json ]; then \
		cd $(BACKEND_DIR) && npm run seed; \
	else \
		echo "${YELLOW}⚠️ Seeds no disponibles aún${NC}"; \
	fi

db-reset: ## Resetear base de datos completa
	@echo "${RED}🗑️ Reseteando base de datos...${NC}"
	@$(DOCKER_COMPOSE) down -v postgres
	@$(DOCKER_COMPOSE) up -d postgres
	@sleep 10
	@$(MAKE) db-setup

db-backup: ## Crear backup de la base de datos
	@echo "${BLUE}💾 Creando backup...${NC}"
	@mkdir -p backups
	@$(DOCKER_COMPOSE) exec postgres pg_dump -U fluxion_user fluxion_dev > backups/backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "${GREEN}✅ Backup creado en backups/${NC}"

# =============================================================================
# TESTING
# =============================================================================

test: ## Ejecutar todos los tests
	@echo "${BLUE}🧪 Ejecutando todos los tests...${NC}"
	@$(MAKE) test-backend
	@$(MAKE) test-ai
	@$(MAKE) test-frontend

test-backend: ## Ejecutar tests del backend
	@echo "${BLUE}🧪 Tests del backend...${NC}"
	@if [ -f $(BACKEND_DIR)/package.json ]; then \
		cd $(BACKEND_DIR) && npm test; \
	else \
		echo "${YELLOW}⚠️ Tests del backend no disponibles aún${NC}"; \
	fi

test-ai: ## Ejecutar tests del AI engine
	@echo "${BLUE}🧪 Tests del AI engine...${NC}"
	@if [ -f $(AI_ENGINE_DIR)/pyproject.toml ]; then \
		cd $(AI_ENGINE_DIR) && python -m pytest; \
	else \
		echo "${YELLOW}⚠️ Tests del AI engine no disponibles aún${NC}"; \
	fi

test-frontend: ## Ejecutar tests del frontend
	@echo "${BLUE}🧪 Tests del frontend...${NC}"
	@if [ -f $(FRONTEND_DIR)/package.json ]; then \
		cd $(FRONTEND_DIR) && npm test; \
	else \
		echo "${YELLOW}⚠️ Tests del frontend no disponibles aún${NC}"; \
	fi

test-coverage: ## Ejecutar tests con coverage
	@echo "${BLUE}📊 Ejecutando tests con coverage...${NC}"
	@$(MAKE) test-backend-coverage
	@$(MAKE) test-ai-coverage

test-backend-coverage: ## Coverage del backend
	@if [ -f $(BACKEND_DIR)/package.json ]; then \
		cd $(BACKEND_DIR) && npm run test:coverage; \
	fi

test-ai-coverage: ## Coverage del AI engine
	@if [ -f $(AI_ENGINE_DIR)/pyproject.toml ]; then \
		cd $(AI_ENGINE_DIR) && python -m pytest --cov=src; \
	fi

# =============================================================================
# CODE QUALITY
# =============================================================================

lint: ## Ejecutar linting en todos los servicios
	@echo "${BLUE}🔍 Ejecutando linting...${NC}"
	@$(MAKE) lint-backend
	@$(MAKE) lint-ai  
	@$(MAKE) lint-frontend

lint-backend: ## Linting del backend
	@if [ -f $(BACKEND_DIR)/package.json ]; then \
		cd $(BACKEND_DIR) && npm run lint; \
	fi

lint-ai: ## Linting del AI engine
	@if [ -f $(AI_ENGINE_DIR)/pyproject.toml ]; then \
		cd $(AI_ENGINE_DIR) && python -m black --check src && python -m mypy src; \
	fi

lint-frontend: ## Linting del frontend
	@if [ -f $(FRONTEND_DIR)/package.json ]; then \
		cd $(FRONTEND_DIR) && npm run lint; \
	fi

format: ## Formatear código automáticamente
	@echo "${BLUE}✨ Formateando código...${NC}"
	@$(MAKE) format-backend
	@$(MAKE) format-ai
	@$(MAKE) format-frontend

format-backend: ## Formatear backend
	@if [ -f $(BACKEND_DIR)/package.json ]; then \
		cd $(BACKEND_DIR) && npm run format; \
	fi

format-ai: ## Formatear AI engine
	@if [ -f $(AI_ENGINE_DIR)/pyproject.toml ]; then \
		cd $(AI_ENGINE_DIR) && python -m black src; \
	fi

format-frontend: ## Formatear frontend
	@if [ -f $(FRONTEND_DIR)/package.json ]; then \
		cd $(FRONTEND_DIR) && npm run format; \
	fi

# =============================================================================
# PRODUCTION
# =============================================================================

build: ## Build de producción
	@echo "${BLUE}🔨 Construyendo para producción...${NC}"
	@$(DOCKER_COMPOSE_PROD) build

deploy-staging: ## Deploy a staging
	@echo "${YELLOW}🚀 Deploy a staging...${NC}"
	@$(DOCKER_COMPOSE_PROD) up -d
	@echo "${GREEN}✅ Deploy a staging completado${NC}"

deploy-prod: ## Deploy a producción (requiere confirmación)
	@echo "${RED}⚠️ Deploy a PRODUCCIÓN${NC}"
	@read -p "¿Estás seguro? (yes/no): " confirm && [ $$confirm = yes ]
	@echo "${GREEN}🚀 Deploying a producción...${NC}"
	@$(DOCKER_COMPOSE_PROD) up -d
	@echo "${GREEN}✅ Deploy a producción completado${NC}"

# =============================================================================
# MAINTENANCE & UTILITIES
# =============================================================================

clean: ## Limpiar archivos temporales y cache
	@echo "${BLUE}🧹 Limpiando archivos temporales...${NC}"
	@find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "coverage" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".coverage" -delete 2>/dev/null || true
	@rm -rf logs/*.log 2>/dev/null || true
	@echo "${GREEN}✅ Limpieza completada${NC}"

reset: ## Reset completo del proyecto (⚠️  DESTRUCTIVO)
	@echo "${RED}⚠️ RESET COMPLETO - Esto eliminará todos los datos${NC}"
	@read -p "¿Estás seguro? (yes/no): " confirm && [ $$confirm = yes ]
	@$(MAKE) docker-clean
	@$(MAKE) clean
	@$(MAKE) setup
	@echo "${GREEN}✅ Reset completado${NC}"

logs: ## Ver todos los logs
	@echo "${BLUE}📋 Mostrando logs...${NC}"
	@$(DOCKER_COMPOSE) logs --tail=100

status: ## Ver estado de todos los servicios
	@echo "${BLUE}📊 Estado de servicios:${NC}"
	@$(DOCKER_COMPOSE) ps
	@echo ""
	@echo "${BLUE}🔍 Health checks:${NC}"
	@curl -s http://localhost:5432 > /dev/null && echo "${GREEN}✅ PostgreSQL: OK${NC}" || echo "${RED}❌ PostgreSQL: ERROR${NC}"
	@curl -s http://localhost:6379 > /dev/null && echo "${GREEN}✅ Redis: OK${NC}" || echo "${RED}❌ Redis: ERROR${NC}"
	@curl -s http://localhost:8085 > /dev/null && echo "${GREEN}✅ Pub/Sub: OK${NC}" || echo "${RED}❌ Pub/Sub: ERROR${NC}"

security-scan: ## Escanear vulnerabilidades de seguridad
	@echo "${BLUE}🔒 Escaneando vulnerabilidades...${NC}"
	@if [ -f $(BACKEND_DIR)/package.json ]; then \
		cd $(BACKEND_DIR) && npm audit; \
	fi
	@if [ -f $(AI_ENGINE_DIR)/requirements.txt ]; then \
		cd $(AI_ENGINE_DIR) && python -m pip check; \
	fi
	@if [ -f $(FRONTEND_DIR)/package.json ]; then \
		cd $(FRONTEND_DIR) && npm audit; \
	fi

# =============================================================================
# DEVELOPMENT HELPERS
# =============================================================================

shell-backend: ## Abrir shell en container del backend
	@$(DOCKER_COMPOSE) exec backend /bin/bash

shell-ai: ## Abrir shell en container del AI engine
	@$(DOCKER_COMPOSE) exec ai-engine /bin/bash

shell-db: ## Abrir shell en PostgreSQL
	@$(DOCKER_COMPOSE) exec postgres psql -U fluxion_user -d fluxion_dev

shell-redis: ## Abrir shell en Redis
	@$(DOCKER_COMPOSE) exec redis redis-cli

# Default target
.DEFAULT_GOAL := help