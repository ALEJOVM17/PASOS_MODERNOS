<?php include_once "includes/header.php"; ?>

<!-- Begin Page Content -->
<div class="container-fluid">

    <!-- Page Heading -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">Gastos Caja Menor</h1>
        <a href="registro_salida.php" class="btn btn-primary">Nuevo</a>
    </div>

    <div class="row">
        <div class="col-lg-12">
            <div class="table-responsive">
                <table class="table table-striped table-bordered" id="table">
                    <thead class="thead-dark">
                        <tr>
                            <th>ID</th>
                            <th>FECHA</th>
                            <th>CONCEPTO</th>
                            <th>PRECIO</th>
                            <th>ACCIONES</th> <!-- Nueva columna para botones de acciones -->
                        </tr>
                    </thead>
                    <tbody>
                        <?php
                        include "../conexion.php";

                        $query = mysqli_query($conexion, "SELECT * FROM salidas");
                        $result = mysqli_num_rows($query);
                        if ($result > 0) {
                            while ($data = mysqli_fetch_assoc($query)) { ?>
                                <tr>
                                    <td><?php echo $data['id']; ?></td>
                                    <td><?php echo $data['fecha']; ?></td>
                                    <td><?php echo $data['concepto']; ?></td>
                                    <td><?php echo $data['precio']; ?></td>
                                    <td>
                                        <!-- Botón de editar -->
                                        <a href="editar_salida.php?id=<?php echo $data['id']; ?>" class="btn btn-success"><i class='fas fa-edit'></i></a>
                                        <!-- Botón de eliminar con confirmación -->
                                        <a href="eliminar_salida.php?id=<?php echo $data['id']; ?>" class="btn btn-danger eliminar-salida"><i class='fas fa-trash-alt'></i></a>
                                    </td>
                                </tr>
                        <?php }
                        } ?>
                    </tbody>

                </table>
            </div>

        </div>
    </div>

</div>
<!-- /.container-fluid -->

</div>
<!-- End of Main Content -->

<?php include_once "includes/footer.php"; ?>

<script>
    // Script para mostrar alerta de confirmación antes de eliminar una salida
    $(document).ready(function() {
        $(".eliminar-salida").on("click", function(e) {
            e.preventDefault(); // Prevenir el comportamiento predeterminado del enlace

            var href = $(this).attr("href"); // Obtener la URL de eliminación desde el atributo href

            // Mostrar una ventana emergente de confirmación
            Swal.fire({
                title: '¿Estás seguro?',
                text: 'Esta acción eliminará la salida.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Sí, eliminar',
                cancelButtonText: 'Cancelar'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Si el usuario confirma la eliminación, redireccionar a la URL de eliminación
                    window.location.href = href;
                }
            });
        });
    });
</script>
