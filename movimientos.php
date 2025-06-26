<?php
require 'db.php';
$id_cliente = $_GET['id_cliente'] ?? null;

if ($id_cliente) {
    $stmt = $pdo->prepare("
        SELECT m.fecha, m.monto, m.codigo_cuenta
        FROM movimientos m
        JOIN cuentabancaria cb ON m.numero_cuenta = cb.numero_cuenta
        WHERE cb.id_cliente = :id_cliente
        ORDER BY m.fecha DESC
    ");
    $stmt->execute([':id_cliente' => $id_cliente]);
    $movimientos = $stmt->fetchAll(PDO::FETCH_ASSOC);
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Movimientos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container py-5">
    <h3>📜 Historial de Movimientos</h3>

    <?php if (empty($movimientos)): ?>
        <p>No hay movimientos registrados.</p>
    <?php else: ?>
        <ul class="list-group">
            <?php foreach ($movimientos as $mov): ?>
                <li class="list-group-item">
                    <?= htmlspecialchars($mov['fecha']) ?> - 
                    S/ <?= number_format($mov['monto'], 2) ?> 
                    (Código <?= htmlspecialchars($mov['codigo_cuenta']) ?>)
                </li>
            <?php endforeach; ?>
        </ul>
    <?php endif; ?>
</body>
</html>

