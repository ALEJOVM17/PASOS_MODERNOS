<?php
include_once "includes/header.php";
include "../conexion.php";

if (!empty($_POST)) {
  $alert = "";
  if (empty($_POST['concepto']) || empty($_POST['precio'])) {
    $alert = '<div class="alert alert-primary" role="alert">
              Todos los campos son requeridos
            </div>';
  } else {
    $id_salida = $_GET['id'];
    
    $concepto = $_POST['concepto'];
    $precio = $_POST['precio'];
    $query_update = mysqli_query($conexion, "UPDATE salidas SET concepto = '$concepto', precio = $precio WHERE id = $id_salida");
    if ($query_update) {
      $alert = '<div class="alert alert-primary" role="alert">
              Salida modificada exitosamente
            </div>';
    } else {
      $alert = '<div class="alert alert-primary" role="alert">
                Error al modificar la salida
              </div>';
    }
  }
}

// Validar salida
if (empty($_REQUEST['id'])) {
  header("Location: lista_salidas.php");
} else {
  $id_salida = $_REQUEST['id'];
  if (!is_numeric($id_salida)) {
    header("Location: lista_salidas.php");
  }
  $query_salida = mysqli_query($conexion, "SELECT id, fecha, concepto, precio FROM salidas WHERE id = $id_salida");
  $result_salida = mysqli_num_rows($query_salida);

  if ($result_salida > 0) {
    $data_salida = mysqli_fetch_assoc($query_salida);
  } else {
    header("Location: lista_salidas.php");
  }
}
?>
<!-- Begin Page Content -->
<div class="container-fluid">
  <div class="row">
    <div class="col-lg-6 m-auto">
      <div class="card">
        <div class="card-header bg-primary text-white">
          Modificar salida
        </div>
        <div class="card-body">
          <form action="" method="post">
            <?php echo isset($alert) ? $alert : ''; ?>
            <div class="form-group">
              <label for="concepto">Concepto</label>
              <input type="text" class="form-control" placeholder="Ingrese el concepto de la salida" name="concepto" id="concepto" value="<?php echo $data_salida['concepto']; ?>">
            </div>
            <div class="form-group">
              <label for="precio">Precio</label>
              <input type="text" placeholder="Ingrese el precio de la salida" class="form-control" name="precio" id="precio" value="<?php echo $data_salida['precio']; ?>">
            </div>
            <input type="submit" value="Actualizar Salida" class="btn btn-primary">
          </form>
        </div>
      </div>
    </div>
  </div>
</div>
<!-- /.container-fluid -->
</div>
<!-- End of Main Content -->
<?php include_once "includes/footer.php"; ?>
