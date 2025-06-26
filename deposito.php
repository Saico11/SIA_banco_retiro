<?php
require 'db.php';
$tarjeta = $_GET['tarjeta'];

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $cuenta = $_POST['cuenta'];
    $monto = $_POST['monto'];
    $cajero = $_POST['cajero'];
    $codigo = $_POST['codigo'];

    try {
        $stmt = $pdo->prepare("CALL RealizarDeposito(:cuenta, :cajero, :monto, :codigo)");
        $stmt->execute([
            ':cuenta' => $cuenta,
            ':cajero' => $cajero,
            ':monto' => $monto,
            ':codigo' => $codigo
        ]);
        echo "✅ Depósito realizado.";
    } catch (PDOException $e) {
        echo "❌ Error: " . $e->getMessage();
    }
}
?>

<form method="POST">
    <h3>Depósito</h3>
    Cuenta destino: <input type="text" name="cuenta"><br>
    Monto: <input type="number" name="monto" step="0.01"><br>
    ID Cajero: <input type="number" name="cajero"><br>
    Código cuenta contable: <input type="number" name="codigo"><br>
    <input type="submit" value="Depositar">
</form>

