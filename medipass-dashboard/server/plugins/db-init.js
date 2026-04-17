import { pool } from '../utils/db';

export default defineNitroPlugin(async (nitroApp) => {
  try {
    // Création de la table doctors si elle n'existe pas
    await pool.query(`
      CREATE TABLE IF NOT EXISTS doctors (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        specialty VARCHAR(255) DEFAULT 'Généraliste',
        diploma_number VARCHAR(255) NOT NULL,
        status VARCHAR(50) DEFAULT 'pending_verification',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // Table 'patients' : Gérée par l'application mobile (Flutter).
    // Nous ne la créons pas ici pour éviter les conflits de structure.

    // Création de la table access_codes (Gérée par l'app mobile, utilisée pour la liaison)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS access_codes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        patient_id INT NOT NULL,
        code VARCHAR(20) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // Création de la table laboratories
    await pool.query(`
      CREATE TABLE IF NOT EXISTS laboratories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        address VARCHAR(255),
        city VARCHAR(100),
        contact VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // Création de la table analysis_requests (Demandes d'analyses)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS analysis_requests (
        id INT AUTO_INCREMENT PRIMARY KEY,
        doctor_id INT NOT NULL,
        patient_id INT NOT NULL,
        laboratory_id INT NOT NULL,
        details TEXT,
        status VARCHAR(50) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
        FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // Insertion des laboratoires par défaut s'ils n'existent pas
    const [labCount] = await pool.query('SELECT COUNT(*) as count FROM laboratories');
    if (labCount[0].count === 0) {
      const labs = [
        ['CTB (Centre Technique Biomédical)', 'Lot 27 bis Anjoma', 'Toamasina', null],
        ['Laboratoire d’Autocontrôle et d’Analyse Alimentaire GC2A', 'Boulevard Ratsimilaho Ampasimazava', 'Toamasina', null],
        ['Annexe LHAE (Institut Pasteur)', 'Toamasina', 'Toamasina', null],
        ['CTB (Centre Technique Biomédical)', 'Ampasika', 'Mahajanga', null],
        ['Laboratoire de Nosy-Be (LNB)', 'Mahajanga', 'Mahajanga', null],
        ['LNB', 'Immeuble “ARO IMMOBILIER”, Hell Ville', 'Nosy Be', null],
        ['Centre d’Analyses Médicales de Moramanga', 'Lot A 193 Camp des Mariés', 'Moramanga', null],
        ['Centre d’Analyses Médicales de Fianarantsoa (CAMF)', 'Fianarantsoa', 'Fianarantsoa', null],
        ['CTB antenne Fianarantsoa', 'Fianarantsoa', 'Fianarantsoa', null],
        ['CMM Labo', 'Mahamasina, Lot VF 13 (en face de l’Institution Sainte Famille)', 'Antananarivo', '+261 34 92 631 50'],
        ['Health Labo', 'Route d’Analamahitsy (à côté du Ministère de la Communication)', 'Antananarivo', '+261 34 22 299 10 / +261 33 12 169 69'],
        ['LAMA', 'Avenue Gal Gabriel, bâtiment EDBM, Antaninarenina', 'Antananarivo', '+261 20 22 681 21 / +261 20 22 670 40'],
        ['Laboratoire d’Anosy Avaratra', 'Ankadikely (RN3) et Ambatonakanga (24h/7j)', 'Antananarivo', 'RN3: +261 20 24 569 01 / 24h/7j: +261 34 27 746 30'],
        ['Laborama', 'Rue Radama 1er, Tsaralalàna, 11 Lalana Radama', 'Antananarivo', '+261 20 22 336 99'],
        ['Institut Pasteur de Madagascar', 'Avaradoha (principal) et centre de prélèvement à Ankorondrano', 'Antananarivo', '+261 20 22 401 64 / +261 20 22 412 72'],
        ['Labo Chimie Madagascar', 'Aingasoa PK20 – RN1, Ambatomirahavavy. Annexe à Ankorondrano.', 'Ambatomirahavavy', '+261 32 43 229 11']
      ];
      
      await pool.query('INSERT INTO laboratories (name, address, city, contact) VALUES ?', [labs]);
      console.log('Laboratoires par défaut insérés.');
    }

    // Création de la table de liaison doctor_patient
    await pool.query(`
      CREATE TABLE IF NOT EXISTS doctor_patient (
        doctor_id INT NOT NULL,
        patient_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (doctor_id, patient_id),
        FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // Création de la table appointments (Rendez-vous)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS appointments (
        id INT AUTO_INCREMENT PRIMARY KEY,
        doctor_id INT NOT NULL,
        patient_id INT NOT NULL,
        date DATETIME NOT NULL,
        status VARCHAR(50) DEFAULT 'pending',
        type VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // Création de la table prescriptions
    await pool.query(`
      CREATE TABLE IF NOT EXISTS prescriptions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        doctor_id INT NOT NULL,
        patient_id INT NOT NULL,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    console.log('Base de données : Table "doctors" vérifiée/prête.');
  } catch (error) {
    console.error('Erreur d\'initialisation DB:', error);
  }
});