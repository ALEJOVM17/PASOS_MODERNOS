<?php
include "../conexion.php";

// Inicializar variables
$nofactura = $abono = $metodoabono = $referenciaabono = "";

if (!empty($_POST)) {
    $alert = "";
    if (empty($_POST['abono'])) {
        $alert = '<p class="error">Todos los campos son requeridos</p>';
    } else {
        $nofactura = $_POST['nofactura'];
        $abono = $_POST['abono'];
        $metodoabono = $_POST['metodoabono'];
        $referenciaabono = $_POST['referenciaabono'];
        
        // Obtener el saldo actual
        $query_saldo = mysqli_query($conexion, "SELECT saldo FROM factura WHERE nofactura = $nofactura");
        $saldo_actual = mysqli_fetch_assoc($query_saldo)['saldo'];

        // Verificar si el abono es mayor que el saldo actual
        if ($abono <= $saldo_actual) {
            $nuevo_saldo = $saldo_actual - $abono;

            // Actualizar la factura con el nuevo abono y saldo
            $sql_update = mysqli_query($conexion, "UPDATE factura SET abono = abono + $abono, metodoabono = '$metodoabono', referenciaabono = '$referenciaabono', saldo = $nuevo_saldo WHERE nofactura = $nofactura");

            if ($sql_update) {
                $alert = '<p class="exito">Abono realizado correctamente</p>';
            } else {
                $alert = '<p class="error">Error al realizar abono</p>';
            }
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
        $abono = $data['abono'];
        $metodoabono = $data['metodoabono'];
        $referenciaabono = $data['referenciaabono'];
    }
}
?>
<?php include_once "includes/header.php"; ?>

<!-- Include SweetAlert -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@10"></script>

<!-- Begin Page Content -->
<div class="container-fluid">

    <div class="row">
        <div class="col-lg-6 m-auto">

            <form id="myForm" class="" action="" method="post">
                <?php echo isset($alert) ? $alert : ''; ?>
                <input type="hidden" name="nofactura" value="<?php echo $nofactura; ?>">
                <div class="form-group">
                    <label for="abono">Monto</label>
                    <input type="number" placeholder="Ingrese monto" name="abono" id="abono" class="form-control" value="<?php echo $abono; ?>">
                </div>
                <div class="form-group">
                    <label for="metodoabono">Metodo de pago</label>
                    <select type="text" placeholder="Ingrese Nombre" name="metodoabono" class="form-control" id="metodoabono" value="<?php echo $metodoabono; ?>">
                        <option value="efectivo">Efectivo</option>
                        <option value="daviplata">Daviplata</option>
                        <option value="nequi">Nequi</option>
                        <option value="trasnferencia">Transferencia</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="referenciaabono">Referencia de pago</label>
                    <input type="text" placeholder="Ingrese referencia de pago" name="referenciaabono" class="form-control" id="referenciaabono" value="<?php echo $referenciaabono; ?>">
                </div>
                
                <button type="submit" class="btn btn-warning"><i class="fas fa-user-edit"></i>Realizar Abono</button>
            </form>
        </div>
    </div>

</div>
<!-- /.container-fluid -->

<!-- End of Main Content -->
<?php include_once "includes/footer.php"; ?>

<!-- Script para mostrar alerta si el abono es mayor que el saldo -->
<script>
document.getElementById('myForm').addEventListener('submit', function(e) {
    e.preventDefault();

    var abono = parseFloat(document.getElementById('abono').value);
    var saldo = parseFloat('<?php echo $saldo_actual; ?>');

    if (abono > saldo) {
        Swal.fire({
            title: 'El abono es mayor al saldo',
            text: 'Verifica nuevamente',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            
            
        }).then((result) => {
            if (result.isConfirmed) {
                // Si el usuario confirma, enviar el formulario
                document.getElementById('myForm').submit();
            }
        });
    } else {
        // Si el abono es menor o igual al saldo, envía el formulario
        document.getElementById('myForm').submit();
    }
});
</script>
