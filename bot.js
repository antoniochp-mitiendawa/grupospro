const { 
    default: makeWASocket, 
    useMultiFileAuthState, 
    delay, 
    fetchLatestBaileysVersion 
} = require("@whiskeysockets/baileys");
const pino = require("pino");
const fs = require("fs");
const readline = require("readline");
const initSqlJs = require('sql.js');

// Conexión con tus archivos existentes en GitHub
const listaEmojis = require('./emojis.js');
const sinonimos = require('./sinonimos.js');

const DB_PATH = './grupospro.sqlite';
const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
const cuestion = (texto) => new Promise((resolver) => rl.question(texto, resolver));

// Función para aplicar Spintax usando tus archivos de soporte
const aplicarSpintax = (texto) => {
    let contenido = texto;
    // Selección aleatoria de emoji de tu base de datos
    const emoji = listaEmojis[Math.floor(Math.random() * listaEmojis.length)] || "✨";
    return `${emoji} ${contenido} ${emoji}`;
};

async function iniciarBot() {
    console.log("\x1b[34m[ BLOQUE 3 ] Motor de Mensajería Activo\x1b[0m");
    
    // Carga de la base de datos generada por el Bloque 2
    const SQL = await initSqlJs();
    if (!fs.existsSync(DB_PATH)) {
        console.log("\x1b[31m[ ERROR ] No se encuentra grupospro.sqlite. Ejecute el Bloque 2 primero.\x1b[0m");
        return;
    }
    const dbFile = fs.readFileSync(DB_PATH);
    const db = new SQL.Database(dbFile);

    const { state, saveCreds } = await useMultiFileAuthState('sesion_auth');
    const { version } = await fetchLatestBaileysVersion();

    const sock = makeWASocket({
        version,
        auth: state,
        printQRInTerminal: false,
        logger: pino({ level: "silent" }),
        browser: ["Ubuntu", "Chrome", "20.0.0"]
    });

    // Emparejamiento por código (Pairing Code)
    if (!sock.authState.creds.registered) {
        await delay(3000);
        const numero = await cuestion("\x1b[33m[ CONFIG ] Ingrese su número (ej: 521XXXXXXXXXX): \x1b[0m");
        const codigo = await sock.requestPairingCode(numero.trim());
        console.log("\x1b[32m\nCÓDIGO DE VINCULACIÓN: " + codigo + "\n\x1b[0m");
    }

    sock.ev.on("creds.update", saveCreds);

    sock.ev.on("messages.upsert", async ({ messages }) => {
        const msg = messages[0];
        if (!msg.message || msg.key.fromMe === false) return;
        const texto = (msg.message.conversation || msg.message.extendedTextMessage?.text || "").toLowerCase();
        
        if (texto === "prueba") {
            const resGrupos = db.exec("SELECT id, nombre FROM grupos");
            const resProds = db.exec("SELECT item, descripcion, precio FROM productos");
            
            if (resGrupos[0] && resProds[0]) {
                const listaGrupos = resGrupos[0].values;
                const listaProductos = resProds[0].values;
                let prodIdx = 0; // Para la rotación de productos solicitada

                for (const [gid, gnombre] of listaGrupos) {
                    const [item, desc, precio] = listaProductos[prodIdx];
                    
                    // Construcción del mensaje con Spintax y rotación
                    const baseMensaje = `*${item.toUpperCase()}*\n${desc}\n💰 Precio: $${precio}`;
                    const mensajeFinal = aplicarSpintax(baseMensaje);
                    
                    console.log(`[ ENVÍO ] Grupo: ${gnombre} | Producto: ${item}`);
                    
                    // Delay aleatorio entre 7 y 25 segundos para evitar baneo
                    await delay(Math.floor(Math.random() * (25000 - 7000) + 7000));
                    
                    await sock.sendMessage(gid, { text: mensajeFinal });

                    // Avanzar al siguiente producto para el próximo grupo
                    prodIdx = (prodIdx + 1) % listaProductos.length;
                }
                
                // Notificación de cierre de ciclo al dueño
                await sock.sendMessage(msg.key.remoteJid, { text: "✅ Ciclo completado con rotación de productos." });
            }
        }
    });
}

iniciarBot();
