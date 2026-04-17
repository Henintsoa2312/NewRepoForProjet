const jwt = require('jsonwebtoken');

module.exports = function(req, res, next) {
    // Récupérer le token du header 'Authorization'
    const authHeader = req.header('Authorization');

    // Vérifier si le header existe
    if (!authHeader) {
        return res.status(401).json({ msg: 'Accès refusé, token manquant.' });
    }

    // Le token est envoyé comme "Bearer <token>", on ne veut que la partie token
    const tokenParts = authHeader.split(' ');
    if (tokenParts.length !== 2 || tokenParts[0] !== 'Bearer') {
        return res.status(401).json({ msg: 'Format du token invalide, il doit être "Bearer <token>".' });
    }

    const token = tokenParts[1];

    // Vérifier si le token est valide
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        // Si le token est valide, on ajoute le payload de l'utilisateur à la requête
        req.user = decoded.user;
        // On passe à la suite (la route sécurisée)
        next();
    } catch (err) {
        res.status(401).json({ msg: 'Token invalide ou expiré.' });
    }
};