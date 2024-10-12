<?php
$conex = new mysqli("localhost", "rsroofin_alejo2024", "Yerik20242**", "rsroofin_proyectounad");

$conex->autocommit(false);
try {
    $conex->query("UPDATE 
    estadistica AS a INNER JOIN ( SELECT a.dia, SUM(b.totalfactura) AS ventradas FROM estadistica a 
                      INNER JOIN factura b ON a.dia = DATE(b.fecha) GROUP BY a.dia ) b ON a.dia = b.dia
                          SET a.ventradas=b.ventradas");
    $conex->query("UPDATE 
    estadistica AS a INNER JOIN ( SELECT a.dia, SUM(c.cantidad) AS pentradas FROM estadistica a 
                      INNER JOIN factura b ON a.dia = DATE(b.fecha)
                      INNER JOIN detallefactura c ON b.nofactura = c.nofactura GROUP BY a.dia ) b ON a.dia = b.dia
                        SET a.pentradas=b.pentradas");
    $conex->query("UPDATE 
    estadistica AS a INNER JOIN ( SELECT a.dia, SUM(b.abono) AS abono, b.estado FROM estadistica a 
                      INNER JOIN factura b ON a.dia = DATE(b.fecha) WHERE b.estado = 2 OR b.estado = 1 GROUP BY a.dia ) b ON a.dia = b.dia
                      SET a.abono=b.abono");
    $conex->query("UPDATE estadistica SET promedioentradas = ventradas/pentradas");
   
   
   $conex->query("UPDATE 
    estadistica AS a INNER JOIN ( SELECT a.dia, SUM(b.saldo) AS vsalidas FROM estadistica a 
                      INNER JOIN factura2 b ON a.dia = DATE(b.fechafinal) GROUP BY a.dia ) b ON a.dia = b.dia
                      SET a.vsalidas=b.vsalidas");
    $conex->query("UPDATE 
    estadistica AS a INNER JOIN ( SELECT a.dia, SUM(c.cantidad) AS psalidas FROM estadistica a 
                      INNER JOIN factura2 b ON a.dia = DATE(b.fechafinal)
                      INNER JOIN detallefactura2 c ON b.nofactura = c.nofactura GROUP BY a.dia ) b ON a.dia = b.dia
                        SET a.psalidas=b.psalidas");
    $conex->query("UPDATE estadistica SET promediosalidas = vsalidas/psalidas");
    
    
    $conex->query("UPDATE 
    estadistica AS a 
        INNER JOIN ( SELECT a.dia, SUM(b.precio) AS gastos
                        FROM estadistica a 
                          INNER JOIN salidas b 
                           ON a.dia = DATE(b.fecha)
                          GROUP BY a.dia 
                        ) b ON a.dia = b.dia
             SET a.gastos=b.gastos");
    
    $conex->query("UPDATE estadistica SET neto = vsalidas-gastos+abono");
    
    $conex->commit();
} catch (Exception $e) {
    $conex->rollback();
    echo 'Something fails: ',  $e->getMessage(), "\n";
}
mysqli_close($conex);
header("location: acaja.php");
?> 

