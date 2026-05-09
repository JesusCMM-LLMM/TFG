# Infraestructura de microservicios en AWS EKS
### TFG · 2º ASIR · Jesús Carlos Mora Mesa

> Implementación, automatización y gestión de una infraestructura de microservicios en AWS EKS con un enfoque basado en **Terraform** y **Portainer**.

---

## Índice

- [Descripción](#-descripción)
- [Arquitectura](#-arquitectura)
- [Stack Tecnológico](#-stack-tecnológico)
- [Estructura del Repositorio](#-estructura-del-repositorio)
- [Requisitos Previos](#-requisitos-previos)
- [Puesta en Marcha Local](#-puesta-en-marcha-local)
- [Pipeline CI/CD](#-pipeline-cicd)
- [Despliegue en AWS EKS](#-despliegue-en-aws-eks)
- [Gestión con Portainer](#-gestión-con-portainer)

---

## Descripción

Este proyecto implementa una infraestructura completa de **microservicios Cloud Native** siguiendo el ciclo de vida completo del software: desde el entorno de desarrollo local hasta el despliegue en producción en la nube de Amazon Web Services.

La arquitectura adopta un enfoque **Monorepo** con separación estricta de contextos (frontend/backend), orquestación local mediante Docker Compose, integración continua con GitHub Actions y despliegue automatizado en un clúster **Amazon EKS** aprovisionado con **Terraform**.

---

## Arquitectura

```
Usuario Final (navegador · DNS ELB · puerto 80)
        │
        ▼
┌─────────────────────────────────────────────────────────┐
│              AWS Cloud – eu-west-1                      │
│         Infraestructura aprovisionada con Terraform     │
│                                                         │
│  VPC 10.0.0.0/16 · NAT Gateway · 2 AZs                  │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Subred Pública · Ingress NLB                    │   │
│  └──────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Amazon EKS – tfg-cluster (v1.30)                │   │
│  │  Nodos t3.small × 3 · Subred Privada             │   │
│  │                                                  │   │
│  │  namespace: proyecto-tfg-2026                    │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────────────┐  │   │
│  │  │ Frontend │ │ Backend  │ │    PostgreSQL     │ │   │
│  │  │Vue · Nginx│ │NestJS API│ │   EBS PVC × 1    │ │   │
│  │  │  × 2     │ │  × 2     │ └──────────────────┘  │   │
│  │  └──────────┘ └──────────┘                       │   │
│  │  HPA: mín. 2 / máx. 6 réplicas · escalado por CPU│   │
│  │  ConfigMaps + Secrets                            │   │
│  └──────────────────────────────────────────────────┘   │
│                                                  ▲      │
│                                            Portainer    │
└─────────────────────────────────────────────────────────┘
        ▲
        │  commit → lint · test → imagen docker → terraform
        │
┌───────────────────────────────────────────┐
│  GitHub Actions – Pipeline CI/CD          │
│  quality-checks → build-scan-push         │
│  Trivy · Docker Buildx · Docker Hub       │
└───────────────────────────────────────────┘
        ▲
        │ git push
┌───────────────────────────────────────────┐
│  Entorno local del desarrollador          │
│  Docker Compose · make.bat                │
└───────────────────────────────────────────┘
```

---

## Stack Tecnológico

| Capa | Tecnología |
|---|---|
| **Frontend** | Vue 3 · Vite · Nginx · Oxlint | Solo es un placeholder
| **Backend** | NestJS · TypeScript · PostgreSQL | Solo es un placeholder
| **Contenedores** | Docker · Docker Compose · Multi-stage Builds |
| **CI/CD** | GitHub Actions · Trivy (DevSecOps) · Docker Hub |
| **IaC** | Terraform · AWS Provider `~> 5.0` |
| **Orquestación** | Amazon EKS (Kubernetes 1.30) · Helm |
| **Red** | VPC · NAT Gateway · Ingress Nginx · NLB |
| **Persistencia** | Amazon EBS · CSI Driver · PVC |
| **Gestión visual** | Portainer Community Edition |
| **Escalado** | Horizontal Pod Autoscaler (HPA) |

---

## Estructura del Repositorio

```
TFG/
├── back-src/                  # API Backend (NestJS)
│   ├── src/
│   ├── test/
│   ├── package.json
│   └── tsconfig.json
├── front-src/                 # Cliente Frontend (Vue 3 + Vite)
│   ├── src/
│   ├── public/
│   └── package.json
├── docker/                    # Dockerfiles por servicio
│   ├── frontend/Dockerfile    # Multi-stage: dev · build · production
│   └── backend/Dockerfile
├── k8s-manifests/             # Manifiestos de Kubernetes (YAML)
│   ├── 00-namespace/
│   ├── 01-config/             # ConfigMaps + Secrets
│   ├── 02-database/           # PostgreSQL + EBS PVC
│   ├── 03-backend/            # Deployment + Service
│   ├── 04-frontend/           # Deployment + Service
│   ├── 05-routing/            # Ingress rules
│   └── 06-hpa/                # Horizontal Pod Autoscaler
├── terraform-eks/             # Infraestructura como Código
│   ├── main.tf                # Proveedor AWS + configuración global
│   ├── vpc.tf                 # VPC · Subnets · NAT Gateway
│   └── eks.tf                 # Clúster EKS + Node Groups
├── .github/workflows/
│   └── pipeline.yml           # CI/CD Pipeline (GitHub Actions)
├── docker-compose.yml         # Stack de desarrollo principal
├── docker-compose.bd.yml      # Contenedor de base de datos (independiente)
├── docker-compose.prod.yml    # Overrides de producción
├── .env.example               # Plantilla de variables de entorno
├── .gitignore
└── make.bat                   # Script de automatización DX (Windows)
```

---

## Requisitos Previos

**Para desarrollo local:**
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Git

**Para el despliegue en AWS:**
- [AWS CLI](https://aws.amazon.com/cli/) configurado con `aws configure`
- [Terraform CLI](https://developer.hashicorp.com/terraform/install) `>= 1.0`
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

---

## Puesta en Marcha Local

**1. Clonar el repositorio y configurar el entorno:**
```bash
git clone https://github.com/JesusCMM-LLMM/TFG.git
cd TFG
cp .env.example .env
# Editar .env con los valores correspondientes
```

**2. Levantar el entorno de desarrollo completo:**
```bash
.\make.bat up
```

El script levanta en cascada: la red externa de Docker → base de datos → aplicación (frontend + backend + Nginx + Adminer + Dozzle).

**Comandos disponibles:**

| Comando | Descripción |
|---|---|
| `.\make.bat up` | Levanta el entorno de desarrollo completo |
| `.\make.bat down` | Para todos los servicios |
| `.\make.bat up-prod` | Levanta el stack de producción local |
| `.\make.bat down-prod` | Para el stack de producción |
| `.\make.bat sync-back` | Sincroniza dependencias del backend (desde el contenedor Linux) |
| `.\make.bat sync-front` | Sincroniza dependencias del frontend (desde el contenedor Linux) |

> ⚠️ **Importante:** Siempre instala dependencias desde dentro del contenedor para garantizar compatibilidad de binarios nativos con Linux:
> ```bash
> docker compose exec frontend npm install <paquete>
> docker compose exec backend npm install <paquete>
> ```

---

## Pipeline CI/CD

El flujo de integración continua se activa automáticamente en cada `push` y está dividido en dos fases:

**Fase 1 — Control de Calidad** *(todas las ramas)*
- Análisis estático con Oxlint
- Ejecución de tests unitarios
- Bloquea el merge si alguna validación falla

**Fase 2 — Construcción y Publicación** *(solo rama `main`)*
- Build de imágenes Docker apuntando al `target: production` del Dockerfile multi-stage
- Escaneo de vulnerabilidades con **Trivy** (aborta si detecta CVEs CRITICAL/HIGH)
- Etiquetado dinámico: `latest` + SHA del commit (trazabilidad total)
- Push a Docker Hub

Las credenciales se gestionan mediante **GitHub Secrets**, nunca en el repositorio.
Preparado para añadir más jobs (pasos) a futuro.

---

## Despliegue en AWS EKS

**1. Aprovisionar la infraestructura con Terraform:**
```bash
cd terraform-eks
terraform init
terraform plan
terraform apply
```
Esto crea automáticamente: VPC · Subnets públicas y privadas · NAT Gateway · Clúster EKS (v1.30) · Node Group (`t3.small` × 3).

**2. Conectar kubectl al clúster:**
```bash
aws eks update-kubeconfig --region eu-west-1 --name tfg-cluster
kubectl get nodes
```

**3. Aplicar los manifiestos de Kubernetes de forma secuencial:**
```bash
kubectl apply -f k8s-manifests/00-namespace/
kubectl apply -f k8s-manifests/01-config/
kubectl apply -f k8s-manifests/02-database/
kubectl apply -f k8s-manifests/03-backend/
kubectl apply -f k8s-manifests/04-frontend/
kubectl apply -f k8s-manifests/05-routing/
kubectl apply -f k8s-manifests/06-hpa/
```

**4. Obtener la URL pública:**
```bash
kubectl get ingress -n proyecto-tfg-2026
```

**Para destruir la infraestructura y evitar costes:**
```bash
terraform destroy
```

---

## Gestión con Portainer

Portainer se instala en el clúster mediante Helm para gestión visual:

```bash
helm repo add portainer https://portainer.github.io/k8s/
helm repo update
helm install portainer portainer/portainer \
  -n portainer --create-namespace \
  --set service.type=LoadBalancer
```

Accede mediante la URL DNS asignada por AWS en el puerto `9443` (HTTPS).

> ⚠️ Configura la contraseña de administrador en los primeros **5 minutos** tras el despliegue. Si se agota el tiempo, ejecuta `kubectl rollout restart deployment/portainer -n portainer`.

Portainer permite desde el navegador: monitorizar el estado de todos los Pods · consultar logs en tiempo real · abrir consolas interactivas · gestionar Ingress y Services · escalar réplicas manualmente.

---

## Variables de Entorno

Copia `.env.example` como `.env` y rellena los valores. **Nunca subas el `.env` real al repositorio.**

```env
NODE_ENV=

# PostgreSQL
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=

# NestJS Backend
DB_TYPE=
DB_HOST=          # Nombre del servicio en docker-compose, no localhost
DB_PORT=
DB_USERNAME=
DB_PASSWORD=
DB_DATABASE=

# Vue / Vite Frontend (deben empezar por VITE_)
VITE_API_URL=
```


