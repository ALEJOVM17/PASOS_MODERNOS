<?php
$subtotal   = 0;
$iva        = 0;
$impuesto   = 0;
$tl_sniva   = 0;
$total      = 0;
$abono      = 0;
$estado     = $factura['estado']; // Estado de la factura
date_default_timezone_set('America/Toronto');
$date = date('Y-m-d H:i:s');
//print_r($configuracion); 
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Recibo</title>
    <link rel="stylesheet" href="style2.css">
    <style>
        .anulada {
            color: red;
        }
    </style>
</head>

<body>
    <div style="width: 250px;">
        <div id="page_pdf">
            <table id="factura_head">
                <tr>
                    <td class="logo_factura">
                        <div>
                            <img src="img/logo.jpg" style="width: 200px;">
                        </div>
                    </td>
                    <td class="info_empresa">
                        <?php
                        if ($result_config > 0) {
                            $iva = $configuracion['igv'];
                        ?>
                            <div>
                                <span class="h2"><?php echo strtoupper($configuracion['nombre']); ?></span>

                                <p>Teléfono: <?php echo $configuracion['telefono']; ?></p>
                                <p>Email: <?php echo $configuracion['email']; ?></p>
                            </div>
                        <?php
                        }
                        ?>
                    </td>
                    <td class="info_factura">
                        <div class="round">
                            <span class="h3">RECIBO</span>
                            <p>N°. Orden: <strong><?php echo $factura['nofactura']; ?></strong></p><br>
                            <p>Fecha: <?php echo $factura['fecha']; ?></p><br>
                            <p>Hora: <?php echo $factura['hora']; ?></p><br>

                        </div>
                    </td>
                </tr>
            </table>
            <table id="factura_cliente">
                <tr>
                    <td class="info_cliente">
                        <div class="round">
                            <span class="h3">Cliente</span>
                            <table class="datos_cliente">
                                <tr>
                                    <td><label>Cédula:</label>
                                        <p><?php echo $factura['dni']; ?></p>
                                    </td>
                                    <td><label>Teléfono:</label>
                                        <p><?php echo $factura['telefono']; ?></p>
                                    </td>
                                </tr>
                                <tr>
                                    <td><label>Nombre:</label>
                                        <p><?php echo $factura['nombre']; ?></p>
                                    </td>
                                    <td><label>Dirección:</label>
                                        <p><?php echo $factura['direccion']; ?></p>
                                    </td>
                                <tr>
                                    <td>
                                    </td>
                                    <td><label>Correo:</label>
                                        <p><?php echo $factura['correo']; ?></p>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>

                </tr>
            </table>

            <table id="factura_detalle">
                <thead>
                    <tr>
                        <th width="10px">Cant.</th>
                        <th class="textleft">Servicio</th>
                        <th class="textleft">Descrip.</th>
                        <th class="textright">V/Unitario.</th>
                        <th class="textright">V/Total</th>
                    </tr>
                </thead>
                <tbody id="detalle_productos">

                    <?php

                    if ($result_detalle > 0) {

                        while ($row = mysqli_fetch_assoc($query_productos)) {
                            $precionuevo = $row['precio_venta'] + $row['mprecio'];
                            $precio_total = $row['cantidad'] * $precionuevo;
                    ?>
                            <tr>
                                <td class="textcenter"><?php echo $row['cantidad']; ?></td>
                                <td><?php echo $row['descripcion']; ?></td>
                                <td><?php echo $row['observacion']; ?></td>
                                <td class="textright"><?php echo $row['precio_venta'] + $row['mprecio']; ?>.00</td>
                                <td class="textright"><?php echo $row['cantidad'] * $precionuevo; ?>.00</td>
                            </tr>
                    <?php
                            $precionuevo = $row['precio_venta'] + $row['mprecio'];
                            $precio_total = $row['cantidad'] * $precionuevo;

                            $subtotal = round($subtotal + $precio_total, 2);
                        }
                    }

                    $impuesto   = round($subtotal / $iva, 2);
                    $tl_sniva   = round($subtotal - $impuesto, 2);
                    $total      = round($tl_sniva + $impuesto, 2);
                    $abono      = $factura['abono']; // Abono de la factura
                    ?>

                </tbody>
                <tfoot id="detalle_totales">

                    <tr>
                        <td colspan="4" class="textright"><span>TOTAL</span></td>
                        <td class="textright"><span><?php echo $total; ?>.00</span></td>
                    </tr>
                    <?php if ($estado == 1) { ?>
                        <tr>
                            <td colspan="4" class="textright"><span>ABONO</span></td>
                            <td class="textright"><span><?php echo $abono; ?>.00</span></td>
                        </tr>
                        <tr>
                            <td colspan="4" class="textright"><span>SALDO A PAGAR</span></td>
                            <td class="textright"><span><?php echo $total - $abono; ?>.00</span></td>
                        </tr>
                    <?php } elseif ($estado == 3) { ?>
                        <tr>
                            <td colspan="5" class="textright anulada"><span>FACTURA ANULADA</span></td>
                        </tr>
                    <?php } ?>
                </tfoot>
            </table>
            <div class="condiciones">

                <h4 class="label_gracias">GRACIAS POR APOYAR EL TRABAJO COLOMBIANO</h4>
                <p class="nota">fecha de impresión <?php echo $date; ?></p>
            </div>
        </div>
    </div>
</body>

</html>
