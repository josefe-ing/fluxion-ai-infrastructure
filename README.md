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
