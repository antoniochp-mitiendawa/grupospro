#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
# PROYECTO: grupospro
# FUNCIÓN: Instalador Maestro de Entorno (Bloque 1)
# =========================================================

# Colores (Corregidos para evitar errores de interpretación)
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' 

clear
echo -e "${BLUE}=========================================${NC}"
echo -e "${YELLOW}       INSTALADOR GRUPOSPRO V1.0        ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}[ INFO ]${NC} Iniciando preparación de entorno..."

# 1. ACTUALIZACIÓN INTEGRAL
echo -e "\n${BLUE}[ 1/6 ]${NC} Actualizando repositorios y sistema..."
pkg update -y && pkg upgrade -y
echo -e "${GREEN}[ OK ]${NC} Sistema base al día."

# 2. HERRAMIENTAS DE COMPILACIÓN
echo -e "${BLUE}[ 2/6 ]${NC} Instalando herramientas de compilación..."
pkg install -y binutils python clang make build-essential
echo -e "${GREEN}[ OK ]${NC} Entorno de compilación listo."

# 3. MOTORES Y CONTROL
echo -e "${BLUE}[ 3/6 ]${NC} Instalando Node.js y Git..."
pkg install -y nodejs git
echo -e "${GREEN}[ OK ]${NC} Motores instalados."

# 4. MULTIMEDIA Y DATOS
echo -e "${BLUE}[ 4/6 ]${NC} Instalando SQLite3, FFmpeg y Libwebp..."
pkg install -y ffmpeg libwebp sqlite
echo -e "${GREEN}[ OK ]${NC} Soporte multimedia y base de datos listos."

# 5. GESTOR DE PERSISTENCIA (PM2)
echo -e "${BLUE}[ 5/6 ]${NC} Instalando PM2 (Para ejecución 24/7)..."
npm install -g pm2
echo -e "${GREEN}[ OK ]${NC} PM2 instalado globalmente."

# 6. ESTRUCTURA DE DIRECTORIOS
echo -e "${BLUE}[ 6/6 ]${NC} Configurando directorio 'grupospro'..."
mkdir -p $HOME/grupospro
cd $HOME/grupospro
echo -e "${GREEN}[ OK ]${NC} Carpeta de trabajo lista."

# SOLICITUD DE PERMISOS
echo -e "\n${YELLOW}[ IMPORTANTE ]${NC} Acepta el permiso de memoria en pantalla."
termux-setup-storage

# VERIFICACIÓN FINAL
NODE_V=$(node -v)
PM2_V=$(pm2 -v | tail -n 1)
SQL_V=$(sqlite3 --version | cut -d ' ' -f 1)

echo -e "\n${BLUE}=========================================${NC}"
echo -e "${GREEN}      RESUMEN DE INSTALACIÓN EXITOSA     ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "📦 Proyecto:  ${YELLOW}grupospro${NC}"
echo -e "🟢 Node.js:   ${GREEN}$NODE_V${NC}"
echo -e "🟢 PM2:       ${GREEN}v$PM2_V${NC}"
echo -e "🟢 SQLite:    ${GREEN}v$SQL_V${NC}"
echo -e "🛠️ Compilación: ${GREEN}[ LISTA ]${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "${YELLOW}Instrucciones:${NC}"
echo -e "1. El entorno está blindado y listo para el Bloque 2."
echo -e "${BLUE}=========================================${NC}"

curl -L https://raw.githubusercontent.com/antoniochp-mitiendawa/grupospro/main/sincronizar.sh | bash
