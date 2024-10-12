<?php

$nofactura = $_POST['nofactura'];
date_default_timezone_set('America/Toronto');
$date = date('Y-m-d H:i:s');
$conex = new mysqli("localhost", "rsroofin_alejo2024", "Yerik20242**", "rsroofin_proyectounad");

$conex->autocommit(false);
try {
    $conex->query("INSERT INTO facturanula  SELECT * FROM factura WHERE nofactura = $nofactura");
    $conex->query("UPDATE factura SET fechafinal = '$date' WHERE nofactura = $nofactura");
    $conex->query("UPDATE facturanula SET fechafinal = '$date' WHERE nofactura = $nofactura");
    $conex->query("INSERT INTO detallefacturanula SELECT * FROM detallefactura WHERE nofactura = $nofactura");
    $conex->query("UPDATE factura SET estado = 3 WHERE nofactura = $nofactura");
    $conex->query("UPDATE facturanula SET estado = 3 WHERE nofactura = $nofactura");
    /*$conex->query("DELETE FROM detallefactura WHERE nofactura = $nofactura");*/
    $conex->commit();
} catch (Exception $e) {
    $conex->rollback();
    echo 'Something fails: ',  $e->getMessage(), "\n";
}
mysqli_close($conex);
header("location: ventas.php");
?> 
