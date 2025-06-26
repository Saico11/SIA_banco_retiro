<?php
$id_cliente = $_GET['id_cliente'];
$id_cajero = $_GET['id_cajero'];
?>

<!DOCTYPE html>
<html>
<head>
    <title>Menú del Cajero</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container py-5">
    <h3>Operaciones disponibles</h3>
    <ul class="list-group">
        <li class="list-group-item"><a href="retiro.php?id_cliente=<?= $id_cliente ?>&id_cajero=<?= $id_cajero ?>">💸 Retirar</a></li>
        <li class="list-group-item"><a href="saldo.php?id_cliente=<?= $id_cliente ?>">💰 Consultar saldo</a></li>
        <li class="list-group-item"><a href="movimientos.php?id_cliente=<?= $id_cliente ?>">📜 Ver movimientos</a></li>
        <li class="list-group-item">
    <a href="transferencia.php?id_cliente=<?= $id_cliente ?>&id_cajero=<?= $id_cajero ?>">🔁 Transferir a otra cuenta</a>
        </li>

    </ul>
</body>
</html>

