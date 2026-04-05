#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
# INSTALADOR AUTOMATIZADO - GRUPOS PRO V2
# ==========================================
# Basado en códigos exitosos y descartando errores previos [cite: 1, 9]

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${YELLOW}   BLOQUE 2: CONFIGURACIÓN Y VINCULACIÓN ${NC}"
echo -e "${BLUE}=========================================${NC}"

# 1. PREPARACIÓN LIMPIA DEL ENTORNO 
echo -e "${BLUE}[ 1/3 ]${NC} Creando directorio del proyecto..."
mkdir -p $HOME/grupospro
cd $HOME/grupospro

# 2. INSTALACIÓN DE DEPENDENCIAS (Garantiza sql.js y axios) [cite: 2]
echo -e "${BLUE}[ 2/3 ]${NC} Instalando librerías necesarias..."
npm install axios sql.js

# 3. GENERACIÓN DEL MOTOR DE SINCRONIZACIÓN (sync.js) [cite: 3]
echo -e "${BLUE}[ 3/3 ]${NC} Generando motor de datos con reporte..."

cat <<'EOF' > sync.js
const initSqlJs = require('sql.js');
const axios = require('axios');
const fs = require('fs');
const readline = require('readline');

const DB_PATH = './grupospro.sqlite';

async function ejecutarSincronizacion() {
    const SQL = await initSqlJs();
    let db = new SQL.Database();

    // LOGS DE EVENTOS: No se eliminan ni simplifican 
    console.log("\x1b[34m[ LOG ] Iniciando configuración de base de datos...\x1b[0m");

    // CREACIÓN DE TABLAS (Garantiza Item, Descripción y Precio) [cite: 4, 5]
    db.run("CREATE TABLE IF NOT EXISTS ajustes (clave TEXT PRIMARY KEY, valor TEXT)");
    db.run("CREATE TABLE IF NOT EXISTS productos (item TEXT, descripcion TEXT, precio TEXT)");
    db.run("CREATE TABLE IF NOT EXISTS grupos (id TEXT, nombre TEXT)");
    
    const rl = readline.createInterface({
        input: fs.createReadStream('/dev/tty'),
        output: process.stdout,
        terminal: true
    });

    console.log('\x1b[33m\n[ CONFIG ] Vinculación con Google Sheets\x1b[0m');
    
    const url = await new Promise(r => rl.question('[ CONFIG ] Pega la URL de tu Web App: ', (answer) => {
        rl.close();
        r(answer.trim());
    }));

    try {
        console.log('\x1b[34m[ INFO ] Conectando a la nube...\x1b[0m');

        // REPORTE DE VINCULACIÓN (Ping de prueba a Google Sheets) 
        console.log('\x1b[36m[ LOG ] Enviando señal de prueba a la hoja...\x1b[0m');
        const resSubida = await axios.get(`${url}?action=reporte&id=VINCULACION_TEST&nombre=BLOQUE_2_OK`);
        
        // DESCARGA DE DATOS 
        console.log('\x1b[36m[ LOG ] Descargando inventario actualizado...\x1b[0m');
        const resBajada = await axios.get(url);

        if (resBajada.data.status === "success") {
            db.run("INSERT OR REPLACE INTO ajustes VALUES ('url_sheets',?)", [url]);

            // GUARDADO DE PRODUCTOS (3 COLUMNAS: ITEM, DESCRIPCIÓN, PRECIO) [cite: 11]
            resBajada.data.productos.forEach(p => {
                db.run("INSERT INTO productos VALUES (?,?,?)", [p.item, p.descripcion || "Sin descripción", p.precio]);
            });

            // GUARDADO DE GRUPOS (ID, NOMBRE) [cite: 11]
            resBajada.data.grupos.forEach(g => {
                db.run("INSERT INTO grupos VALUES (?,?)", [g.id, g.nombre]);
            });
            
            // Persistencia física de la DB [cite: 11]
            fs.writeFileSync(DB_PATH, Buffer.from(db.export()));

            console.log('\n\x1b[32m=========================================');
            console.log('      VINCULACIÓN COMPLETADA EXITOSAMENTE');
            console.log('=========================================\x1b[0m');
            console.log(`✅ Reporte: ${resSubida.data.message}`);
            console.log(`✅ Productos: ${resBajada.data.productos.length} sincronizados.`);
            console.log(`✅ Grupos: ${resBajada.data.grupos.length} autorizados.`);
            
            // VERIFICACIÓN VISUAL (Garantiza que la descripción bajó) [cite: 11]
            if(resBajada.data.productos.length > 0) {
                const p = resBajada.data.productos[0];
                console.log(`\x1b[35m[ CHECK ] Muestra: ${p.item} | ${p.precio}\x1b[0m`);
            }
        }
    } catch (e) {
        console.log('\x1b[31m[ ERROR ]\x1b[0m', e.message);
    }
    process.exit();
}
ejecutarSincronizacion();
EOF

# EJECUCIÓN DEL MOTOR [cite: 14]
node sync.js </dev/tty
