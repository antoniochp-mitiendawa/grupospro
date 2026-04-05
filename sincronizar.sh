const axios = require('axios');
const fs = require('fs');
const initSqlJs = require('sql.js');
const { spawn } = require('child_process'); // Herramienta para saltar al Bloque 3

async function sincronizarDatos() {
    console.log("\x1b[34m[ BLOQUE 2 ] Sincronizando con Google Sheets...\x1b[0m");
    
    // URL de tu Web App de Google (La que ya tienes configurada)
    const url = "TU_URL_DE_GOOGLE_SHEETS"; 

    try {
        const respuesta = await axios.get(url);
        const datos = respuesta.data;

        const SQL = await initSqlJs();
        const db = new SQL.Database();

        // Crear tablas
        db.run("CREATE TABLE productos (item TEXT, descripcion TEXT, precio REAL)");
        db.run("CREATE TABLE grupos (id TEXT, nombre TEXT)");

        // Insertar Productos
        datos.productos.forEach(p => {
            db.run("INSERT INTO productos VALUES (?, ?, ?)", [p.item, p.descripcion, p.precio]);
        });

        // Insertar Grupos
        datos.grupos.forEach(g => {
            db.run("INSERT INTO grupos VALUES (?, ?)", [g.id, g.nombre]);
        });

        // Guardar físicamente
        const data = db.export();
        const buffer = Buffer.from(data);
        fs.writeFileSync('./grupospro.sqlite', buffer);

        console.log("\x1b[32m\n=========================================");
        console.log("   VINCULACIÓN Y CARGA EXITOSA");
        console.log("=========================================");
        console.log(`✅ PRODUCTOS CARGADOS: ${datos.productos.length}`);
        console.log(`✅ GRUPOS AUTORIZADOS: ${datos.grupos.length}\x1b[0m\n`);

        // --- SALTO AUTOMÁTICO AL BLOQUE 3 ---
        console.log("\x1b[33m[ INFO ] Iniciando Bloque 3 automáticamente...\x1b[0m");
        
        const child = spawn('node', ['bot.js'], {
            stdio: 'inherit', // Esto permite que el Bloque 3 use la misma terminal para el código de vinculación
            shell: true
        });

    } catch (error) {
        console.error("\x1b[31m[ ERROR ] No se pudo sincronizar: " + error.message + "\x1b[0m");
    }
}

sincronizarDatos();
