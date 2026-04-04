#!/data/data/com.termux/files/usr/bin/bash

# --- CONFIGURACIÓN DE COLORES ---
GW='\033[0;32m'
BW='\033[0;34m'
YW='\033[1;33m'
NW='\033[0m'

echo -e "${BW}=========================================${NW}"
echo -e "${YW}   GRUPOSPRO V2.0 - INSTALACIÓN TOTAL    ${NW}"
echo -e "${BW}=========================================${NW}"

# 1. ACTUALIZACIÓN Y ENTORNO BASE (Bloque 1)
echo -e "${BW}[ 1/5 ]${NW} Preparando sistema base..."
pkg update -y && pkg upgrade -y 
pkg install -y binutils python clang make build-essential nodejs git ffmpeg libwebp sqlite [cite: 33, 34, 35]

# 2. DIRECTORIO Y DEPENDECIAS (Puente entre Bloques)
echo -e "${BW}[ 2/5 ]${NW} Creando estructura de carpetas..."
mkdir -p $HOME/grupospro
cd $HOME/grupospro 

echo -e "${BW}[ 3/5 ]${NW} Instalando librerías de enlace..."
npm install axios sql.js 

# 3. CREACIÓN DEL MOTOR DE SINCRONIZACIÓN (Bloque 2)
echo -e "${BW}[ 4/5 ]${NW} Generando archivo de sincronización..."
cat <<EOF > sync.js
const initSqlJs = require('sql.js');
const axios = require('axios');
const fs = require('fs');
const rl = require('readline').createInterface({input:process.stdin,output:process.stdout});

const DB_PATH = './grupospro.sqlite';

async function iniciarSistema() {
    const SQL = await initSqlJs();
    let db = new SQL.Database();
    
    // Tablas según arquitectura definida
    db.run("CREATE TABLE IF NOT EXISTS ajustes (clave TEXT PRIMARY KEY, valor TEXT)");
    db.run("CREATE TABLE IF NOT EXISTS productos (item TEXT, precio TEXT)");
    db.run("CREATE TABLE IF NOT EXISTS grupos (id TEXT, nombre TEXT)");

    console.log('\x1b[33m\n[ CONFIG ] Vinculación con Google Sheets\x1b[0m');
    const url = await new Promise(r => rl.question('[ CONFIG ] Pega la URL de tu Web App: ', r));
    
    try {
        console.log('\x1b[34m[ INFO ] Validando conexión...\x1b[0m');
        
        // Reporte de instalación (Escritura en Lista Grupos) [cite: 25, 27]
        const resSub = await axios.get(\`\${url}?action=reporte&id=NUEVA_ID_001&nombre=INSTALACION_LIMPIA\`);
        
        // Descarga de datos (Lectura de Productos y Grupos) [cite: 19, 21, 23]
        const resDown = await axios.get(url);
        
        if (resDown.data.status === "success") {
            db.run("INSERT OR REPLACE INTO ajustes VALUES ('url_sheets',?)", [url]);
            
            // Llenado de base de datos local
            resDown.data.productos.forEach(p => db.run("INSERT INTO productos VALUES (?,?)", [p.item, p.precio]));
            resDown.data.grupos.forEach(g => db.run("INSERT INTO grupos VALUES (?,?)", [g.id, g.nombre]));
            
            fs.writeFileSync(DB_PATH, Buffer.from(db.export()));
            
            console.log('\n\x1b[32m=========================================');
            console.log('      SISTEMA LISTO Y SINCRONIZADO');
            console.log('=========================================\x1b[0m');
            console.log(\`✅ Nube: \${resSub.data.message}\`);
            console.log(\`✅ Local: \${resDown.data.productos.length} productos cargados.\`);
        }
    } catch (e) {
        console.log('\x1b[31m[ ERROR ]\x1b[0m', e.message);
    }
    process.exit();
}
iniciarSistema();
EOF

# 4. FINALIZACIÓN (Bloque 1)
echo -e "${BW}[ 5/5 ]${NW} Configurando acceso a archivos..."
termux-setup-storage [cite: 37]

echo -e "${GW}[ OK ] Entorno blindado. Iniciando vinculación final...${NW}"
node sync.js
