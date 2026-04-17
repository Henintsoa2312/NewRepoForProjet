const { createServer } = require('http');
const { Server } = require("socket.io");
const db = require('./config/db'); // On réutilise la connexion DB existante
const { logMessage } = require('./utils/logger'); // Assurez-vous que ce fichier existe

const httpServer = createServer();

const io = new Server(httpServer, {
  cors: {
    origin: "*", // Accepte toutes les origines (Nuxt, App Mobile)
    methods: ["GET", "POST"]
  }
});

io.on("connection", (socket) => {
  console.log(`[Socket.IO] Un client est connecté: ${socket.id}`);

  socket.on('join_room', (roomName) => {
    socket.join(roomName);
  });

  socket.on('send_message', (data) => {
    if (data.room && data.content) {
      
      // 1. Log fichier
      try {
        logMessage(data.room, socket.id, data.content);
      } catch (e) {
        console.error("   -> Erreur log:", e.message);
      }

      // 2. Sauvegarde DB
      const sql = 'INSERT INTO messages (room, content, sender_id, is_doctor) VALUES (?, ?, ?, ?)';
      const isDoctor = data.isDoctor || false; 
      const senderId = data.senderId || 0;

      db.query(sql, [data.room, data.content, senderId, isDoctor], (err) => {
        if (err) console.error("❌ Erreur sauvegarde DB:", err.message);
        else console.log("✅ Message sauvegardé en DB");
      });

      console.log(`[Socket.IO] Message reçu: "${data.content}"`);

      // 3. Diffusion
      socket.to(data.room).emit('receive_message', {
        content: data.content,
        senderId: senderId,
        isDoctor: isDoctor,
        timestamp: new Date()
      });
    }
  });

  socket.on("disconnect", () => {
    console.log(`[Socket.IO] Client déconnecté: ${socket.id}`);
  });
});

const PORT = 3001;

httpServer.listen(PORT, '0.0.0.0', () => {
    console.log(`\n==================================================`);
    console.log(`💬 Serveur SOCKET.IO démarré sur le port ${PORT}`);
    console.log(`==================================================\n`);
});