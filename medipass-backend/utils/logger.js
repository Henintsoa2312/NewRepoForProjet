const fs = require('fs');
const path = require('path');

// Définition du chemin : on crée un dossier 'logs' à la racine du projet
const logDirectory = path.join(__dirname, '..', 'logs');
const logFilePath = path.join(logDirectory, 'chat.log');

// Création du dossier logs s'il n'existe pas
if (!fs.existsSync(logDirectory)) {
    fs.mkdirSync(logDirectory);
}

// Création du flux d'écriture (mode 'append' pour ajouter à la suite)
const logStream = fs.createWriteStream(logFilePath, { flags: 'a' });

/**
 * Enregistre un message dans le fichier de log
 * @param {string} room - La salle de discussion
 * @param {string} senderId - L'ID de l'expéditeur
 * @param {string} content - Le contenu du message
 */
const logMessage = (room, senderId, content) => {
    const timestamp = new Date().toISOString();
    const logEntry = `[${timestamp}] [Room: ${room}] [Sender: ${senderId}]: ${content}\n`;
    
    // Écriture dans le fichier
    logStream.write(logEntry);
    
    // Optionnel : Afficher aussi dans la console pour le développement
    console.log(`[LOG] ${logEntry.trim()}`);
};

module.exports = { logMessage };
