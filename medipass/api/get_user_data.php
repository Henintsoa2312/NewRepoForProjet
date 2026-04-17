<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");

    $servername = "localhost";
    $username = "root";
    $password = "";
    $dbname = "medipass_db";

    $conn = new mysqli($servername, $username, $password, $dbname);

    if ($conn->connect_error) {
        echo json_encode(['success' => false, 'message' => 'Erreur de connexion a la BDD: ' . $conn->connect_error]);
        exit();
    }

    $email = isset($_GET['email']) ? $_GET['email'] : '';

    if (empty($email)) {
        echo json_encode(['success' => false, 'message' => 'Le parametre email est manquant.']);
        exit();
    }

    // On sélectionne toutes les informations utiles de l'utilisateur
    $stmt = $conn->prepare("SELECT nom, prenom, email, date_naissance, sexe, photo_url FROM patients WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user_data = $result->fetch_assoc();
        echo json_encode([
            'success' => true,
            'data' => $user_data
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Utilisateur non trouve.']);
    }

    $stmt->close();
    $conn->close();

?>
