<?php
$host = 'localhost';
$dbname = 'cajero_real';     // cambia si usas otro nombre
$user = 'postgres';          // o el usuario que configuraste
$password = '080100'; // reemplaza con tu clave

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    echo "✅ Conexión exitosa con PDO y PostgreSQL.\n";
} catch (PDOException $e) {
    echo "❌ Error de conexión: " . $e->getMessage() . "\n";
}
?>

