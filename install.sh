#!/bin/bash
# ==========================================
# INSTALADOR MAESTRO - PROYECTO GRUPOSPRO
# ==========================================

echo "🚀 Iniciando Instalación Automática..."

# 1. Preparar carpetas y entorno
cd $HOME
rm -rf grupospro
mkdir grupospro
cd grupospro

# 2. Instalación de dependencias (Bloque 1 - Blindaje)
pkg update -y && pkg upgrade -y
pkg install nodejs -y
termux-wake-lock

# 3. Descargar archivos desde tu GitHub
# Reemplaza 'TU_USUARIO' y 'TU_REPO' con tus datos reales
curl -O https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/sincronizar.js
curl -O https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/bot.js
curl -O https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/emojis.js
curl -O https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/sinonimos.js

# 4. Instalar librerías de Node
npm install @whiskeysockets/baileys pino sql.js axios @hapi/boom readline

# 5. EJECUCIÓN AUTOMÁTICA (Unión de Bloque 2 y 3)
echo "✅ Entorno listo. Iniciando Sincronización y Vinculación..."
node -e "
const { spawn } = require('child_process');
const sync = spawn('node', ['sincronizar.js'], { stdio: 'inherit' });
sync.on('close', () => {
    console.log('--- Saltando al Motor de WhatsApp ---');
    spawn('node', ['bot.js'], { stdio: 'inherit', shell: true });
});
"
