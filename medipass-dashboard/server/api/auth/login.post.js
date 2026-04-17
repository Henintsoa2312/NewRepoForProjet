import bcrypt from 'bcryptjs';

export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  const { email, password } = body;

  if (!email || !password) {
    throw createError({ statusCode: 400, statusMessage: 'Email et mot de passe requis.' });
  }

  // Recherche du docteur par email
  const [rows] = await pool.execute('SELECT * FROM doctors WHERE email = ?', [email]);
  const user = rows[0];

  if (!user) {
    throw createError({ statusCode: 401, statusMessage: 'Identifiants incorrects.' });
  }

  // Vérification du mot de passe
  const validPassword = await bcrypt.compare(password, user.password);
  if (!validPassword) {
    throw createError({ statusCode: 401, statusMessage: 'Identifiants incorrects.' });
  }

  // Retourne les infos (sans le mot de passe)
  // Note: Dans un vrai projet, on utiliserait ici un token JWT ou une session
  return { success: true, user: { id: user.id, name: user.name, email: user.email, specialty: user.specialty } };
});

