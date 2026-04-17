import { pool } from '../utils/db';

export default defineEventHandler(async (event) => {
  const userCookie = getCookie(event, 'user');
  if (!userCookie) throw createError({ statusCode: 401, statusMessage: 'Non autorisé' });
  const doctor = JSON.parse(userCookie);
  
  const body = await readBody(event);
  const { patientId, content } = body;

  if (!patientId || !content) throw createError({ statusCode: 400, statusMessage: 'Contenu requis' });

  await pool.execute(
    'INSERT INTO prescriptions (doctor_id, patient_id, content) VALUES (?, ?, ?)',
    [doctor.id, patientId, content]
  );

  return { success: true, message: 'Prescription envoyée' };
});