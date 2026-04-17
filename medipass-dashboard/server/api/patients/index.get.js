import { pool } from '../../utils/db';

export default defineEventHandler(async (event) => {
  const userCookie = getCookie(event, 'user');
  if (!userCookie) {
    throw createError({ statusCode: 401, statusMessage: 'Non autorisé' });
  }
  
  const doctor = JSON.parse(userCookie);
  const doctorId = doctor.id;

  try {
    const [rows] = await pool.query(
      `SELECT p.id_patient as id, CONCAT(p.nom, ' ', p.prenom) as name, p.email, p.telephone as phone, p.date_creation as created_at, p.photo_url
       FROM patients p
       JOIN doctor_patient dp ON p.id_patient = dp.patient_id
       WHERE dp.doctor_id = ?`,
      [doctorId]
    );
    return rows;
  } catch (error) {
    console.error('Get Patients API Error:', error);
    throw createError({ statusCode: 500, statusMessage: 'Erreur lors de la récupération des patients.' });
  }
});