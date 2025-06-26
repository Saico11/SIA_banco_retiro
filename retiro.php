<?php
require 'db.php';
$id_cliente = $_GET['id_cliente'];
$id_cajero = $_GET['id_cajero'];

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $monto = $_POST['monto'];

    try {
        $stmt = $pdo->prepare("CALL RealizarRetiro(:cliente, :cajero, :monto)");
        $stmt->execute([
            ':cliente' => $id_cliente,
            ':cajero' => $id_cajero,
            ':monto' => $monto
        ]);
        $mensaje = "✅ Retiro exitoso.";
    } catch (PDOException $e) {
        $mensaje = "❌ Error: " . $e->getMessage();
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Retiro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container py-5">
    <h3>Retirar dinero</h3>
    <?php if (isset($mensaje)) echo "<div class='alert alert-info'>$mensaje</div>"; ?>
    <form method="POST">
        <div class="mb-3">
            <label>Monto a retirar</label>
            <input type="number" step="0.01" name="monto" class="form-control" required>
        </div>
        <button class="btn btn-danger">Retirar</button>
    </form>
</body>
</html>

