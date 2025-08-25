#!/bin/bash

# =============================================================================
# FLUXION AI - MULTI-REPO SETUP SCRIPT
# Convierte el monorepo actual en múltiples repositorios independientes
# =============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 FLUXION AI - MULTI-REPO SETUP${NC}"
echo -e "${BLUE}=================================${NC}"

# Variables
GITHUB_USERNAME="josefe-ing"
PARENT_DIR="../fluxion-repos"
CURRENT_DIR=$(pwd)

# Crear directorio padre
echo -e "\n${YELLOW}📁 Creando estructura de directorios...${NC}"
mkdir -p "$PARENT_DIR"
cd "$PARENT_DIR"

# Repositorios a crear
repos=(
    "fluxion-ai-backend"
    "fluxion-ai-ai-engine" 
    "fluxion-ai-frontend"
    "fluxion-ai-infrastructure"
)

echo -e "\n${GREEN}✅ Repositorios a crear:${NC}"
for repo in "${repos[@]}"; do
    echo "  - $repo"
done

# Función para crear repositorio
create_repo() {
    local repo_name=$1
    local source_dir=$2
    
    echo -e "\n${BLUE}📦 Creando $repo_name...${NC}"
    
    # Crear directorio
    mkdir -p "$repo_name"
    cd "$repo_name"
    
    # Inicializar Git
    git init
    git branch -m main
    
    # Copiar archivos desde monorepo
    if [ -d "$CURRENT_DIR/$source_dir" ]; then
        cp -r "$CURRENT_DIR/$source_dir"/* .
    fi
    
    # Copiar archivos comunes
    cp "$CURRENT_DIR/.gitignore" . 2>/dev/null || true
    cp "$CURRENT_DIR/.env.example" . 2>/dev/null || true
    
    # Crear README específico
    create_readme "$repo_name"
    
    # Git add y commit inicial
    git add .
    git commit -m "feat: initial commit for $repo_name

🚀 Initial setup from Fluxion AI monorepo migration
- Extracted $source_dir functionality  
- Multi-repo architecture for independent deployments
- Ready for CI/CD pipeline setup

Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
    
    # Configurar remote (comentado hasta crear repos en GitHub)
    # git remote add origin "git@github.com:$GITHUB_USERNAME/$repo_name.git"
    
    echo -e "${GREEN}✅ $repo_name creado exitosamente${NC}"
    cd ..
}

# Función para crear README específico
create_readme() {
    local repo_name=$1
    
    case $repo_name in
        "fluxion-ai-backend")
            cat > README.md << 'EOF'
# 🚀 Fluxion AI - Backend Service

Sistema de gestión de inventario con IA proactiva - Servicio Backend

## 🏗️ Arquitectura
- **Framework**: Node.js + TypeScript + Express
- **Puerto**: 3000
- **Base de datos**: PostgreSQL + TimescaleDB
- **Cache**: Redis
- **Autenticación**: JWT

## 🚀 Desarrollo

```bash
# Instalar dependencias
npm install

# Desarrollo
npm run dev

# Tests  
npm test

# Build
npm run build
```

## 📊 Endpoints Principales
- `GET /health` - Health check
- `POST /auth/login` - Autenticación
- `GET /api/inventory` - Inventario
- `GET /api/alerts` - Alertas proactivas

## 🔗 Servicios Relacionados
- AI Engine: Puerto 8000
- Frontend: Puerto 3001
- PostgreSQL: Puerto 5432
- Redis: Puerto 6379
EOF
            ;;
        "fluxion-ai-ai-engine")
            cat > README.md << 'EOF'
# 🤖 Fluxion AI - AI Engine

Sistema de Inteligencia Artificial para predicciones y alertas proactivas

## 🏗️ Arquitectura  
- **Framework**: Python + FastAPI
- **Puerto**: 8000
- **ML Stack**: Prophet, Pandas, NumPy
- **Agentes**: Multi-agent system

## 🚀 Desarrollo

```bash
# Crear entorno virtual
python -m venv venv
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Desarrollo
uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload

# Tests
pytest
```

## 🧠 Agentes IA
- **AlertAgent**: Detecta stockouts y anomalías
- **ForecastAgent**: Predicciones con Prophet
- **OptimizeAgent**: Optimización automática
- **ChatAgent**: Conversación natural

## 📊 Endpoints ML
- `POST /predict/demand` - Predicción de demanda
- `POST /analyze/inventory` - Análisis de inventario
- `GET /agents/status` - Estado de agentes
EOF
            ;;
        "fluxion-ai-frontend")
            cat > README.md << 'EOF'
# 🎨 Fluxion AI - Frontend Dashboard

Dashboard interactivo para gestión de inventario con IA

## 🏗️ Arquitectura
- **Framework**: React + TypeScript  
- **Styling**: Tailwind CSS
- **Puerto**: 3001
- **Charts**: Recharts
- **State**: Context API

## 🚀 Desarrollo

```bash
# Instalar dependencias
npm install

# Desarrollo
npm run dev

# Build
npm run build

# Tests
npm test
```

## 📊 Características
- Dashboard analytics en tiempo real
- Centro de alertas con priorización
- Gestión de inventario multi-tienda
- Responsive design
- Real-time updates via WebSocket

## 🔗 Integración
- Backend API: http://localhost:3000
- WebSocket: ws://localhost:3000
- AI Engine: Puerto 8000
EOF
            ;;
        "fluxion-ai-infrastructure")
            cat > README.md << 'EOF'
# 🏗️ Fluxion AI - Infrastructure

Configuraciones de infraestructura, deployment y DevOps

## 📁 Estructura

```
infrastructure/
├── docker/           # Dockerfiles y configs
├── kubernetes/       # K8s manifests
├── terraform/        # IaC para GCP
├── scripts/          # Scripts de deployment
└── ci-cd/           # GitHub Actions workflows
```

## 🐳 Docker

```bash
# Build todas las imágenes
make docker-build

# Deploy local con Docker Compose
docker-compose up -d

# Deploy producción
make deploy-prod
```

## ☁️ Google Cloud Platform

```bash
# Setup inicial GCP
make gcp-setup

# Deploy a Cloud Run
make deploy-staging
make deploy-prod
```

## 🚀 Servicios
- **Backend**: Node.js en Cloud Run
- **AI Engine**: Python en Cloud Run
- **Frontend**: React en Cloud Storage + CDN
- **Database**: Cloud SQL PostgreSQL
- **Cache**: Cloud Memorystore Redis
EOF
            ;;
    esac
}

# Crear cada repositorio
create_repo "fluxion-ai-backend" "backend"
create_repo "fluxion-ai-ai-engine" "ai-engine" 
create_repo "fluxion-ai-frontend" "frontend"

# Para infrastructure, copiar archivos específicos
echo -e "\n${BLUE}📦 Creando fluxion-ai-infrastructure...${NC}"
mkdir -p "fluxion-ai-infrastructure"
cd "fluxion-ai-infrastructure"

git init
git branch -m main

# Copiar archivos de infraestructura
cp -r "$CURRENT_DIR/docker" . 2>/dev/null || true
cp -r "$CURRENT_DIR/infrastructure" . 2>/dev/null || true  
cp -r "$CURRENT_DIR/scripts" . 2>/dev/null || true
cp "$CURRENT_DIR/docker-compose.yml" . 2>/dev/null || true
cp "$CURRENT_DIR/Makefile" . 2>/dev/null || true
cp "$CURRENT_DIR/.gitignore" . 2>/dev/null || true
cp "$CURRENT_DIR/.env.example" . 2>/dev/null || true

create_readme "fluxion-ai-infrastructure"

git add .
git commit -m "feat: initial infrastructure setup

🏗️ Multi-repo infrastructure configuration
- Docker configs and Compose files
- Kubernetes manifests  
- Terraform GCP setup
- CI/CD scripts and automation
- Makefile for development workflows

Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

cd ..

echo -e "\n${GREEN}🎉 MULTI-REPO SETUP COMPLETADO!${NC}"
echo -e "\n${YELLOW}📋 Próximos pasos:${NC}"
echo "1. Crear repositorios en GitHub:"
for repo in "${repos[@]}"; do
    echo "   - https://github.com/new → $repo"
done
echo ""
echo "2. Push inicial a cada repo:"
for repo in "${repos[@]}"; do
    echo "   cd $repo && git remote add origin git@github.com:$GITHUB_USERNAME/$repo.git"
    echo "   git push -u origin main"
done

echo -e "\n${BLUE}📁 Repositorios creados en: $(pwd)${NC}"
ls -la