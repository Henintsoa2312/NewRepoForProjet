<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Fonction pour écrire dans un fichier de log pour le débogage
function write_log($message) {
    $logFile = 'upload_debug.log'; // Le fichier de log sera dans le même dossier (api/)
    $formatted_message = date('Y-m-d H:i:s') . ' - ' . $message . PHP_EOL;
    file_put_contents($logFile, $formatted_message, FILE_APPEND);
}

write_log("--- NOUVELLE REQUETE ---");

header('Content-Type: application/json');

// --- Connexion à la base de données ---
$host = 'localhost';
$dbname = 'medipass_db';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    write_log("Connexion à la BDD 'medipass_db' réussie.");
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Erreur de connexion a la base de donnees: ' . $e->getMessage()]);
    exit();
}

if (isset($_POST['email']) && isset($_FILES['photo'])) {
    $email = $_POST['email'];
    $photo = $_FILES['photo'];

    if ($photo['error'] !== UPLOAD_ERR_OK) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Erreur lors de l\'upload. Code: ' . $photo['error']]);
        exit();
    }

    $uploadDir = '../uploads/';
    $absoluteUploadDir = realpath(dirname(__FILE__) . '/' . $uploadDir);

    if (!is_writable($absoluteUploadDir)) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => "Erreur de permission serveur: le dossier n'est pas accessible en écriture."]);
        exit();
    }

    $extension = pathinfo($photo['name'], PATHINFO_EXTENSION);
    $newFileName = uniqid('profile_', true) . '.' . $extension;
    $uploadFile = $absoluteUploadDir . '/' . $newFileName;

    if (move_uploaded_file($photo['tmp_name'], $uploadFile)) {
        $photoUrl = 'http://10.0.2.2/medipass/uploads/' . $newFileName;

        try {
            $sql = "UPDATE patients SET photo_url = :photo_url WHERE email = :email";
            $stmt = $pdo->prepare($sql);
            $stmt->execute(['photo_url' => $photoUrl, 'email' => $email]);
            write_log("SUCCES: Mise à jour de la table 'patients'.");

            echo json_encode(['success' => true, 'message' => 'Photo mise a jour avec succes.', 'new_url' => $photoUrl]);
        } catch (PDOException $e) {
            write_log("ERREUR BDD (Update): " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Erreur BDD (Update): ' . $e->getMessage()]);
        }
    } else {
        write_log("ECHEC: move_uploaded_file a retourné false. Erreur PHP: " . error_get_last()['message']);
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Le serveur n\'a pas pu déplacer le fichier.']);
    }

} else {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Donnees manquantes: email ou photo non recus.']);
}
?>