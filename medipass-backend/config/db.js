// Fichier: medipass-backend/config/db.js
    const mysql = require('mysql2'); // Assurez-vous que c'est bien mysql2 si vos logs d'erreur le montrent
    const dotenv = require('dotenv');

    dotenv.config(); // Charge les variables depuis .env

    console.log('[config/db.js] Tentative de chargement des variables d\'environnement...');
    console.log(`[config/db.js] Valeur de DB_HOST: ${process.env.DB_HOST}`);
    console.log(`[config/db.js] Valeur de DB_USER: ${process.env.DB_USER}`);
    console.log(`[config/db.js] Valeur de DB_PASSWORD: [${process.env.DB_PASSWORD}] (longueur: ${process.env.DB_PASSWORD ? process.env.DB_PASSWORD.length : 'undefined/0'})`); // Affiche la valeur brute pour le mot de passe vide
    console.log(`[config/db.js] Valeur de DB_NAME: ${process.env.DB_NAME}`);

    const pool = mysql.createPool({
        connectionLimit: 10,
        host: process.env.DB_HOST, // Utilise directement ce qui est lu
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        charset: 'utf8mb4',
        // Ajout de configurations pour le débogage de la connexion si nécessaire
        // connectTimeout: 10000 // 10 secondes
    });

    // Test de connexion initial lors de la création du pool
    pool.getConnection((err, connection) => {
        if (err) {
            console.error("\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            console.error("[config/db.js] ERREUR CRITIQUE lors de la tentative d'obtenir une connexion initiale du pool:");
            console.error(`[config/db.js] Hôte utilisé: ${process.env.DB_HOST}`);
            console.error(`[config/db.js] Utilisateur utilisé: '${process.env.DB_USER}'`); // Mettre des apostrophes pour voir si c'est une chaîne vide
            console.error(`[config/db.js] Mot de passe utilisé: '${process.env.DB_PASSWORD === '' ? 'CHAÎNE VIDE' : (process.env.DB_PASSWORD ? 'PRÉSENT MAIS NON VIDE' : 'UNDEFINED/NULL')}'`);
            console.error(`[config/db.js] Base de données utilisée: ${process.env.DB_NAME}`);
            console.error("----------------------------------------------------------------------------");
            console.error("[config/db.js] Détails de l'erreur MySQL:");
            console.error("[config/db.js]   Code:", err.code);
            console.error("[config/db.js]   Errno:", err.errno);
            console.error("[config/db.js]   Message SQL:", err.sqlMessage || err.message);
            console.error("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
        }
        if (connection) {
            console.log("[config/db.js] Connexion de test initiale au pool MySQL réussie et libérée.");
            connection.release();
        }
    });

    module.exports = pool;
    
