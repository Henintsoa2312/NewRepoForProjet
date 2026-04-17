const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken'); // IMPORT AJOUTÉ
const db = require('../config/db');

// ... (la route /register ne change pas) ...
router.post('/register', async (req, res) => {
    console.log("======================================================");
    console.log("NOUVELLE REQUÊTE SUR /api/auth/register");
    console.log("Timestamp:", new Date().toISOString());
    console.log("-----------------------------------------");
    console.log("req.body entier:", JSON.stringify(req.body, null, 2));

    const { nom, prenom, dateNaissance: date_naissance_val, sexe, telephone, email, password } = req.body;

    console.log("-----------------------------------------");
    console.log("Détails extraits de req.body:");
    console.log(`Nom: ${nom} (Type: ${typeof nom})`);
    console.log(`Prénom: ${prenom} (Type: ${typeof prenom})`);
    console.log(`Date de Naissance: ${date_naissance_val} (Type: ${typeof date_naissance_val})`);
    console.log(`Sexe: ${sexe} (Type: ${typeof sexe})`);
    console.log(`Téléphone: ${telephone} (Type: ${typeof telephone})`);
    console.log(`Email: ${email} (Type: ${typeof email})`);
    console.log(`Password: ${password ? '[PRÉSENT]' : '[MANQUANT]'}`); // Ne pas logger le mot de passe réel en production
    console.log("-----------------------------------------");

    // Vérification initiale des champs requis
    if (!nom || !prenom || !date_naissance_val || !sexe || !telephone || !email || !password) {
        console.log("VALIDATION ÉCHOUÉE: Un ou plusieurs champs sont manquants ou vides.");
        console.log("Réponse envoyée: status 400");
        console.log("======================================================");
        return res.status(400).json({ success: false, message: 'Tous les champs sont requis.' });
    }

    // Validation supplémentaire
    if (password.length < 6) {
        console.log("VALIDATION ÉCHOUÉE: Le mot de passe est trop court.");
        console.log("Réponse envoyée: status 400");
        console.log("======================================================");
        return res.status(400).json({ success: false, message: 'Le mot de passe doit contenir au moins 6 caractères.' });
    }

    console.log("VALIDATION PASSÉE: Tous les champs requis sont présents et valides.");
    console.log("-----------------------------------------");
    console.log("AVANT BLOC TRY: Préparation pour hachage et requête DB.");
    console.log("-----------------------------------------");

    try {
        console.log("DANS BLOC TRY: Début du hachage du mot de passe.");
        const salt = await bcrypt.genSalt(10);
        console.log("DANS BLOC TRY: Salt généré.");
        const hashedPassword = await bcrypt.hash(password, salt);
        console.log("DANS BLOC TRY: Mot de passe haché:", hashedPassword.substring(0, 10) + "..."); // Afficher seulement une partie pour confirmation
        console.log("-----------------------------------------");

        const query = 'INSERT INTO patients (nom, prenom, date_naissance, sexe, telephone, email, password) VALUES (?, ?, ?, ?, ?, ?, ?)';
        
        console.log("DANS BLOC TRY: Préparation pour exécuter db.query.");
        console.log("Requête SQL:", query);
        const queryParams = [nom, prenom, date_naissance_val, sexe, telephone, email, hashedPassword];
        console.log("Valeurs pour SQL:", JSON.stringify(queryParams)); // Afficher les paramètres
        console.log("-----------------------------------------");

        db.query(query, queryParams, (err, result) => {
            console.log(">>> DANS CALLBACK DB.QUERY: Entrée dans le callback. <<<"); // Log crucial
            console.log("-----------------------------------------");
            if (err) {
                console.error("DANS CALLBACK DB.QUERY: Erreur SQL détectée.");
                console.error("Erreur SQL lors de l'insertion:", JSON.stringify(err, Object.getOwnPropertyNames(err))); // Log complet de l'erreur
                console.error("Code d'erreur SQL:", err.code);
                console.error("Message d'erreur SQL:", err.message);
                console.log("-----------------------------------------");

                if (!res.headersSent) {
                    if (err.code === 'ER_DUP_ENTRY') {
                        let duplicateMessage = 'Une valeur dupliquée a été détectée (email ou téléphone déjà utilisé).';
                        if (err.message.toLowerCase().includes('email')) {
                            duplicateMessage = 'Cet email est déjà utilisé.';
                        } else if (err.message.toLowerCase().includes('telephone')) {
                            duplicateMessage = 'Ce numéro de téléphone est déjà utilisé.';
                        }
                        console.log("Réponse envoyée: status 409 (Duplicata)");
                        console.log("======================================================");
                        return res.status(409).json({ success: false, message: duplicateMessage });
                    }
                    console.log("Réponse envoyée: status 500 (Erreur SQL interne)");
                    console.log("======================================================");
                    return res.status(500).json({ success: false, message: 'Erreur serveur lors de l\'enregistrement des données.' });
                } else {
                    console.log("DANS CALLBACK DB.QUERY (ERREUR): Headers déjà envoyés. Impossible d'envoyer une nouvelle réponse d'erreur.");
                    console.log("======================================================");
                }
            } else { // Si pas d'erreur (err est null ou undefined)
                console.log("DANS CALLBACK DB.QUERY: Inscription réussie (pas d'erreur SQL).");
                console.log("Résultat de l'insertion:", JSON.stringify(result));
                console.log("-----------------------------------------");
                if (!res.headersSent) {
                    console.log("Réponse envoyée: status 201 (Inscription réussie)");
                    console.log("======================================================");
                    return res.status(201).json({ success: true, message: 'Inscription réussie!' });
                } else {
                     console.log("DANS CALLBACK DB.QUERY (SUCCÈS): Headers déjà envoyés. Impossible d'envoyer une nouvelle réponse de succès.");
                     console.log("======================================================");
                }
            }
        });
        // Ce log s'exécute AVANT que le callback de db.query ne soit appelé.
        console.log("APRÈS APPEL DB.QUERY (synchrone): L'appel à db.query a été initié. Le callback s'exécutera de manière asynchrone.");
        console.log("Le serveur attend maintenant la fin de l'opération de base de données...");
        console.log("-----------------------------------------");

    } catch (error) {
        console.error("ERREUR DANS BLOC CATCH PRINCIPAL (avant ou pendant hachage):", JSON.stringify(error, Object.getOwnPropertyNames(error)));
        console.log("-----------------------------------------");
        if (!res.headersSent) {
            console.log("Réponse envoyée: status 500 (Erreur catch principal)");
            console.log("======================================================");
            res.status(500).json({ success: false, message: 'Erreur serveur inattendue lors du processus d\'inscription.', error: error.message });
        } else {
            console.log("ERREUR DANS BLOC CATCH PRINCIPAL: Headers déjà envoyés.");
            console.log("======================================================");
        }
    }
});


// Route de connexion : POST /api/auth/login (MODIFIÉE)
router.post('/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ success: false, message: 'Email et mot de passe sont requis.' });
    }

    const query = 'SELECT * FROM patients WHERE email = ?';
    db.query(query, [email], async (err, results) => {
        if (err) {
            return res.status(500).json({ success: false, message: 'Erreur serveur lors de la connexion.' });
        }

        if (results.length === 0) {
            return res.status(401).json({ success: false, message: 'Email ou mot de passe incorrect.' });
        }

        const patient = results[0];
        const isMatch = await bcrypt.compare(password, patient.password);

        if (!isMatch) {
            return res.status(401).json({ success: false, message: 'Email ou mot de passe incorrect.' });
        }

        // CRÉATION DU TOKEN JWT
        const payload = { user: { id: patient.id_patient } };
        const token = jwt.sign(
            payload,
            process.env.JWT_SECRET,
            { expiresIn: '1h' } // Le token expirera dans 1 heure
        );

        res.status(200).json({
            success: true,
            message: 'Connexion réussie!',
            token: token // On envoie le token au client
        });
    });
});

module.exports = router;
