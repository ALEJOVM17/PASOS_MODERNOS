<?php
$nofactura = $_POST['nofactura'];
$mpago = $_POST['mpago'];
$referenciapago = $_POST['referenciapago'];
echo $nofactura;
date_default_timezone_set('America/Toronto');
$date = date('Y-m-d H:i:s');
$conex = new mysqli("localhost", "rsroofin_alejo2024", "Yerik20242**", "rsroofin_proyectounad");

$conex->autocommit(false);
try {
    $conex->query("INSERT INTO factura2  SELECT * FROM factura WHERE nofactura = $nofactura");
    $conex->query("UPDATE factura SET fechafinal = '$date' WHERE nofactura = $nofactura");
    $conex->query("UPDATE factura2 SET fechafinal = '$date' WHERE nofactura = $nofactura");
    $conex->query("INSERT INTO detallefactura2 SELECT * FROM detallefactura WHERE nofactura = $nofactura");
    $conex->query("UPDATE factura SET estado = 2, mpago = '$mpago', referenciapago = '$referenciapago'  WHERE nofactura = $nofactura");
    $conex->query("UPDATE factura2 SET estado = 2, mpago = '$mpago', referenciapago = '$referenciapago' WHERE nofactura = $nofactura");
    /*$conex->query("DELETE FROM detallefactura WHERE nofactura = $nofactura");*/
    $conex->commit();
} catch (Exception $e) {
    $conex->rollback();
    echo 'Something fails: ',  $e->getMessage(), "\n";
}
mysqli_close($conex);
header("location: ventas.php");
?> 
