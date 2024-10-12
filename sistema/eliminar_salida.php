<?php
if (!empty($_GET['id'])) {
    require("../conexion.php");
    $id_salida = $_GET['id'];
    $query_delete = mysqli_query($conexion, "DELETE FROM salidas WHERE id = $id_salida");
    mysqli_close($conexion);
    header("location: lista_salidas.php");
}
?>
