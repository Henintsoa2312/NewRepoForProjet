import bcrypt from 'bcryptjs';

export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  const { name, email, password, specialty, diplomaNumber, consent } = body;

  // Validation des champs
  if (!name || !email || !password || !diplomaNumber || !consent) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Tous les champs sont obligatoires.',
    });
  }

  const emailRegex = /^[^\s@]+@gmail\.com$/;
  if (!emailRegex.test(email)) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Veuillez utiliser une adresse @gmail.com.',
    });
  }

  if (consent !== true) {
    throw createError({
      statusCode: 400,
      statusMessage: "Vous devez autoriser la vérification pour vous inscrire.",
    });
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  try {
    // Insertion dans la table doctors avec le statut de vérification
    const [rows] = await pool.execute(
      'INSERT INTO doctors (name, email, password, specialty, diploma_number, status) VALUES (?, ?, ?, ?, ?, ?)',
      [name, email, hashedPassword, specialty || 'Généraliste', diplomaNumber, 'pending_verification']
    );
    return { success: true, message: 'Inscription réussie !', id: rows.insertId };
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      throw createError({ statusCode: 409, statusMessage: 'Cet email est déjà utilisé.' });
    }
    console.error('Register API Error:', error);
    throw createError({ statusCode: 500, statusMessage: 'Erreur serveur lors de l\'inscription.' });
  }
});
