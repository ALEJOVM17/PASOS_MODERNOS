 <?php include_once "includes/header.php";
  include "../conexion.php";
  if (!empty($_POST)) {
    $alert = "";
    if (empty($_POST['concepto']) || empty($_POST['precio']) ) {
      $alert = '<div class="alert alert-danger" role="alert">
                Todo los campos son obligatorios
              </div>';
    } else {
      
      $concepto = $_POST['concepto'];
      $precio = $_POST['precio'];
      date_default_timezone_set('America/Toronto');
      $date = date('Y-m-d H:i:s');
      $usuario_id = $_SESSION['idUser'];

      $query_insert = mysqli_query($conexion, "INSERT INTO costos(concepto,precio,fecha,usuario_id) values ('$concepto', '$precio', '$date','$usuario_id')");
      if ($query_insert) {
        $alert = '<div class="alert alert-primary" role="alert">
                Producto Registrado
              </div>';
      } else {
        $alert = '<div class="alert alert-danger" role="alert">
                Error al registrar el producto
              </div>';
      }
    }
  }
  ?>

 <!-- Begin Page Content -->
 <div class="container-fluid">

   <!-- Page Heading -->
   <div class="d-sm-flex align-items-center justify-content-between mb-4">
     <h1 class="h3 mb-0 text-gray-800">Nuevo costo</h1>
     <a href="lista_salidas.php" class="btn btn-primary">Regresar</a>
   </div>

   <!-- Content Row -->
   <div class="row">
     <div class="col-lg-6 m-auto">
       <form action="" method="post" autocomplete="off">
         <?php echo isset($alert) ? $alert : ''; ?>
         <div class="form-group">
           <label for="producto">Concepto</label>
           <select type="text" placeholder="Ingrese concepto de salida" name="concepto" id="concepto" class="form-control">
              <option value="ARRIENDO">ARRIENDO</option>
              <option value="AGUA">AGUA</option>
              <option value="LUZ">LUZ</option>
              <option value="GAS">GAS</option>
              <option value="INTERNET">INTERNET</option>
              <option value="NOMINA">NOMINA</option>
              <option value="OTROS">OTROS</option>
            </select>
         </div>
         <div class="form-group">
           <label for="producto">Precio</label>
           <input type="text" placeholder="Ingrese precio" name="precio" id="precio" class="form-control">
         </div>
         <input type="submit" value="Resgristrar costo" class="btn btn-primary">
       </form>
     </div>
   </div>

 </div>
 <!-- /.container-fluid -->

 </div>
 <!-- End of Main Content -->
 <?php include_once "includes/footer.php"; ?>