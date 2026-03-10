@echo off
SET NETWORK_NAME=global-db-net

:: 1. Comprobar si no se pasaron argumentos
IF "%1"=="" (
    echo [ERROR] No has especificado ningun comando.
    echo.
    GOTO help
)

:: 2. Enrutador de comandos validos
IF "%1"=="h" GOTO help
IF "%1"=="help" GOTO help
IF "%1"=="up" GOTO up
IF "%1"=="down" GOTO down
IF "%1"=="up-prod" GOTO up-prod
IF "%1"=="down-prod" GOTO down-prod
IF "%1"=="sync-back" GOTO sync-back
IF "%1"=="sync-front" GOTO sync-front

:: 3. Seguro contra fall-thru
echo [ERROR] El comando "%1" no es valido.
echo.
GOTO help

:up
echo [1/3] Comprobando red externa...
docker network inspect %NETWORK_NAME% >nul 2>nul || docker network create %NETWORK_NAME%
echo [2/3] Levantando Base de Datos...
docker-compose -f docker-compose.bd.yml up -d
echo [3/3] Levantando Aplicacion (Desarrollo)...
docker-compose up -d --build
echo ========================================
echo  ENTORNO DE DESARROLLO LISTO
echo ========================================
GOTO end

:down
echo Apagando Aplicacion (Desarrollo)...
docker-compose down
echo Apagando Base de Datos...
docker-compose -f docker-compose.bd.yml down
GOTO end

:up-prod
echo [1/3] Comprobando red externa...
docker network inspect %NETWORK_NAME% >nul 2>nul || docker network create %NETWORK_NAME%
echo [2/3] Levantando Base de Datos...
docker-compose -f docker-compose.bd.yml up -d
echo [3/3] Levantando Aplicacion (Produccion)...
docker-compose -f docker-compose.prod.yml up -d --build
echo ========================================
echo  ENTORNO DE PRODUCCION LISTO
echo ========================================
GOTO end

:down-prod
echo Apagando Aplicacion (Produccion)...
docker-compose -f docker-compose.prod.yml down
echo Apagando Base de Datos...
docker-compose -f docker-compose.bd.yml down
GOTO end

:sync-back
echo [1/2] Buscando el contenedor del Backend...
FOR /F "tokens=*" %%i IN ('docker-compose ps -q backend_dev') DO set CONTAINER_ID=%%i
IF "%CONTAINER_ID%"=="" (
    echo [ERROR] El contenedor del Backend no esta encendido. Lanza 'make.bat up' primero.
    GOTO end
)
echo [2/2] Extrayendo node_modules a Windows. Esto puede tardar unos segundos...
docker cp %CONTAINER_ID%:/app/node_modules ./back-src/
echo ========================================
echo  SINCRONIZACION COMPLETADA (Backend)
echo ========================================
GOTO end

:sync-front
echo [1/2] Buscando el contenedor del Frontend...
FOR /F "tokens=*" %%i IN ('docker-compose ps -q frontend_dev') DO set CONTAINER_ID=%%i
IF "%CONTAINER_ID%"=="" (
    echo [ERROR] El contenedor del Frontend no esta encendido. Lanza 'make.bat up' primero.
    GOTO end
)
echo [2/2] Extrayendo node_modules a Windows. Esto puede tardar unos segundos...
docker cp %CONTAINER_ID%:/app/node_modules ./front-src/
echo ========================================
echo  SINCRONIZACION COMPLETADA (Frontend)
echo ========================================
GOTO end

:help
echo ====================================================================================
echo  COMANDOS DISPONIBLES
echo ====================================================================================
echo   make.bat h           - Muestra este panel de ayuda
echo   make.bat up          - Levanta DB y App en modo Desarrollo
echo   make.bat down        - Apaga App Dev y DB
echo   make.bat up-prod     - Levanta DB y App en modo Produccion
echo   make.bat down-prod   - Apaga App Prod y DB
echo   make.bat sync-back   - Extrae las dependencias de NestJS a Windows 
echo   make.bat sync-front  - Extrae las dependencias de Vue a Windows
echo ====================================================================================
GOTO end

:end