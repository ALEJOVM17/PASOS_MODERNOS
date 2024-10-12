<?php include_once "includes/header.php"; ?>


<!-- Begin Page Content -->
<div class="container-fluid">

    <!-- Page Heading -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">Órdenes de trabajo</h1>
        <!--a href="nueva_venta.php" class="btn btn-primary">Nueva Orden</a-->
        <a href="#" class="btn btn-info" data-toggle="modal" data-target="#myModal"><i class="fa fa-university" aria-hidden="true"></i> Nueva Orden</a>
    </div>

    <!-- DESCARGAR -->
    <div class="row">
        <div class="col-lg-6">
            <div class="card">
                <!--h5 class="card-header">Descargar orden</h5-->
                <div class="card-body">
                    <form action="facturar.php" method="post" class="descargar1 d-inline">
                        <label for="metodoabono">Número de orden</label>
                        <input type="text" class="form-control"  name="nofactura" placeholder="Nro. de orden">
                        <label for="mpago">Método de pago</label>
                        <select type="text" placeholder="Ingrese Nombre" name="mpago" class="form-control">
                            <option value="efectivo">Efectivo</option>
                            <option value="daviplata">Daviplata</option>
                            <option value="nequi">Nequi</option>
                            <option value="trasnferencia">Transferencia</option>
                        </select>
                        <label for="referenciapago">Referencia de pago</label>
                        <input type="text" class="form-control"  name="referenciapago" placeholder="Referencia de pago">
                        <p></p>
                        <button class="btn btn-success" type="submit">Finalizar</button>
                    </form>
                </div>
            </div>
        </div>

        <!-- FACTURA ELECTRÓNICA -->
        <?php if ($_SESSION['rol'] == 1) { ?>
        <div class="col-lg-6">
            <div class="card">
                <!--h5 class="card-header">Factura electrónica</h5-->
                <div class="card-body">

                    <form action="anular.php" method="post" class="anular1 d-inline">
                        <label for="metodoabono">Número de orden</label>
                        <input type="text" class="form-control"  name="nofactura" placeholder="Ingrese Nro. de orden">
                        <p></p>
                        <button class="btn btn-danger" type="submit">Anular</button>
                    </form>  
                </div>
            </div>
        </div>
        <?php } ?>

        <?php if ($_SESSION['rol'] == 2) { ?>
        <div class="col-lg-6">
            <div class="card">
                <!--h5 class="card-header">Factura electrónica</h5-->
                <div class="card-body">
                    <form class="form-horizontal" action="facturar_ele.php" role="form" method="POST">
                        <div class="input">
                            <label for="metodoabono">Número de orden</label>
                            <input type="text" class="form-control"  name="nofactura" placeholder="Ingrese Nro. de orden">
                        </div>
                        <p></p><button type="submit" name="submit" class="btn btn-info">Facturar</button> <p></p>
                    </form>
                    <form action="anular.php" method="post" class="anular1 d-inline">
                        <label for="metodoabono">Número de orden</label>
                        <input type="text" class="form-control"  name="nofactura" placeholder="Ingrese Nro. de orden">
                        <p></p>
                        <button class="btn btn-danger" type="submit">Anular</button>
                    </form>  
                </div>
            </div>
        </div>
        <?php } ?>
    </div>

    <style>
        .naranja{color:black; background-color:orange;}
        .verde{color:black;background-color:green;}
        .rojo{color:black;background-color:red;}
    </style>
    <div class="row">
        <div class="col-lg-12">
            <div class="table-responsive">
                <table class="table table-striped table-bordered" id="table">
                    <thead class="thead-dark">
                        <tr>
                            <th>NRO. ORDEN</th>
                            <th>FECHA INICIAL</th>
                            <th>CLIENTE</th>
                            <th>VALOR</th>
                            <th>ABONO</th>
                            <th>SALDO</th>
                            <th>ESTADO</th>
                            <th>FECHA FINAL</th>
                            <th>ACCIONES</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php
                        require "../conexion.php";
                        $query = mysqli_query($conexion, "SELECT f.abono, f.saldo, f.nofactura, f.fecha,f.codcliente, f.totalfactura, f.estado, f.fechafinal, c.dni, es.estado, f.estado as nuevoestado FROM factura f 
                        INNER JOIN cliente c
                        ON f.codcliente = c.idcliente
                        INNER JOIN estado es
                        ON f.estado = es.idestado
                        WHERE f.estado = 1 OR f.estado = 2 OR f.estado = 3
                        ORDER BY nofactura ASC");
                        mysqli_close($conexion);
                        $cli = mysqli_num_rows($query);

                        if ($cli > 0) {
                            while ($dato = mysqli_fetch_array($query)) {
                                $totalfactura = '$' . number_format($dato['totalfactura'], 0, ',', '.');
                                $abono = '$' . number_format($dato['abono'], 0, ',', '.');
                                $saldo = '$' . number_format($dato['saldo'], 0, ',', '.');
                                $estado_color = '';
                                if ($dato['nuevoestado'] == 1) {
                                    $estado_color = 'naranja';
                                } elseif ($dato['nuevoestado'] == 2) {
                                    $estado_color = 'verde';
                                } else {
                                    $estado_color = 'rojo';
                                }
                        ?>
                                <tr>
                                    <td><?php echo $dato['nofactura']; ?></td>
                                    <td><?php echo $dato['fecha']; ?></td>
                                    <td><?php echo $dato['dni']; ?></td>
                                    <td><?php echo $totalfactura; ?></td>
                                    <td><?php echo $abono; ?></td>
                                    <td><?php echo $saldo; ?></td>
                                    <td class="<?php echo $estado_color; ?>"><?php echo $dato['estado']; ?></td>
                                    <td><?php echo $dato['fechafinal']; ?></td>
                                    <td>
                                        <?php 
                                            // Desactivar botón de abonar si el estado es 3 (anulada) o 2 (finalizada)
                                            if($dato['nuevoestado'] != 3 && $dato['nuevoestado'] != 2) {
                                        ?>
                                            <a href="abonar.php?nofactura=<?php echo $dato['nofactura']; ?>" class="btn btn-warning">Abonar</a>
                                        <?php } ?>
                                        <button type="button" class="btn btn-primary view_factura" cl="<?php echo $dato['codcliente'];  ?>" f="<?php echo $dato['nofactura']; ?>">Recibo</button>
                                    </td>
                                </tr>
                        <?php
                            }
                        } ?>
                    </tbody>

                </table>
            </div>
        </div>
    </div>
    <p></p>

    <div class="modal fade" id="myModal" tabindex="-1" role="dialog">

        <!-- Modal content-->
        <div class="modal-content">
            <div class="row">
                <div class="col-lg-12">
                    <div class="form-group">
                        <?php
                        include "../conexion.php";
                        $query = mysqli_query($conexion, "SELECT * FROM cliente");
                        mysqli_close($conexion);
                        $resultado = mysqli_num_rows($query);
                        if ($resultado > 0) {
                            $data = mysqli_fetch_array($query);
                        }
                        ?>
                        <h4 class="text-center">Nueva orden de trabajo</h4>
                        <a class="btn btn-primary" href="ventas.php">cerrar</a>  
                        <a href="#" class="btn btn-primary btn_new_cliente"><i class="fas fa-user-plus"></i> Nuevo Cliente</a>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <form method="post" name="form_new_cliente_venta" id="form_new_cliente_venta">
                                <input type="hidden" name="action" value="addCliente">
                                <input type="hidden" id="idcliente" value="<?php echo $data['idcliente']; ?>" name="idcliente" required>
                                <div class="row">
                                    <div class="col-lg-4">
                                        <div class="form-group">
                                            <label>C.C</label>
                                            <input type="number" name="dni_cliente" id="dni_cliente" class="form-control" >
                                        </div>
                                    </div>
                                    <div class="col-lg-4">
                                        <div class="form-group">
                                            <label>Nombre</label>
                                            <input type="text" name="nom_cliente" id="nom_cliente" class="form-control" disabled required>
                                        </div>
                                    </div>
                                    <div class="col-lg-4">
                                        <div class="form-group">
                                            <label>Teléfono</label>
                                            <input type="number" name="tel_cliente" id="tel_cliente" class="form-control" disabled required>
                                        </div>
                                    </div>
                                    <div class="col-lg-4">
                                        <div class="form-group">
                                            <label>Correo</label>
                                            <input type="text" name="cor_cliente" id="cor_cliente" class="form-control" disabled required>
                                        </div>
                                    </div>
                                    <div class="col-lg-4">
                                        <div class="form-group">
                                            <label>Dirreción</label>
                                            <input type="text" name="dir_cliente" id="dir_cliente" class="form-control" disabled required>
                                        </div>

                                    </div>
                                    <div id="div_registro_cliente" style="display: none;">
                                        <button type="submit" class="btn btn-primary">Guardar</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-6">
                            <div class="form-group">
                                <label><i class="fas fa-user"></i> Vendedor</label>
                                <p style="font-size: 16px; text-transform: uppercase; color: blue;"><?php echo $_SESSION['nombre']; ?></p>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <label>Acciones</label>
                            <div id="acciones_venta" class="form-group">
                                <a href="#" class="btn btn-success" id="btn_facturar_venta"><i class="fas fa-save"></i> Generar Orden</a>
                            </div>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="thead-dark">
                                <tr>
                                    <th width="100px">Código</th>
                                    <th>Producto</th>
                                    <th>Descripción</th>
                                    <th width="100px">Cantidad</th>
                                    <th class="textright">Precio</th>
                                    <th class="textright">+/-Precio</th>
                                    <th class="textright">Precio Total</th>
                                    <th>Acciones</th>
                                </tr>
                                <tr>
                                    <td><input type="number" name="txt_cod_producto" id="txt_cod_producto"></td>
                                    <td id="txt_descripcion">-</td>
                                    <td><input type="text" name="txt_observacion" id="txt_observacion"disabled></td>
                                    <td><input type="text" name="txt_cant_producto" id="txt_cant_producto"value="0" min="1" disabled></td>
                                    <td id="txt_precio" class="textright">0.00</td>
                                    <td><input type="number" name="txt_mprecio" id="txt_mprecio"disabled></td>
                                    <td id="txt_precio_total" class="txtright">0.00</td>
                                    <td><a href="#" id="add_product_venta" class="btn btn-dark" style="display: none;">Agregar</a></td>
                                </tr>
                                <tr>
                                    <th>Código</th>
                                    <th>Producto</th>
                                    <th>Descripción</th>
                                    <th>Cantidad</th>
                                    <th class="textright">Precio</th>
                                    <th class="textright">Nuevo Precio</th>
                                    <th class="textright">Precio Total</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody id="detalle_venta">
                                <!-- Contenido ajax -->

                            </tbody>

                            <tfoot id="detalle_totales">
                                <!-- Contenido ajax -->
                            </tfoot>
                        </table>

                    </div>
                </div>



            </div>
            <!-- //Modal content-->
        </div>
    </div>
    <!-- //Modal1 -->

</div>
<!-- /.container-fluid -->

</div>
<!-- End of Main Content -->


<?php include_once "includes/footer.php"; ?>

<script>
    var listaTD=table.getElementsByClassName("autoColor");
    var valoresTD=[];
    var coloresTD=[];
    var colores=["rgba(0, 128, 0, 0.541)","rgba(197, 197, 4, 0.534)"];
    var colorIndice=0;
    var i;
    for (let td=0; td<listaTD.length; td++) {
        i=valoresTD.findIndex(function(valor){return valor==listaTD[td].innerHTML});
        if (i==-1) {
            valoresTD.push(listaTD[td].innerHTML);
            i=valoresTD.length-1;
            coloresTD.push(colorIndice++);
            if (colorIndice>=colores.length) colorIndice=0;
        }
        listaTD[td].style.backgroundColor=colores[coloresTD[i]];
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
