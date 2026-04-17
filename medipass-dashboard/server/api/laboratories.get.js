import { pool } from '../utils/db';

export default defineEventHandler(async (event) => {
  try {
    const [rows] = await pool.query('SELECT * FROM laboratories');
    return rows;
  } catch (error) {
    console.error('Erreur base de données:', error);
    throw createError({
      statusCode: 500,
      statusMessage: 'Erreur lors de la récupération des laboratoires',
    });
  }
});