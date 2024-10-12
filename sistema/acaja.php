<?php include_once "includes/header.php"; ?>

<!-- Begin Page Content -->
<div class="container-fluid">

    <!-- Page Heading -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">Arqueo de Caja</h1>
        <!-- Agregar formulario para filtrar por mes y botón de sumatoria total -->
        <form method="GET" action="">
            <div class="form-group">
                <label for="mes">Seleccionar Mes:</label>
                <select class="form-control" id="mes" name="mes">
                    <option value="">Todos</option>
                    <option value="01">Enero</option>
                    <option value="02">Febrero</option>
                    <option value="03">Marzo</option>
                    <option value="04">Abril</option>
                    <option value="05">Mayo</option>
                    <option value="06">Junio</option>
                    <option value="07">Julio</option>
                    <option value="08">Agosto</option>
                    <option value="09">Septiembre</option>
                    <option value="10">Octubre</option>
                    <option value="11">Noviembre</option>
                    <option value="12">Diciembre</option>
                    <!-- Agregar opciones para otros meses -->
                </select>
            </div>
            <button type="submit" class="btn btn-primary">Filtrar</button>
        </form>
        <div style="font-size: 20px;color: #af5252;">
            <?php
            include "../conexion.php";
            $filtro_mes_query = isset($_GET['mes']) && $_GET['mes'] != '' ? " WHERE MONTH(dia) = '" . $_GET['mes'] . "'" : "";
            $query = mysqli_query($conexion, "SELECT SUM(neto) AS total_neto FROM estadistica" . $filtro_mes_query);
            $result = mysqli_fetch_assoc($query);
            $valor_neto = $result['total_neto'];
            if (!empty($_GET['mes'])) {
                $mes_seleccionado = date('F', mktime(0, 0, 0, $_GET['mes'], 10));
                echo "El valor neto para el mes de $mes_seleccionado es: $" . number_format($valor_neto, 0, '', '.');
            } else {
                echo "El valor neto es: $" . number_format($valor_neto, 0, '', '.');
            }
            ?>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-12">
            <form class="form-horizontal" action="actualizar.php" role="form">
                <p></p><button type="submit" name="submit" class="btn btn-info">ACTUALIZAR</button>
                <p></p>
            </form>
        </div>
        <div class="table-responsive">
            <table class="table table-striped table-bordered" id="table">
                <thead class="thead-dark">
                    <tr>
                        <th>FECHA</th>
                        <th>V/TR RECIBIDOS</th>
                        <th>TR/ RECIBIDOS</th>
                        <th>V/TR ENTREGADOS</th>
                        <th>TR /ENTREGADOS</th>
                        <th>GASTOS</th>
                        <th>ABONOS</th>
                        <th>NETO</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    include "../conexion.php";
                    $filtro_mes_query = isset($_GET['mes']) && $_GET['mes'] != '' ? " WHERE MONTH(dia) = '" . $_GET['mes'] . "'" : "";
                    $query = mysqli_query($conexion, "SELECT * FROM estadistica" . $filtro_mes_query);
                    $result = mysqli_num_rows($query);
                    if ($result > 0) {
                        while ($data = mysqli_fetch_assoc($query)) { ?>
                            <tr>
                                <td><?php echo $data['dia']; ?></td>
                                <td><?php echo "$" . number_format($data['ventradas'], 0, '', '.'); ?></td>
                                <td><?php echo number_format($data['pentradas'], 0, '', '.'); ?></td>
                                <td><?php echo "$" . number_format($data['vsalidas'], 0, '', '.'); ?></td>
                                <td><?php echo number_format($data['psalidas'], 0, '', '.'); ?></td>
                                <td><?php echo "$" . number_format($data['gastos'], 0, '', '.'); ?></td>
                                <td><?php echo "$" . number_format($data['abono'], 0, '', '.'); ?></td>
                                <td><?php echo "$" . number_format($data['neto'], 0, '', '.'); ?></td>
                            </tr>
                    <?php }
                    } ?>
                </tbody>
            </table>
        </div>
    </div>
    <p></p>

</div>
<!-- /.container-fluid -->

</div>
<!-- End of Main Content -->

<?php include_once "includes/footer.php"; ?>

<script>
    var listaTD = table.getElementsByClassName("autoColor");
    var valoresTD = [];
    var coloresTD = [];
    var colores = ["rgba(0, 128, 0, 0.541)", "rgba(197, 197, 4, 0.534)"];
    var colorIndice = 0;
    var i;
    for (let td = 0; td < listaTD.length; td++) {
        i = valoresTD.findIndex(function(valor) { return valor == listaTD[td].innerHTML });
        if (i == -1) {
            valoresTD.push(listaTD[td].innerHTML);
            i = valoresTD.length - 1;
            coloresTD.push(colorIndice++);
            if (colorIndice >= colores.length) colorIndice = 0;
        }
        listaTD[td].style.backgroundColor = colores[coloresTD[i]];
    }

    $(".descargar1").submit(function(e) {
        e.preventDefault();
        Swal.fire({
            title: '¿Desea descargar la orden?',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'SI'
        }).then((result) => {
            if (result.isConfirmed) {
                this.submit();
            }
        })
    })

    $(".anular1").submit(function(e) {
        e.preventDefault();
        Swal.fire({
            title: '¿Desea anular la orden?',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'SI'
        }).then((result) => {
            if (result.isConfirmed) {
                this.submit();
            }
        })
    })
</script>
