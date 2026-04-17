const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const db = require('./config/db');

dotenv.config({ debug: process.env.NODE_ENV !== 'production' });

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
    res.status(200).send('<h1>Bienvenue sur l\'API Medipass!</h1><p>Le serveur est opérationnel.</p>');
});

// Importer les routes
const authRoutes = require('./routes/auth');
const secureRoutes = require('./routes/secure');
const verifyToken = require('./middleware/verifyToken');

// Utiliser les routes
app.use('/api/auth', authRoutes);
app.use('/api/secure', verifyToken, secureRoutes);

// --- AJOUT POUR LE DASHBOARD ---
// Route pour récupérer l'historique des messages
// Cette route est appelée par le Dashboard Nuxt sur le port 3000
app.get('/api/messages/:room', (req, res) => {
    const room = req.params.room;
    db.query(
        'SELECT * FROM messages WHERE room = ? ORDER BY created_at ASC',
        [room],
        (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json(results);
        }
    );
});
// -------------------------------

app.use((err, req, res, next) => {
    console.error("ERREUR NON CAPTURÉE:", err.stack || err.message || err);
    const statusCode = err.status || 500;
    const message = err.message || 'Une erreur inattendue est survenue sur le serveur.';

    res.status(statusCode).json({
        success: false,
        message: message,
        ...(process.env.NODE_ENV === 'development' && { errorStack: err.stack }),
    });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
    if (process.env.NODE_ENV !== 'test') {
        console.log(`[dotenv@${require('dotenv/package.json').version}] variables d'environnement chargées.`);
    }
    console.log(`Serveur démarré et à l'écoute sur le port ${PORT} sur toutes les interfaces réseau.`);
    console.log(`   Frontend (via émulateur Android) devrait utiliser: http://10.0.2.2:${PORT}`);
    console.log(`   Vérifier le serveur (depuis le navigateur de l'hôte): http://localhost:${PORT}/`);

    db.getConnection((err, connection) => {
        if (err) {
            console.error('ERREUR CRITIQUE: Impossible de se connecter à la base de données MySQL au démarrage.');
            return;
        }
        if (connection) {
            connection.release();
            console.log('Connexion initiale à la base de données MySQL via le pool réussie!');
        }
    });
});

process.on('SIGINT', () => {
    console.log('\nArrêt du serveur demandé (Ctrl+C)...');
    process.exit(0);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
});
