<!-- Sidebar -->
<ul class="navbar-nav bg-gradient-primary sidebar sidebar-dark accordion" id="accordionSidebar">

	<!-- Sidebar - Brand -->
	<a class="sidebar-brand d-flex align-items-center justify-content-center" href="index.php">
		<div class="sidebar-brand-icon rotate-n-15">
			
		</div>
		<div class="sidebar-brand-text mx-3"> PASOS MODERNOS</div>
	</a>

	<!-- Divider -->
	<hr class="sidebar-divider my-0">

	<!-- Divider -->
	<hr class="sidebar-divider">

	<!-- Heading -->
	<div class="sidebar-heading">
		OPCIONES
	</div>

	<!-- Nav Item - Pages Collapse Menu -->
	<li class="nav-item">
		<a class="nav-link collapsed" href="ventas.php" >
			<i class="fas fa-clipboard-check"></i>
			<span>Órdenes de trabajo</span>
		</a>
	</li>
	
	<!-- Nav Item - Clientes Collapse Menu -->
	<li class="nav-item">
		<a class="nav-link collapsed" href="lista_cliente.php">
			<i class="fas fa-users"></i>
			<span>Clientes</span>
		</a>
	</li>

		
	<!-- Nav Item - Facturación Collapse Menu>
	<li class="nav-item">
		<a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapseFacturas" aria-expanded="true" aria-controls="collapseUtilities">
			<i class="fas fa-cash-register"></i>
			<span>Facturación</span>
		</a>
		<div id="collapseFacturas" class="collapse" aria-labelledby="headingUtilities" data-parent="#accordionSidebar">
			<div class="bg-white py-2 collapse-inner rounded">
				<a class="collapse-item" href="ventas2.php">Lista de Facturas</a>
			</div>
		</div>
	</li-->

	<!-- Nav Item - inventario Collapse Menu -->
	<!-- <?php if ($_SESSION['rol'] == 1) { ?>
	<li class="nav-item">
		<a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapseInventarios" aria-expanded="true" aria-controls="collapseUtilities">
			<i class="fa fa-archive"></i>
			<span>Inventarios</span>
		</a>
		<div id="collapseInventarios" class="collapse" aria-labelledby="headingUtilities" data-parent="#accordionSidebar">
			<div class="bg-white py-2 collapse-inner rounded">
				<a class="collapse-item" href="inventario_actual2.php">Inventario por órdenes</a>
				<a class="collapse-item" href="inventario_actual.php">Inventario por prendas</a>
			</div>
		</div>
	</li>
	<?php } ?>
	<?php if ($_SESSION['rol'] == 2) { ?>
	<li class="nav-item">
		<a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapseInventarios" aria-expanded="true" aria-controls="collapseUtilities">
			<i class="fa fa-archive"></i>
			<span>Inventarios</span>
		</a>
		<div id="collapseInventarios" class="collapse" aria-labelledby="headingUtilities" data-parent="#accordionSidebar">
			<div class="bg-white py-2 collapse-inner rounded">
				<a class="collapse-item" href="inventario_actual2.php">Inventario por órdenes</a>
				<a class="collapse-item" href="inventario_actual.php">Inventario por prendas</a>
			</div>
		</div>
	</li> -->
	<?php } ?>

	<!-- Nav Item - salidas Collapse Menu -->
	<li class="nav-item">
		<a class="nav-link collapsed" href="lista_salidas.php">
		<i class="fas fa-sign-out-alt"></i>
			<span>Gastos</span>
		</a>
	</li>
	
	<?php if ($_SESSION['rol'] == 1) { ?>
		<!-- Nav Item - Usuarios Collapse Menu -->
		<!--<li class="nav-item">
			<a class="nav-link collapsed" href="lista_costos.php">
				<i class="fas fa-sign-out-alt"></i>
				<span>Costos</span>
			</a>
			<?php } ?>
	<?php if ($_SESSION['rol'] == 2) { ?>
		<!-- Nav Item - Usuarios Collapse Menu -->
		<!--<li class="nav-item">
			<a class="nav-link collapsed" href="lista_costos.php">
				<i class="fas fa-sign-out-alt"></i>
				<span>Costos</span>
			</a>
		</li>
	<?php } ?>

	<?php if ($_SESSION['rol'] == 1) { ?>
		<!-- Nav Item - Usuarios Collapse Menu -->
		<!--<li class="nav-item">
			<a class="nav-link collapsed" href="lista_usuarios.php">
				<i class="fas fa-users"></i>
				<span>Usuarios</span>
			</a>
		</li>
	<?php } ?>
	<?php if ($_SESSION['rol'] == 2) { ?>
		<!-- Nav Item - Usuarios Collapse Menu -->
		<!--<li class="nav-item">
			<a class="nav-link collapsed" href="lista_usuarios.php">
				<i class="fas fa-users"></i>
				<span>Usuarios</span>
			</a>
		</li>
	<?php } ?>
	<!-- Nav Item - Utilities Collapse Menu -->
	<!--li class="nav-item">
		<a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapseProveedor" aria-expanded="true" aria-controls="collapseUtilities">
			<i class="fas fa-hospital"></i>
			<span>Proveedor</span>
		</a>
		<div id="collapseProveedor" class="collapse" aria-labelledby="headingUtilities" data-parent="#accordionSidebar">
			<div class="bg-white py-2 collapse-inner rounded">
				<a class="collapse-item" href="registro_proveedor.php">Nuevo Proveedor</a>
				<a class="collapse-item" href="lista_proveedor.php">Proveedores</a>
			</div>
		</div>
	</li-->
			<!-- Nav Item - Productos Collapse Menu -->
			<?php if ($_SESSION['rol'] == 1) { ?>
	<li class="nav-item">
		<a class="nav-link collapsed" href="acaja.php">
			<i class="fab fa-product-hunt"></i>
			<span>Arqueo de caja</span>
		</a>
	</li>
	<?php } ?>
	<?php if ($_SESSION['rol'] == 2) { ?>
	<li class="nav-item">
		<a class="nav-link collapsed" href="acaja.php">
			<i class="fab fa-product-hunt"></i>
			<span>Arqueo de caja</span>
		</a>
	</li>
	<?php } ?>

	<!-- Nav Item - Productos Collapse Menu -->
	<?php if ($_SESSION['rol'] == 1) { ?>
	<li class="nav-item">
		<a class="nav-link collapsed" href="lista_productos.php">
			<i class="fab fa-product-hunt"></i>
			<span>Productos</span>
		</a>
	</li>
	<?php } ?>
	<?php if ($_SESSION['rol'] == 2) { ?>
	<li class="nav-item">
		<a class="nav-link collapsed" href="lista_productos.php">
			<i class="fab fa-product-hunt"></i>
			<span>Productos</span>
		</a>
	</li>
	<?php } ?>
	<?php if ($_SESSION['rol'] == 3) { ?>
	<li class="nav-item">
		<a class="nav-link collapsed" href="lista_productos.php">
			<i class="fab fa-product-hunt"></i>
			<span>Productos</span>
		</a>
	</li>
	<?php } ?> 

</ul>