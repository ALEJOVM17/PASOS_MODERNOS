<?php
include "../../conexion.php";
require_once '../pdf/vendor/autoload.php';
use Dompdf\Dompdf;

if(empty($_REQUEST['cl']) || empty($_REQUEST['f']))
{
    echo "No es posible generar la factura.";
}
else
{
    $codCliente = $_REQUEST['cl'];
    $noFactura = $_REQUEST['f'];
    $anulada = '';

    $query_config = mysqli_query($conexion,"SELECT * FROM configuracion");
    $result_config = mysqli_num_rows($query_config);
    if($result_config > 0){
        $configuracion = mysqli_fetch_assoc($query_config);
    }

    $query = mysqli_query($conexion,"SELECT f.nofactura, f.totalfactura, DATE_FORMAT(f.fecha, '%d/%m/%Y') as fecha, DATE_FORMAT(f.fecha,'%H:%i:%s') as  hora, f.codcliente, f.estado,
                                             v.nombre as vendedor,
                                             cl.dni, cl.nombre, cl.correo, cl.telefono,cl.direccion, f.abono, f.saldo
                                        FROM factura f
                                        INNER JOIN usuario v
                                        ON f.usuario = v.idusuario
                                        INNER JOIN cliente cl
                                        ON f.codcliente = cl.idcliente
                                        WHERE f.nofactura = $noFactura AND f.codcliente = $codCliente  AND f.estado != 10 ");

    $result = mysqli_num_rows($query);
    if($result > 0){

        $factura = mysqli_fetch_assoc($query);
        $no_factura = $factura['nofactura'];

        if($factura['estado'] == 2){
            $anulada = '<img class="anulada" src="img/descargado.png" alt="Anulada">';
        }
        if($factura['estado'] == 3){
            $anulada = '<img class="anulada" src="img/anulado.png" alt="Anulada">';
        }
        if($factura['estado'] == 5){
            $anulada = '<img class="anulada" src="img/debaja.png" alt="Anulada">';
        }
        $query_productos = mysqli_query($conexion,"SELECT p.descripcion,dt.cantidad,dt.observacion, dt.mprecio, dt.precio_venta,(dt.cantidad * dt.precio_venta) as precio_total
                                                    FROM factura f
                                                    INNER JOIN detallefactura dt
                                                    ON f.nofactura = dt.nofactura
                                                    INNER JOIN producto p
                                                    ON dt.codproducto = p.codproducto
                                                    WHERE f.nofactura = $no_factura ");
        $result_detalle = mysqli_num_rows($query_productos);

        ob_start();
        include(dirname('__FILE__').'/factura_ele2.php');
        $html = ob_get_clean();

        // Modificar el HTML para que los valores estén en pesos colombianos y sin decimales con el símbolo "$" al inicio
        $html = str_replace('.00', '', $html);
        $html = str_replace('$', '$ ', $html);

        // instantiate and use the dompdf class
        $dompdf = new Dompdf();

        $dompdf->loadHtml($html);
        // (Optional) Setup the paper size and orientation
        $dompdf->setPaper('letter', 'portrait');
        // Render the HTML as PDF
        $dompdf->render();
        // Output the generated PDF to Browser
        $dompdf->stream('factura_'.$noFactura.'.pdf',array('Attachment'=>0));
        exit;
    }
}
?>
