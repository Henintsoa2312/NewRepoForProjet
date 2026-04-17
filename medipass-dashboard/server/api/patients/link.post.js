import { pool } from '../../utils/db';

export default defineEventHandler(async (event) => {
  const userCookie = getCookie(event, 'user');
  if (!userCookie) {
    throw createError({ statusCode: 401, statusMessage: 'Non autorisé' });
  }
  const doctor = JSON.parse(userCookie);
  const doctorId = doctor.id;

  const body = await readBody(event);
  const { patientCode } = body;

  if (!patientCode || !/^[A-Z0-9]{4}-[A-Z0-9]{4}$/i.test(patientCode)) {
    throw createError({ statusCode: 400, statusMessage: 'Format du code patient invalide.' });
  }

  try {
    // 1. Vérifier le code dans la table access_codes
    // On joint avec la table patients pour récupérer les infos directement
    const [rows] = await pool.execute(
      `SELECT p.id_patient as id, CONCAT(p.nom, ' ', p.prenom) as name, p.email 
       FROM access_codes ac
       JOIN patients p ON ac.id_patient = p.id_patient
       WHERE ac.code = ? 
       AND ac.expires_at > NOW()
       LIMIT 1`,
      [patientCode]
    );

    const patient = rows[0];
    if (!patient) {
      throw createError({ statusCode: 404, statusMessage: 'Code invalide ou expiré.' });
    }

    // 2. Vérifier si le lien existe déjà
    const [linkRows] = await pool.execute(
      'SELECT * FROM doctor_patient WHERE doctor_id = ? AND patient_id = ?',
      [doctorId, patient.id]
    );

    if (linkRows.length > 0) {
      return { success: true, message: 'Ce patient est déjà dans votre liste.', patient };
    }

    // 3. Créer le lien
    await pool.execute('INSERT INTO doctor_patient (doctor_id, patient_id) VALUES (?, ?)', [doctorId, patient.id]);
    return { success: true, message: 'Patient ajouté avec succès !', patient };
  } catch (error) {
    if (error.statusCode) throw error;
    console.error('Link Patient API Error:', error);

    throw createError({ statusCode: 500, statusMessage: error.message || "Erreur serveur lors de l'ajout du patient." });
  }
});