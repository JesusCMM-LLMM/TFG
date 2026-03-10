# NIVEL 1: LA BASE (Dependencias totales)
# ==========================================
FROM node:20-alpine AS base
WORKDIR /app

# Copiamos los archivos de definición de paquetes
COPY package*.json ./

# Instalamos TODO (incluidas las "devDependencies" como TypeScript y el CLI de Nest)
# Las necesitamos para poder compilar más adelante o para el hot-reload en local.
RUN npm install

# NIVEL 2: DESARROLLO (Lo que usarán los Devs)
# ==========================================
FROM base AS development

# Copiamos el código fuente
COPY . .

# NestJS corre por defecto en el puerto 3000
EXPOSE 3000

# El comando mágico de NestJS que escucha cambios y reinicia el servidor al vuelo
CMD ["npm", "run", "start:dev"]

# NIVEL 3: EL CONSTRUCTOR (La fábrica de JavaScript)
# ==========================================
FROM base AS builder

COPY . .

# Este comando coge todo el TypeScript (/src) y lo compila a JavaScript 
# puro y optimizado, guardándolo en una nueva carpeta llamada /dist.
RUN npm run build

# NIVEL 4: PRODUCCIÓN (Seguridad y Rendimiento)
# ==========================================
# Volvemos a empezar desde una imagen limpia de Alpine
FROM node:20-alpine AS production
WORKDIR /app

# Copiamos los package.json OTRA VEZ en este entorno limpio
COPY package*.json ./

# Para más seguridad, "npm ci" es más estricto que "npm install". 
RUN npm ci --omit=dev

# Con omit=dev, nos quitamos node_modules que puede pesar 400 MB porque tiene compiladores, 
# linters (ESLint), librerías de test (Jest), etc.

# Copiamos SOLO la carpeta /dist (el código JS compilado) desde el Nivel 3.
# El código fuente original en TypeScript (.ts) se queda atrás y no llega a producción
COPY --from=builder /app/dist ./dist

# Exponemos el puerto
EXPOSE 3000

# En producción NO usamos "npm run start". Ejecutamos directamente el binario 
# de Node sobre el archivo principal. Es muchísimo más rápido y consume menos RAM.
CMD ["node", "dist/main.js"]

# Ejecutar node directamente sobre 
# el archivo compilado es la forma más pura y eficiente de levantar la API.