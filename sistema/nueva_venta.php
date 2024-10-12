<?php include_once "includes/header.php"; ?>
<link href="css/tabla.css" rel="stylesheet">
                <!-- Begin Page Content -->
        <div class="container-fluid">
        <div class="row">
        <div class="col-lg-12">
                <h4 class="text-center">Lista de productos</h4>
                <div class="table-responsive">
                    <table class="table table-striped table-bordered" id="table">
                        <thead class="thead-dark">
                            <tr>
                                <th>ID</th>
                                <th>PRODUCTO</th>
                                <th>PRECIO</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            include "../conexion.php";

                            $query = mysqli_query($conexion, "SELECT * FROM producto");
                            $result = mysqli_num_rows($query);
                            if ($result > 0) {
                                while ($data = mysqli_fetch_assoc($query)) { ?>
                                    <tr>
                                        <td><?php echo $data['codproducto']; ?></td>
                                        <td><?php echo $data['descripcion']; ?></td>
                                        <td><?php echo $data['precio']; ?></td>
                                    </tr>
                            <?php }
                            } ?>
                        </tbody>

                    </table>
                </div>

		</div>
		</div>


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
                                <h4 class="text-center">Datos del Cliente</h4>
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
                            <h4 class="text-center">Datos Venta</h4>
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
                                        <a href="#" class="btn btn-info" data-toggle="modal" data-target="#myModal"><i class="fa fa-university" aria-hidden="true"></i> Abono</a>
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

                </div>
                <!-- /.container-fluid -->

            </div>
            <!-- End of Main Content -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog">
	<div class="modal-dialog">
		<!-- Modal content-->
		<div class="modal-content">
			<div class="modal-header">
			<div class="card">
                <h5 class="card-header">Abono</h5>
                    <div class="card-body">
	                    <form action="abonar.php" method="post" class="">
                            <label>Monto</label>
	                        <input type="text" class="form-control"  name="abono" id="abono" placeholder="Ingrese monto">
	                        <p></p><label>Forma de pago</label>
                            <select type="text" placeholder="Ingrese metodo de pago" name="mpago" id="mpago" class="form-control">
                                <option value="TarjetaCredito">Tarjeta Crédito</option>
                                <option value="TarjetaDebito">Tarjeta Débito</option>
                                <option value="Nequi">Nequi</option>
                                <option value="Daviplata">Daviplata</option>
                                <option value="Transferencia">Transferencia</option>
                            </select>
                            <label>Referencia de pago</label>
	                        <input type="text" class="form-control"  name="referencia" id="referencia"placeholder="Ingrese referencia de pago">
	                        <p></p>
				            <button class="btn btn-success" type="submit">Agregar</i> </button>
	                    </form>
                    </div>
	            </div>
			</div>
		</div>
		<!-- //Modal content-->
	</div>
</div>
<!-- //Modal1 -->

            <?php include_once "includes/footer.php"; ?>
