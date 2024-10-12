<?php include_once "includes/header.php";
include "../conexion.php";
if (!empty($_POST)) {
    $alert = "";
    if (empty($_POST['nombre']) || empty($_POST['correo']) || empty($_POST['telefono'])|| empty($_POST['usuario']) || empty($_POST['clave'])) {
        $alert = '<div class="alert alert-primary" role="alert">
                    Todo los campos son obligatorios
                </div>';
    } else {

        $nombre = $_POST['nombre'];
        $cedula = $_POST['cedula'];
        $email = $_POST['correo'];
        $user = $_POST['usuario'];
        $clave = md5($_POST['clave']);
        $telefono = $_POST['telefono'];

        $query = mysqli_query($conexion, "SELECT * FROM usuario where correo = '$email'");
        $result = mysqli_fetch_array($query);

        if ($result > 0) {
            $alert = '<div class="alert alert-danger" role="alert">
                        El correo ya existe
                    </div>';
        } else {
            $query_insert = mysqli_query($conexion, "INSERT INTO usuario(nombre,cedula,correo,usuario,clave,rol,telefono,estado) values ('$nombre', '$cedula','$email','$user', '$clave', 3, '$telefono',1)");
            if ($query_insert) {
                $alert = '<div class="alert alert-primary" role="alert">
                            Usuario registrado
                        </div>';
            } else {
                $alert = '<div class="alert alert-danger" role="alert">
                        Error al registrar
                    </div>';
            }
        }
    }
}
?>

<!-- Begin Page Content -->
<div class="container-fluid">
    <!-- Page Heading -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">Registrar usuario</h1>
        <a href="lista_usuarios.php" class="btn btn-primary">Regresar</a>
    </div>

    <!-- Content Row -->
    <div class="row">
        <div class="col-lg-6 m-auto">
            <form action="" method="post" autocomplete="off">
                <?php echo isset($alert) ? $alert : ''; ?>
                <div class="form-group">
                    <label for="nombre">Nombre</label>
                    <input type="text" class="form-control" placeholder="Ingrese Nombre" name="nombre" id="nombre">
                </div>
                <div class="form-group">
                    <label for="nombre">Cedula</label>
                    <input type="text" class="form-control" placeholder="Ingrese cédula" name="cedula" id="cedula">
                </div>
                <div class="form-group">
                    <label for="correo">Correo</label>
                    <input type="email" class="form-control" placeholder="Ingrese Correo Electrónico" name="correo" id="correo">
                </div>
                <div class="form-group">
                    <label for="telefono">Teléfono</label>
                    <input type="telefono" class="form-control" placeholder="Ingrese Nro. de telefono" name="telefono" id="telefono">
                </div>
                <div class="form-group">
                    <label for="usuario">Usuario</label>
                    <input type="text" class="form-control" placeholder="Ingrese Usuario" name="usuario" id="usuario">
                </div>
                <div class="form-group">
                    <label for="clave">Contraseña</label>
                    <input type="password" class="form-control" placeholder="Ingrese Contraseña" name="clave" id="clave">
                </div>
                
                <input type="submit" value="Guardar Usuario" class="btn btn-primary">
            </form>
        </div>
    </div>


</div>
<!-- /.container-fluid -->

</div>
<!-- End of Main Content -->
<?php include_once "includes/footer.php"; ?>