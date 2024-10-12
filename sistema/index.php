<?php include_once "includes/header.php"; ?>

<!-- Begin Page Content -->
<div class="container-fluid">

	<!-- Page Heading -->
	<div class="d-sm-flex align-items-center justify-content-between mb-4">
		<h1 class="h3 mb-0 text-gray-800">Estadísticas hoy</h1>
	</div>

	<!-- Content Row -->
	<div class="row">

		<!-- Earnings (Monthly) Card Example -->
		<a class="col-xl-4 col-md-6 mb-4" href="lista_usuarios.php">
			<div class="card border-left-success shadow h-100 py-2">
				<div class="card-body">
					<div class="row no-gutters align-items-center">
						<div class="col mr-2">
							<div class="text-xs font-weight-bold text-success text-uppercase mb-1">VALOR TOTAL TRABAJO RECIBIDOS</div>
							<div class="h5 mb-0 font-weight-bold text-gray-800">$<?php
								include "../conexion.php";
								$query = mysqli_query($conexion, "SELECT FORMAT(SUM(totalfactura), 0) as total FROM factura WHERE fecha > CURDATE()");
								$result = mysqli_num_rows($query);
									if ($result > 0) {
										while ($data = mysqli_fetch_assoc($query)) { 
												echo $data['total'];}
									} ?>
							</div>
						</div>
						<div class="col-auto">
							
						</div>
					</div>
				</div>
			</div>
		</a>

		<!-- Earnings (Monthly) Card Example -->
		<a class="col-xl-2 col-md-6 mb-4" href="lista_cliente.php">
			<div class="card border-left-success shadow h-100 py-2">
				<div class="card-body">
					<div class="row no-gutters align-items-center">
						<div class="col mr-2">
							<div class="text-xs font-weight-bold text-success text-uppercase mb-1">Trabajos recibidos</div>
							<div class="h5 mb-0 font-weight-bold text-gray-800"><?php
								include "../conexion.php";
								$query = mysqli_query($conexion, "SELECT SUM(df.cantidad) as total FROM detallefactura df 
								INNER JOIN factura f
								ON df.nofactura = f.nofactura
								WHERE f.fecha > CURDATE()");
								$result = mysqli_num_rows($query);
									if ($result > 0) {
										while ($data = mysqli_fetch_assoc($query)) { 
												echo $data['total'];}
									} ?>
							</div>
						</div>
						<div class="col-auto">
							
						</div>
					</div>
				</div>
			</div>
		</a> 

		<!-- Earnings (Monthly) Card Example -->
		<a class="col-xl-4 col-md-6 mb-4" href="lista_productos.php">
			<div class="card border-left-info shadow h-100 py-2">
				<div class="card-body">
					<div class="row no-gutters align-items-center">
						<div class="col mr-2">
							<div class="text-xs font-weight-bold text-info text-uppercase mb-1">SALDOS PAGADOS POR TRABAJO FINALIZADO</div>
							<div class="row no-gutters align-items-center">
								<div class="col-auto">
								<div class="h5 mb-0 font-weight-bold text-gray-800">$<?php
								include "../conexion.php";
								$query = mysqli_query($conexion, "SELECT FORMAT(SUM(saldo), 0) as total FROM factura2 WHERE fechafinal > CURDATE()");
								$result = mysqli_num_rows($query);
									if ($result > 0) {
										while ($data = mysqli_fetch_assoc($query)) { 
												echo $data['total'];}
									} ?>
							</div>
								</div>
								<div class="col-auto">
									<div class="progress progress-sm mr-2">
										<div class="progress-bar bg-info" role="progressbar" style="width: 50%" aria-valuenow="50" aria-valuemin="0" aria-valuemax="100"></div>
									</div>
								</div>
							</div>
						</div>
						<div class="col-auto">
							
						</div>
					</div>
				</div>
			</div>
		</a>

		<!-- Pending Requests Card Example -->
		<a class="col-xl-2 col-md-6 mb-4" href="ventas.php">
			<div class="card border-left-info shadow h-100 py-2">
				<div class="card-body">
					<div class="row no-gutters align-items-center">
						<div class="col mr-2">
							<div class="text-xs font-weight-bold text-info text-uppercase mb-1">TRABAJOS ENTREGADOS</div>
							<div class="h5 mb-0 font-weight-bold text-gray-800"><?php
								include "../conexion.php";
								$query = mysqli_query($conexion, "SELECT SUM(df.cantidad) as total FROM detallefactura2 df 
								INNER JOIN factura2 f
								ON df.nofactura = f.nofactura
								WHERE f.fechafinal > CURDATE()");
								$result = mysqli_num_rows($query);
									if ($result > 0) {
										while ($data = mysqli_fetch_assoc($query)) { 
												echo $data['total'];}
									} ?>
							</div>
						</div>
						<div class="col-auto">
							
						</div>
					</div>
				</div>
			</div>
		</a>
		<a class="col-xl-3 col-md-6 mb-4" href="ventas.php">
  <div class="card border-left-warning shadow h-100 py-2">
    <div class="card-body">
      <div class="row no-gutters align-items-center">
        <div class="col mr-2">
          <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">GASTOS</div>
          <div class="h5 mb-0 font-weight-bold text-gray-800">$<?php
            include "../conexion.php";
            $query = mysqli_query($conexion, "SELECT FORMAT(SUM(precio), 0) as gastos FROM salidas 
            WHERE fecha > CURDATE()");
            $result = mysqli_num_rows($query);
              if ($result > 0) {
                while ($data = mysqli_fetch_assoc($query)) { 
                    echo $data['gastos'];}
              } ?>
          </div>
        </div>
        <div class="col-auto">
          
        </div>
      </div>
    </div>
  </div>
</a>
<a class="col-xl-3 col-md-6 mb-4" href="#">
  <div class="card border-left-warning shadow h-100 py-2">
    <div class="card-body">
      <div class="row no-gutters align-items-center">
        <div class="col mr-2">
          <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">ABONOS RECIBIDOS</div>
          <div class="h5 mb-0 font-weight-bold text-gray-800">$<?php
            include "../conexion.php";
            $query = mysqli_query($conexion, "SELECT FORMAT(SUM(abono), 0) as abono FROM factura  WHERE fecha > CURDATE()");
            $result = mysqli_num_rows($query);
              if ($result > 0) {
                while ($data = mysqli_fetch_assoc($query)) { 
                    echo $data['abono'];}
              } ?>
          </div>
        </div>
        <div class="col-auto">
          
        </div>
      </div>
    </div>
  </div>
</a>
<a class="col-xl-6 col-md-6 mb-4" href="#">
  <div class="card border-left-danger shadow h-100 py-2">
    <div class="card-body">
      <div class="row no-gutters align-items-center">
        <div class="col mr-2">
          <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">NETO</div>
          <div class="h5 mb-0 font-weight-bold text-gray-800">$<?php
            include "../conexion.php";
            $query = mysqli_query($conexion, "SELECT FORMAT(neto, 0) as neto FROM estadistica
						WHERE dia = CURDATE()");
            $result = mysqli_num_rows($query);
              if ($result > 0) {
                while ($data = mysqli_fetch_assoc($query)) { 
                    echo $data['neto'];}
              } ?>
          </div>
        </div>
        <div class="col-auto">
          
        </div>
      </div>
    </div>
  </div>
</a>
<form class="form-horizontal" action="actualizar.php" role="form">
     <p></p><button type="submit" name="submit" class="btn btn-info">ACTUALIZAR</button> <p></p>
		 </form> 
	</div>
	
	

</div>
<!-- End of Main Content -->


<?php include_once "includes/footer.php"; ?>
