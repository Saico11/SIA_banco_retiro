<?php
require 'db.php';
$id_cliente = $_GET['id_cliente'] ?? null;
$id_cajero = $_GET['id_cajero'] ?? null;
$mensaje = '';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $cuenta_destino = $_POST['cuenta_destino'] ?? '';
    $monto = $_POST['monto'] ?? 0;

    try {
        $stmt = $pdo->prepare("CALL RealizarTransferencia(:id_cliente, :id_cajero, :cuenta_destino, :monto)");
        $stmt->execute([
            ':id_cliente' => $id_cliente,
            ':id_cajero' => $id_cajero,
            ':cuenta_destino' => $cuenta_destino,
            ':monto' => $monto
        ]);
        $mensaje = "✅ Transferencia realizada con éxito.";
    } catch (PDOException $e) {
        $mensaje = "❌ Error: " . $e->getMessage();
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Transferencia</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container py-5">
    <h3>Transferir a otra cuenta</h3>
    <?php if ($mensaje): ?>
        <div class="alert alert-info"><?= $mensaje ?></div>
    <?php endif; ?>
    <form method="POST">
        <div class="mb-3">
            <label for="cuenta_destino" class="form-label">Número de cuenta destino</label>
            <input type="text" class="form-control" name="cuenta_destino" required>
        </div>
        <div class="mb-3">
            <label for="monto" class="form-label">Monto a transferir</label>
            <input type="number" step="0.01" class="form-control" name="monto" required>
        </div>
        <button type="submit" class="btn btn-primary">Transferir</button>
    </form>
</body>
</html>

