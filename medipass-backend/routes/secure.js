const express = require('express');
const router = express.Router();
const db = require('../config/db');
const authMiddleware = require('../middleware/verifyToken'); // MODIFIÉ

// POST /api/secure/generate-code
router.post('/generate-code', authMiddleware, (req, res) => {
    const patientId = req.user.id;

    console.log(`Génération de code pour le patient ID: ${patientId}`);

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 8; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    const formattedCode = `${code.substring(0, 4)}-${code.substring(4, 8)}`;

    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    const query = 'INSERT INTO access_codes (id_patient, code, expires_at) VALUES (?, ?, ?)';
    db.query(query, [patientId, formattedCode, expiresAt], (err, result) => {
        if (err) {
            console.error("Erreur SQL:", err);
            return res.status(500).json({ message: "Erreur serveur." });
        }
        
        console.log(`Code ${formattedCode} généré pour le patient ID: ${patientId}`);
        res.status(201).json({ code: formattedCode });
    });
});

module.exports = router;