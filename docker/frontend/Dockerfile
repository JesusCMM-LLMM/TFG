# NIVEL 1: LA BASE
# ==========================================
FROM node:20-alpine AS base

# Definimos el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos SOLO los archivos de dependencias primero.
# Esto aprovecha la caché de Docker. Si el código cambia 
# pero el package.json no, Docker se salta el npm install y ahorra minutos.
COPY package*.json ./

# Instalamos todas las dependencias (incluyendo Vite, PrimeVue, etc.)
RUN npm install

# NIVEL 2: DESARROLLO (Lo que usarán los Devs)
# ==========================================
FROM base AS development

# Copiamos el resto del código fuente (aunque en desarrollo usaremos volúmenes, 
# se copia por seguridad y buenas prácticas)
COPY . .

# Exponemos el puerto por defecto de Vite
EXPOSE 5173

# Vite por defecto solo escucha en localhost (dentro del contenedor). 
# Al añadir "--host 0.0.0.0", le obligamos a escuchar en todas las interfaces de red
# para que tu navegador en Windows pueda ver la web.
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# NIVEL 3: EL CONSTRUCTOR (Solo para compilar)
# ==========================================
FROM base AS builder

COPY . .

# Ejecutamos el build de Vite. Esto coge todo el Vue/JS/CSS, lo comprime, 
# lo ofusca y genera una carpeta llamada /dist con HTML estático puro.
RUN npm run build

# NIVEL 4: PRODUCCIÓN (El despliegue final)
# ==========================================
FROM nginx:alpine-slim AS production

# Copiamos SOLO la carpeta /dist generada en el Nivel 3.
# Todo el Node.js, npm, archivos .vue y node_modules se quedan atrás y se destruyen.
COPY --from=builder /app/dist /usr/share/nginx/html

# Con esta línea, obligamos a Nginx a redirigir todo al index.html para que Vue gestione la ruta.
RUN echo 'server { listen 80; location / { root /usr/share/nginx/html; try_files $uri $uri/ /index.html; } }' > /etc/nginx/conf.d/default.conf
# Esto de arriba inyecta una configuración de Nginx al vuelo, evita errores con el hot reload
# Exponemos el puerto estándar web
EXPOSE 80

# Arrancamos Nginx en primer plano para que el contenedor no se apague
CMD ["nginx", "-g", "daemon off;"]