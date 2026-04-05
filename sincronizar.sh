const axios = require('axios');
const fs = require('fs');
const initSqlJs = require('sql.js');
const { spawn } = require('child_process'); 

async function sincronizarDatos() {
    console.log("\x1b[34m[ BLOQUE 2 ] Conectando con la nube...\x1b[0m");
    
    // Cambia esto por tu URL real de la Web App de Google
    const url = "TU_URL_DE_GOOGLE_SHEETS"; 

    try {
        const respuesta = await axios.get(url);
        const datos = respuesta.data;

        const SQL = await initSqlJs();
        const db = new SQL.Database();

        db.run("CREATE TABLE productos (item TEXT, descripcion TEXT, precio REAL)");
        db.run("CREATE TABLE grupos (id TEXT, nombre TEXT)");

        datos.productos.forEach(p => {
            db.run("INSERT INTO productos VALUES (?, ?, ?)", [p.item, p.descripcion, p.precio]);
        });

        datos.grupos.forEach(g => {
            db.run("INSERT INTO grupos VALUES (?, ?)", [g.id, g.nombre]);
        });

        const data = db.export();
        fs.writeFileSync('./grupospro.sqlite', Buffer.from(data));

        console.log("\x1b[32m\n=========================================");
        console.log("   VINCULACIÓN COMPLETADA EXITOSAMENTE");
        console.log("=========================================");
        console.log(`✅ PRODUCTOS: ${datos.productos.length} sincronizados.`);
        console.log(`✅ GRUPOS: ${datos.grupos.length} autorizados.\x1b[0m\n`);

        // SALTO AUTOMÁTICO AL BLOQUE 3
        console.log("\x1b[33m[ INFO ] Iniciando Bloque 3...\x1b[0m");
        spawn('node', ['bot.js'], { stdio: 'inherit', shell: true });

    } catch (error) {
        console.error("\x1b[31m[ ERROR ] " + error.message + "\x1b[0m");
    }
}

sincronizarDatos();
