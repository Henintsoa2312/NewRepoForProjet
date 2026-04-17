export default defineEventHandler(async (event) => {
  try {
    // Exécution de la requête SQL pour récupérer les docteurs
    const [rows] = await pool.query('SELECT * FROM doctors');
    return rows;
  } catch (error) {
    console.error('Erreur base de données:', error);
    throw createError({
      statusCode: 500,
      statusMessage: 'Erreur lors de la récupération des docteurs',
    });
  }
});

