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

// Verificación de archivos de soporte
const listaEmojis = fs.existsSync('./emojis.js') ? require('./emojis.js') : ["✨"];
const sinonimos = fs.existsSync('./sinonimos.js') ? require('./sinonimos.js') : {};

const DB_PATH = './grupospro.sqlite';
const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
const cuestion = (texto) => new Promise((resolver) => rl.question(texto, resolver));

async function iniciarBot() {
    console.log("\x1b[34m[ BLOQUE 3 ] Motor de WhatsApp Online\x1b[0m");
    
    if (!fs.existsSync(DB_PATH)) {
        console.log("❌ Error: Base de datos no encontrada.");
        return;
    }

    const SQL = await initSqlJs();
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

    // Código de vinculación
    if (!sock.authState.creds.registered) {
        await delay(3000);
        const numero = await cuestion("\x1b[33m[ CONFIG ] Ingrese su número (ej: 521XXXXXXXXXX): \x1b[0m");
        const codigo = await sock.requestPairingCode(numero.trim());
        console.log("\x1b[32m\nTU CÓDIGO ES: " + codigo + "\x1b[0m\n");
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
                let prodIdx = 0;

                for (const [gid, gnombre] of listaGrupos) {
                    const [item, desc, precio] = listaProductos[prodIdx];
                    
                    // Aplicar Emojis del archivo de GitHub
                    const emoji = listaEmojis[Math.floor(Math.random() * listaEmojis.length)];
                    const mensaje = `${emoji} *${item.toUpperCase()}*\n${desc}\n💰 *PRECIO:* $${precio}`;
                    
                    console.log(`[ ENVÍO ] Grupo: ${gnombre} | Producto: ${item}`);
                    
                    // Delay humano 7-25s
                    await delay(Math.floor(Math.random() * (25000 - 7000) + 7000));
                    
                    await sock.sendMessage(gid, { text: mensaje });
                    prodIdx = (prodIdx + 1) % listaProductos.length;
                }
                await sock.sendMessage(msg.key.remoteJid, { text: "✅ Prueba terminada." });
            }
        }
    });
}

iniciarBot();
