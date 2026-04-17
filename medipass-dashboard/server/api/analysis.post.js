import { pool } from '../utils/db';

export default defineEventHandler(async (event) => {
  const userCookie = getCookie(event, 'user');
  if (!userCookie) throw createError({ statusCode: 401, statusMessage: 'Non autorisé' });
  const doctor = JSON.parse(userCookie);
  
  const body = await readBody(event);
  const { patientId, laboratoryId, details } = body;

  if (!patientId || !laboratoryId || !details) throw createError({ statusCode: 400, statusMessage: 'Données incomplètes' });

  await pool.execute(
    'INSERT INTO analysis_requests (doctor_id, patient_id, laboratory_id, details) VALUES (?, ?, ?, ?)',
    [doctor.id, patientId, laboratoryId, details]
  );

  return { success: true, message: 'Demande d\'analyse envoyée' };
});