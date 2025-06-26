<?php
require 'db.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $dni = $_POST['dni'];

    $stmt = $pdo->prepare("SELECT ID_Cliente FROM Cliente WHERE DNI = :dni");
    $stmt->execute([':dni' => $dni]);
    $cliente = $stmt->fetch();

    if ($cliente) {
        header("Location: cajero.php?id_cliente=" . $cliente['id_cliente']);
        exit;
    } else {
        $error = "DNI no encontrado.";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Ingreso al Cajero</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container py-5">
    <h2 class="mb-4">Ingreso al Cajero</h2>
    <form method="POST" class="w-50">
        <div class="mb-3">
            <label for="dni" class="form-label">DNI del Cliente</label>
            <input type="text" class="form-control" name="dni" required>
        </div>
        <button type="submit" class="btn btn-primary">Ingresar</button>
        <?php if (isset($error)) echo "<div class='text-danger mt-3'>$error</div>"; ?>
    </form>
</body>
</html>

