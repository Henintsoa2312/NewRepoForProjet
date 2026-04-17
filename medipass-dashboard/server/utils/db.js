import mysql from 'mysql2/promise';

// Configuration de la connexion à la base de données WAMP
// Ce fichier est dans server/utils, donc 'pool' est auto-importé dans les API
export const pool = mysql.createPool({
  host: '127.0.0.1',     // Force l'IPv4 pour éviter les erreurs de connexion
  user: 'root',          // Utilisateur par défaut de WAMP
  password: '',          // Mot de passe par défaut (vide)
  database: 'medipass_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});
