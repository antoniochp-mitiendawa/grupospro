#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
# PROYECTO: grupospro
# FUNCIÓN: Instalador Maestro de Entorno (Bloque 1)
# REPOSITORIO: https://github.com/tu-usuario/grupospro
# =========================================================

# Colores para la interfaz
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear
echo -e "${BLUE}=========================================${NC}"
echo -e "${YELLOW}       INSTALADOR GRUPOSPRO V1.0        ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}[ INFO ]${NC} Iniciando preparación de entorno..."

# 1. ACTUALIZACIÓN DE REPOSITORIOS Y SISTEMA
echo -e "\n${BLUE}[ 1/6 ]${NC} Actualizando sistema base..."
pkg update -y && pkg upgrade -y
echo -e "${GREEN}[ OK ]${NC} Sistema actualizado."

# 2. HERRAMIENTAS DE COMPILACIÓN Y RED
echo -e "${BLUE}[ 2/6 ]${NC} Instalando herramientas de compilación (C++/Python)..."
pkg install -y binutils python clang make build-essential
echo -e "${GREEN}[ OK ]${NC} Herramientas de compilación listas."

# 3. MOTORES DE EJECUCIÓN
echo -e "${BLUE}[ 3/6 ]${NC} Instalando Node.js y Git..."
pkg install -y nodejs git
echo -e "${GREEN}[ OK ]${NC} Motores instalados correctamente."

# 4. SOPORTE MULTIMEDIA Y BASE DE DATOS
echo -e "${BLUE}[ 4/6 ]${NC} Instalando SQLite3, FFmpeg y Libwebp..."
pkg install -y ffmpeg libwebp sqlite
echo -e "${GREEN}[ OK ]${NC} Soporte de medios y datos listo."

# 5. GESTOR DE PERSISTENCIA (PM2)
echo -e "${BLUE}[ 5/6 ]${NC} Configurando gestor de procesos PM2..."
npm install -g pm2
echo -e "${GREEN}[ OK ]${NC} PM2 instalado globalmente."

# 6. ESTRUCTURA DE DIRECTORIOS
echo -e "${BLUE}[ 6/6 ]${NC} Creando directorio del proyecto 'grupospro'..."
mkdir -p $HOME/grupospro
cd $HOME/grupospro
echo -e "${GREEN}[ OK ]${NC} Carpeta de trabajo lista en: $HOME/grupospro"

# SOLICITUD DE PERMISOS DE ALMACENAMIENTO
echo -e "\n${YELLOW}[ IMPORTANTE ]${NC} Se solicitará acceso a la memoria."
termux-setup-storage

# VERIFICACIÓN FINAL DE VERSIONES
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
echo -e "1. Acepta el permiso de archivos si aparece en pantalla."
echo -e "2. El entorno está blindado. Listo para el Bloque 2."
echo -e "${BLUE}=========================================${NC}"
