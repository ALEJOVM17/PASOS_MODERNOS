<?php
include "../conexion.php";
if (!empty($_POST)) {
  $alert = "";
  if (empty($_POST['mpago'])) {
    $alert = '<p class"error">Todo los campos son requeridos</p>';
  } else {
    $nofactura = $_POST['nofactura'];
    $mpago = $_POST['mpago'];
    $referenciapago = $_POST['referenciapago'];
    
    $conexion->autocommit(false);
try {
    $conexion->query("INSERT INTO factura2  SELECT * FROM factura WHERE nofactura = $nofactura");
    $conexion->query("UPDATE factura SET fechafinal = '$date' WHERE nofactura = $nofactura");
    $conexion->query("UPDATE factura2 SET fechafinal = '$date' WHERE nofactura = $nofactura");
    $conexion->query("INSERT INTO detallefactura2 SELECT * FROM detallefactura WHERE nofactura = $nofactura");
    $conexion->query("UPDATE factura SET estado = 2, mpago = '$mpago', referenciapago = '$referenciapago' WHERE nofactura = $nofactura");
    $conexion->query("UPDATE factura2 SET estado = 2,mpago = '$mpago', referenciapago = '$referenciapago' WHERE nofactura = $nofactura");
    /*$conex->query("DELETE FROM detallefactura WHERE nofactura = $nofactura");*/
    $conex->commit();
} catch (Exception $e) {
    $conex->rollback();
    echo 'Something fails: ',  $e->getMessage(), "\n";
    }  
  }
}
// Mostrar Datos

if (empty($_REQUEST['nofactura'])) {
  header("Location: ventas.php");
}
$nofactura = $_REQUEST['nofactura'];
$sql = mysqli_query($conexion, "SELECT * FROM factura WHERE nofactura = $nofactura");
$result_sql = mysqli_num_rows($sql);
if ($result_sql == 0) {
  header("Location: ventas.php");
} else {
  while ($data = mysqli_fetch_array($sql)) {
    $nofactura = $data['nofactura'];
    $metodoabono = $data['mpago'];
    $referenciaabono = $data['referenciapago'];
  }
}
?>
<?php include_once "includes/header.php"; ?>

        <!-- Begin Page Content -->
        <div class="container-fluid">

          <div class="row">
            <div class="col-lg-6 m-auto">

              <form class="" action="" method="post">
                <?php echo isset($alert) ? $alert : ''; ?>
                <input type="hidden" name="nofactura" value="<?php echo $nofactura; ?>">
                
                <div class="form-group">
                  <label for="mpago">Metodo de pago</label>
                  <select type="text" placeholder="Ingrese Nombre" name="mpago" class="form-control" id="mpago" value="<?php echo $mpago; ?>">
                    <option value="efectivo">Efectivo</option>
                    <option value="tarjetaCredito">Tarjeta débito</option>
                    <option value="tarjetaDebido">Tarjeta crédito</option>
                    <option value="daviplata">Daviplata</option>
                    <option value="nequi">Nequi</option>
                    <option value="trasnferencia">Transferencia</option>
                  </select>
                </div>
                <div class="form-group">
                  <label for="referenciapago">Referencia de pago</label>
                  <input type="text" placeholder="Ingrese referencia de pago" name="referenciapago" class="form-control" id="referenciapago" value="<?php echo $referenciapago; ?>">
                </div>
                
                <button type="submit" class="btn btn-success"><i class="fas fa-user-edit"></i>Realizar descarga</button>
              </form>
            </div>
          </div>


        </div>
        <!-- /.container-fluid -->

      </div>
      <!-- End of Main Content -->
      <?php include_once "includes/footer.php"; ?>