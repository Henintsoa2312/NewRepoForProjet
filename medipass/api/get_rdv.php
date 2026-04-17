<?php
    header('Content-Type: application/json; charset=utf-8');

    // --- Connexion à la base de données ---
    $host = 'localhost';
    $dbname = 'medipass_db';
    $username = 'root';
    $password = '';

    try {
        $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Erreur de connexion a la BDD: ' . $e->getMessage()]);
        exit();
    }

    // --- Vérification de l'email reçu ---
    if (!isset($_GET['email']) || empty($_GET['email'])) {
        http_response_code(400); // Bad Request
        echo json_encode(['success' => false, 'message' => 'Email du patient manquant.']);
        exit();
    }

    $patientEmail = $_GET['email'];

    // --- Récupération des rendez-vous ---
    try {
        // On sélectionne les rendez-vous futurs, triés du plus proche au plus lointain
        $sql = "SELECT id, medecin_nom, specialite, date_rdv, lieu, statut
                FROM rendez_vous
                WHERE patient_email = :email AND date_rdv >= NOW()
                ORDER BY date_rdv ASC";
            
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['email' => $patientEmail]);
    
        $rdv = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // On renvoie les résultats, même si la liste est vide
        echo json_encode(['success' => true, 'data' => $rdv]);

    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Erreur lors de la recuperation des rendez-vous: ' . $e->getMessage()]);
    }

?>
