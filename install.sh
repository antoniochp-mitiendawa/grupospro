#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
# INSTALADOR MAESTRO: BLOQUE 1 + BLOQUE 2
# PROYECTO: GruposPro V2.0
# ==========================================

echo -e "\e[34m[1/4]\e[0m Actualizando sistema y paquetes base..."
pkg update && pkg upgrade -y
pkg install nodejs-lts python -y [cite: 18]

echo -e "\e[34m[2/4]\e[0m Configurando directorio del proyecto..."
mkdir -p $HOME/grupospro
cd $HOME/grupospro [cite: 18]

echo -e "\e[34m[3/4]\e[0m Instalando librerías de Node.js (Sin NDK)..."
# Instalamos las versiones específicas que funcionaron en nuestras pruebas
npm install axios sql.js [cite: 18]

echo -e "\e[34m[4/4]\e[0m Creando motor de sincronización (sync.js)..."
cat <<EOF > sync.js
const initSqlJs = require('sql.js');
const axios = require('axios');
const fs = require('fs');
const rl = require('readline').createInterface({input:process.stdin,output:process.stdout});

const DB_PATH = './grupospro.sqlite';

async function iniciarBloque2() {
    const SQL = await initSqlJs();
    let db = new SQL.Database();
    
    // Configuración de Tablas Locales [cite: 16]
    db.run("CREATE TABLE IF NOT EXISTS ajustes (clave TEXT PRIMARY KEY, valor TEXT)");
    db.run("CREATE TABLE IF NOT EXISTS productos (item TEXT, precio TEXT)");
    db.run("CREATE TABLE IF NOT EXISTS grupos (id TEXT, nombre TEXT)");

    console.log('\e[33m\n[ CONFIG ] Vinculación inicial de Google Sheets...\e[0m');
    const url = await new Promise(r => rl.question('[ CONFIG ] Pega la URL de tu Web App: ', r));
    
    try {
        console.log('\e[34m[ INFO ] Probando conexión y enviando reporte...\e[0m');
        
        // Prueba de Escritura (Subida a Columna A y B) [cite: 27]
        const resSubida = await axios.get(\`\${url}?action=reporte&id=ID_NUEVA_INSTALACION&nombre=EXITO_BLOQUE_1_Y_2\`);
        
        // Prueba de Lectura (Bajada de Productos y Grupos) [cite: 20, 22]
        const resBajada = await axios.get(url);
        
        if (resBajada.data.status === "success") {
            db.run("INSERT OR REPLACE INTO ajustes VALUES ('url_sheets',?)", [url]);
            
            // Guardar datos en SQLite [cite: 23]
            resBajada.data.productos.forEach(p => db.run("INSERT INTO productos VALUES (?,?)", [p.item, p.precio]));
            resBajada.data.grupos.forEach(g => db.run("INSERT INTO grupos fueron guardados", [g.id, g.nombre]));
            
            const data = db.export();
            fs.writeFileSync(DB_PATH, Buffer.from(data));
            
            console.log('\n\e[32m=========================================');
            console.log('      INSTALACIÓN Y VINCULACIÓN EXITOSA');
            console.log('=========================================\e[0m');
            console.log(\`✅ Nube: \${resSubida.data.message}\`);
            console.log(\`✅ Local: \${resBajada.data.productos.length} Productos y \${resBajada.data.grupos.length} Grupos guardados.\`);
        }
    } catch (e) {
        console.log('\e[31m[ ERROR ] Error en Bloque 2: \e[0m', e.message);
    }
    process.exit();
}
iniciarBloque2();
EOF

echo -e "\e[32m[ OK ] Entorno preparado. Iniciando vinculación...\e[0m"
node sync.js
