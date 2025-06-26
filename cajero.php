<?php
require 'db.php';
$id_cliente = $_GET['id_cliente'];

$stmt = $pdo->query("SELECT ID_Cajero_Automatico, Ubicacion FROM Cajero_Automatico WHERE Estado = 'Activo'");
$cajeros = $stmt->fetchAll();
?>

<!DOCTYPE html>
<html>
<head>
    <title>Seleccionar Cajero</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container py-5">
    <h3>Selecciona un Cajero Automático</h3>
    <form method="GET" action="menu.php" class="mt-3">
        <input type="hidden" name="id_cliente" value="<?= $id_cliente ?>">
        <div class="mb-3">
            <select name="id_cajero" class="form-select" required>
                <?php foreach ($cajeros as $c): ?>
                    <option value="<?= $c['id_cajero_automatico'] ?>">
                        <?= $c['ubicacion'] ?>
                    </option>
                <?php endforeach; ?>
            </select>
        </div>
        <button class="btn btn-success">Entrar al Cajero</button>
    </form>
</body>
</html>

