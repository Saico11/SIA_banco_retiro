<?php
require 'db.php';
$id_cliente = $_GET['id_cliente'] ?? null;

if ($id_cliente) {
    $stmt = $pdo->prepare("
        SELECT cb.Saldo_Actual
        FROM CuentaBancaria cb
        WHERE cb.ID_Cliente = :id_cliente
        LIMIT 1
    ");
    $stmt->execute([':id_cliente' => $id_cliente]);
    $saldo = $stmt->fetchColumn();

    echo "<h3>💰 Saldo actual: S/ " . number_format($saldo, 2) . "</h3>";
} else {
    echo "ID de cliente no proporcionado.";
}
?>

