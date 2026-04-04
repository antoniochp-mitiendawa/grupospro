#!/data/data/com.termux/files/usr/bin/bash

# Colores para el Log
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${YELLOW}   BLOQUE 2: CONFIGURACIÓN Y ENLACE     ${NC}"
echo -e "${BLUE}=========================================${NC}"

# 1. PREPARACIÓN DEL PROYECTO
echo -e "${BLUE}[ 1/3 ]${NC} Creando directorio 'grupospro'..."
mkdir -p $HOME/grupospro
cd $HOME/grupospro

# 2. INSTALACIÓN DE LIBRERÍAS ESPECÍFICAS
echo -e "${BLUE}[ 2/3 ]${NC} Instalando dependencias de Node.js..."
npm install axios sql.js

# 3. CREACIÓN DEL MOTOR DE SINCRONIZACIÓN
echo -e "${BLUE}[ 3/3 ]${NC} Generando motor de datos..."
cat <<EOF > sync.js
const initSqlJs = require('sql.js');
const axios = require('axios');
const fs = require('fs');
const rl = require('readline').createInterface({input:process.stdin,output:process.stdout});

const DB_PATH = './grupospro.sqlite';

async function ejecutarSincronizacion() {
    const SQL = await initSqlJs();
    let db = new SQL.Database();
    
    db.run("CREATE TABLE IF NOT EXISTS ajustes (clave TEXT PRIMARY KEY, valor TEXT)");
    db.run("CREATE TABLE IF NOT EXISTS productos (item TEXT, precio TEXT)");
    db.run("CREATE TABLE IF NOT EXISTS grupos (id TEXT, nombre TEXT)");

    console.log('\x1b[33m\n[ CONFIG ] Vinculación con Google Sheets\x1b[0m');
    const url = await new Promise(r => rl.question('[ CONFIG ] Pega la URL de tu Web App: ', r));
    
    try {
        console.log('\x1b[34m[ INFO ] Conectando a la nube...\x1b[0m');
        
        const resSubida = await axios.get(\`\${url}?action=reporte&id=VINCULACION_TEST&nombre=BLOQUE_2_OK\`);
        const resBajada = await axios.get(url);
        
        if (resBajada.data.status === "success") {
            db.run("INSERT OR REPLACE INTO ajustes VALUES ('url_sheets',?)", [url]);
            resBajada.data.productos.forEach(p => db.run("INSERT INTO productos VALUES (?,?)", [p.item, p.precio]));
            resBajada.data.grupos.forEach(g => db.run("INSERT INTO grupos VALUES (?,?)", [g.id, g.nombre]));
            
            fs.writeFileSync(DB_PATH, Buffer.from(db.export()));
            
            console.log('\n\x1b[32m=========================================');
            console.log('      VINCULACIÓN COMPLETADA EXITOSAMENTE');
            console.log('=========================================\x1b[0m');
            console.log(\`✅ Reporte: \${resSubida.data.message}\`);
            console.log(\`✅ Datos: \${resBajada.data.productos.length} productos sincronizados.\`);
        }
    } catch (e) {
        console.log('\x1b[31m[ ERROR ]\x1b[0m', e.message);
    }
    process.exit();
}
ejecutarSincronizacion();
EOF

# EJECUCIÓN INMEDIATA
node sync.js
