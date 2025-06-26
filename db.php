<?php
$host = "localhost";
$dbname = "cajero_real"; // cambia esto
$user = "postgres";         // cambia esto
$password = "080100";  // cambia esto

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
} catch (PDOException $e) {
    die("Error en conexión: " . $e->getMessage());
}
?>

