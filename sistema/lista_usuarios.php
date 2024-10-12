<?php include_once "includes/header.php"; ?>
<style>
ol {list-style: decimal;}
ul {list-style: disc;}
li {display: list-item;}
ol, ul {margin-left: 1.7rem;}
ul li {padding-left: .4rem;}
ul ul, ul ol, ol ol, ol ul {margin: .6rem 0 .6rem 1.7rem;}
ul.disc li {
    display: list-item;
    list-style: none;
    padding: 0 0 0 .8rem;
    position: relative;
}
ul.disc li::before {
    content: "";
    display: inline-block;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #39b54a;
    position: absolute;
    left: -17px;
    top: 11px;
    vertical-align: middle;
}
</style>
<!-- Begin Page Content -->
<div class="container-fluid">

	<!-- Page Heading -->
	<div class="d-sm-flex align-items-center justify-content-between mb-4">
		<h1 class="h3 mb-0 text-gray-800">Usuarios</h1>
		<?php if ($_SESSION['rol'] == 1) { ?>
		<a href="registro_usuario.php" class="btn btn-primary">Nuevo Usuario</a>
		<?php } ?>
		<?php if ($_SESSION['rol'] == 2) { ?>
		<a href="registro_usuario.php" class="btn btn-primary">Nuevo Usuario</a>
		<?php } ?>
	</div>
	
	<div class="row">
		<div class="col-lg-12">
	<?php if ($_SESSION['rol'] == 1) { ?>	 
  <ul class="nav nav-tabs">
    <li class="active"><a data-toggle="tab" href="#home">Activos</a></li>
		<li><a data-toggle="tab" href="#menu1">Inactivos</a></li>
	</ul>

  <div class="tab-content">
    <div id="home" class="tab-pane fade in active">
		<div class="table-responsive">
				<table class="table table-striped table-bordered" id="table">
					<thead class="thead-dark">
						<tr>
							<th>ID</th>
							<th>NOMBRE</th>
							<th>CÉDULA</th>
							<th>CORREO</th>
							<th>TELEFONO</th>
							<th>USUARIO</th>
							<th>ROL</th>
							<?php if ($_SESSION['rol'] == 1) { ?>
							<th>ACCIONES</th>
							<?php }?>
						</tr>
					</thead>
					<tbody>
						<?php
						include "../conexion.php";

						$query = mysqli_query($conexion, "SELECT u.idusuario, u.nombre, u.cedula, u.correo, u.usuario, u.telefono, r.rol FROM usuario u INNER JOIN rol r ON u.rol = r.idrol WHERE u.estado=1");
						$result = mysqli_num_rows($query);
						if ($result > 0) {
							while ($data = mysqli_fetch_assoc($query)) { ?>
								<tr>
									<td><?php echo $data['idusuario']; ?></td>
									<td><?php echo $data['nombre']; ?></td>
									<td><?php echo $data['cedula']; ?></td>
									<td><?php echo $data['correo']; ?></td>
									<td><?php echo $data['telefono']; ?></td>
									<td><?php echo $data['usuario']; ?></td>
									<td><?php echo $data['rol']; ?></td>
									<?php if ($_SESSION['rol'] == 1) { ?>
									<td>
										<a href="editar_usuario.php?id=<?php echo $data['idusuario']; ?>" class="btn btn-success"><i class='fas fa-edit'></i></a>
										<form action="eliminar_usuario.php?id=<?php echo $data['idusuario']; ?>" method="post" class="confirmar d-inline">
											<button class="btn btn-danger" type="submit"><i class='fas fa-trash-alt'></i> </button>
										</form>
									</td>
									<?php } ?>
								</tr>
						<?php }
						} ?>
					</tbody>

				</table>
			</div>
    </div>
    <div id="menu1" class="tab-pane fade">
		<div class="table-responsive">
				<table class="table table-striped table-bordered" id="table">
					<thead class="thead-dark">
						<tr>
							<th>ID</th>
							<th>NOMBRE</th>
							<th>CÉDULA</th>
							<th>CORREO</th>
							<th>TELEFONO</th>
							<th>USUARIO</th>
							<th>ROL</th>
							<?php if ($_SESSION['rol'] == 1) { ?>
							<th>ACCIONES</th>
							<?php }?>
						</tr>
					</thead>
					<tbody>
						<?php
						include "../conexion.php";

						$query = mysqli_query($conexion, "SELECT u.idusuario, u.nombre, u.cedula, u.correo, u.usuario, u.telefono, r.rol FROM usuario u INNER JOIN rol r ON u.rol = r.idrol WHERE u.estado=2");
						$result = mysqli_num_rows($query);
						if ($result > 0) {
							while ($data = mysqli_fetch_assoc($query)) { ?>
								<tr>
									<td><?php echo $data['idusuario']; ?></td>
									<td><?php echo $data['nombre']; ?></td>
									<td><?php echo $data['cedula']; ?></td>
									<td><?php echo $data['correo']; ?></td>
									<td><?php echo $data['telefono']; ?></td>
									<td><?php echo $data['usuario']; ?></td>
									<td><?php echo $data['rol']; ?></td>
									<?php if ($_SESSION['rol'] == 1) { ?>
									<td>
										<a href="editar_usuario.php?id=<?php echo $data['idusuario']; ?>" class="btn btn-success"><i class='fas fa-edit'></i></a>
										
											
										</form>
									</td>
									<?php } ?>
								</tr>
						<?php }
						} ?>
					</tbody>

				</table>
			</div>
    </div>
    
  </div>
	<?php } ?>
	<?php if ($_SESSION['rol'] == 2) { ?>	 
  <ul class="nav nav-tabs">
    <li class="active"><a data-toggle="tab" href="#home">Activos</a></li>
		<li><a data-toggle="tab" href="#menu1">Inactivos</a></li>
	</ul>

  <div class="tab-content">
    <div id="home" class="tab-pane fade in active">
		<div class="table-responsive">
				<table class="table table-striped table-bordered" id="table">
					<thead class="thead-dark">
						<tr>
							<th>ID</th>
							<th>NOMBRE</th>
							<th>CÉDULA</th>
							<th>CORREO</th>
							<th>TELEFONO</th>
							<th>USUARIO</th>
							<th>ROL</th>
							<?php if ($_SESSION['rol'] == 2) { ?>
							<th>ACCIONES</th>
							<?php }?>
						</tr>
					</thead>
					<tbody>
						<?php
						include "../conexion.php";

						$query = mysqli_query($conexion, "SELECT u.estado, u.idusuario, u.nombre, u.cedula, u.correo, u.usuario, u.telefono, r.rol FROM usuario u INNER JOIN rol r ON u.rol = r.idrol WHERE r.idrol=3 AND u.estado=1");
						$result = mysqli_num_rows($query);
						if ($result > 0) {
							while ($data = mysqli_fetch_assoc($query)) { ?>
								<tr>
									<td><?php echo $data['idusuario']; ?></td>
									<td><?php echo $data['nombre']; ?></td>
									<td><?php echo $data['cedula']; ?></td>
									<td><?php echo $data['correo']; ?></td>
									<td><?php echo $data['telefono']; ?></td>
									<td><?php echo $data['usuario']; ?></td>
									<td><?php echo $data['rol']; ?></td>
									<?php if ($_SESSION['rol'] == 2) { ?>
									<td>
										<a href="editar_usuario.php?id=<?php echo $data['idusuario']; ?>" class="btn btn-success"><i class='fas fa-edit'></i></a>
										<form action="eliminar_usuario.php?id=<?php echo $data['idusuario']; ?>" method="post" class="confirmar d-inline">
											<button class="btn btn-danger" type="submit"><i class='fas fa-trash-alt'></i> </button>
										</form>
									</td>
									<?php } ?>
								</tr>
						<?php }
						} ?>
					</tbody>

				</table>
			</div>
    </div>
    <div id="menu1" class="tab-pane fade">
		<div class="table-responsive">
				<table class="table table-striped table-bordered" id="table">
					<thead class="thead-dark">
						<tr>
							<th>ID</th>
							<th>NOMBRE</th>
							<th>CÉDULA</th>
							<th>CORREO</th>
							<th>TELEFONO</th>
							<th>USUARIO</th>
							<th>ROL</th>
							<?php if ($_SESSION['rol'] == 2) { ?>
							<th>ACCIONES</th>
							<?php }?>
						</tr>
					</thead>
					<tbody>
						<?php
						include "../conexion.php";

						$query = mysqli_query($conexion, "SELECT u.estado, u.idusuario, u.nombre, u.cedula, u.correo, u.usuario, u.telefono, r.rol FROM usuario u INNER JOIN rol r ON u.rol = r.idrol WHERE r.idrol=3 AND u.estado=2");
						$result = mysqli_num_rows($query);
						if ($result > 0) {
							while ($data = mysqli_fetch_assoc($query)) { ?>
								<tr>
									<td><?php echo $data['idusuario']; ?></td>
									<td><?php echo $data['nombre']; ?></td>
									<td><?php echo $data['cedula']; ?></td>
									<td><?php echo $data['correo']; ?></td>
									<td><?php echo $data['telefono']; ?></td>
									<td><?php echo $data['usuario']; ?></td>
									<td><?php echo $data['rol']; ?></td>
									<?php if ($_SESSION['rol'] == 2) { ?>
									<td>
										<a href="editar_usuario.php?id=<?php echo $data['idusuario']; ?>" class="btn btn-success"><i class='fas fa-edit'></i></a>
										
											
										</form>
									</td>
									<?php } ?>
								</tr>
						<?php }
						} ?>
					</tbody>

				</table>
			</div>
    </div>
    
  </div>
	<?php } ?>
</div>
</div>
			

		</div>
	</div>

 

</div>
<!-- /.container-fluid -->

</div>
<!-- End of Main Content -->


<?php include_once "includes/footer.php"; ?>


