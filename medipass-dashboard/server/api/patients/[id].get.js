import { pool } from '../../utils/db';

export default defineEventHandler(async (event) => {
  const userCookie = getCookie(event, 'user');
  if (!userCookie) {
    throw createError({ statusCode: 401, statusMessage: 'Non autorisé' });
  }
  
  const doctor = JSON.parse(userCookie);
  const doctorId = doctor.id;
  const patientId = event.context.params.id;

  try {
    // Vérifie que le patient est bien lié au docteur et récupère ses infos
    const [rows] = await pool.query(
      `SELECT p.id_patient as id, CONCAT(p.nom, ' ', p.prenom) as name, p.email, p.telephone as phone, p.date_creation as created_at, p.photo_url
       FROM patients p
       JOIN doctor_patient dp ON p.id_patient = dp.patient_id
       WHERE dp.doctor_id = ? AND p.id_patient = ?`,
      [doctorId, patientId]
    );

    if (rows.length === 0) {
        throw createError({ statusCode: 404, statusMessage: 'Patient non trouvé ou non lié.' });
    }
    return rows[0];
  } catch (error) {
    console.error('Get Patient Details API Error:', error);
    throw createError({ statusCode: 500, statusMessage: 'Erreur serveur.' });
  }
});