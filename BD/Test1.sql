-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 11-07-2024 a las 15:46:30
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `Test1`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_precio_producto` (IN `n_cantidad` INT, IN `n_precio` DECIMAL(10,2), IN `codigo` INT)   BEGIN
DECLARE nueva_existencia int;
DECLARE nuevo_total decimal(10,2);
DECLARE nuevo_precio decimal(10,2);
DECLARE cant_actual int;
DECLARE pre_actual decimal(10,2);
DECLARE actual_existencia int;
DECLARE actual_precio decimal(10,2);
SELECT precio, existencia INTO actual_precio, actual_existencia FROM producto WHERE codproducto = codigo;
SET nueva_existencia = actual_existencia + n_cantidad;
SET nuevo_total = n_precio;
SET nuevo_precio = nuevo_total;
UPDATE producto SET existencia = nueva_existencia, precio = nuevo_precio WHERE codproducto = codigo;
SELECT nueva_existencia, nuevo_precio;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_detalle_temp` (`codigo` INT, `cantidad` INT, `observacion` VARCHAR(50), `mprecio` DECIMAL(10,2), `token_user` VARCHAR(50))   BEGIN
DECLARE precio_actual decimal(10,2);
SELECT precio INTO precio_actual FROM producto WHERE codproducto = codigo;
INSERT INTO detalle_temp(token_user, codproducto, cantidad, observacion, precio_venta, mprecio) VALUES (token_user, codigo, cantidad, observacion, precio_actual, mprecio);
SELECT tmp.correlativo, tmp.codproducto, p.descripcion, tmp.cantidad, tmp.observacion, tmp.precio_venta, tmp.mprecio FROM detalle_temp tmp INNER JOIN producto p ON tmp.codproducto = p.codproducto WHERE tmp.token_user = token_user;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `data` ()   BEGIN
DECLARE usuarios int;
DECLARE clientes int;
DECLARE proveedores int;
DECLARE productos int;
DECLARE ventas int;
SELECT COUNT(*) INTO usuarios FROM usuario;
SELECT COUNT(*) INTO clientes FROM cliente;
SELECT COUNT(*) INTO proveedores FROM proveedor;
SELECT COUNT(*) INTO productos FROM producto;
SELECT COUNT(*) INTO ventas FROM factura WHERE fecha > CURDATE();
SELECT usuarios, clientes, proveedores, productos, ventas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `data2` ()   BEGIN
DECLARE egresos INT;
SELECT SUM(precio) INTO egresos FROM salidas;
SELECT egresos;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `del_detalle_temp` (`id_detalle` INT, `token` VARCHAR(50))   BEGIN
DELETE FROM detalle_temp WHERE correlativo = id_detalle;
SELECT tmp.correlativo, tmp.codproducto, p.descripcion, tmp.cantidad, tmp.observacion,tmp.precio_venta FROM detalle_temp tmp INNER JOIN producto p ON tmp.codproducto = p.codproducto WHERE tmp.token_user = token;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `filldates` (`dateStart` DATE, `dateEnd` DATE)   BEGIN
  WHILE dateStart <= dateEnd DO
    INSERT INTO estadistica (dia) VALUES (dateStart);
    SET dateStart = DATE_ADD(dateStart, INTERVAL 1 DAY);
  END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `procesar_venta` (IN `cod_usuario` INT, IN `cod_cliente` INT, IN `token` VARCHAR(50))   BEGIN
DECLARE factura INT;
DECLARE registros INT;
DECLARE subtotal DECIMAL(10,2);
DECLARE subtotal2 DECIMAL(10,2);
DECLARE total DECIMAL(10,2);
DECLARE nueva_existencia int;
DECLARE existencia_actual int;
DECLARE tmp_cod_producto int;
DECLARE tmp_cant_producto int;
DECLARE a int;
SET a = 1;
CREATE TEMPORARY TABLE tbl_tmp_tokenuser(
	id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    cod_prod BIGINT,
    cant_prod int);
SET registros = (SELECT COUNT(*) FROM detalle_temp WHERE token_user = token);
IF registros > 0 THEN
INSERT INTO tbl_tmp_tokenuser(cod_prod, cant_prod) SELECT codproducto, cantidad FROM detalle_temp WHERE token_user = token;
INSERT INTO factura (usuario,codcliente) VALUES (cod_usuario, cod_cliente);
SET factura = LAST_INSERT_ID();
INSERT INTO detallefactura(nofactura,codproducto,cantidad,observacion,precio_venta,mprecio) SELECT (factura) AS nofactura, codproducto, cantidad, observacion, precio_venta, mprecio FROM detalle_temp WHERE token_user = token;
WHILE a <= registros DO
	SELECT cod_prod, cant_prod INTO tmp_cod_producto,tmp_cant_producto FROM tbl_tmp_tokenuser WHERE id = a;
    SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = tmp_cod_producto;
    SET nueva_existencia = existencia_actual - tmp_cant_producto;
    UPDATE producto SET existencia = nueva_existencia WHERE codproducto = tmp_cod_producto;
    SET a=a+1;
END WHILE;
SET subtotal = (SELECT SUM(cantidad * precio_venta) FROM detalle_temp WHERE token_user = token);
SET subtotal2 = (SELECT SUM(cantidad * mprecio) FROM detalle_temp WHERE token_user = token);
SET total = subtotal + subtotal2;
UPDATE factura SET totalfactura = total, saldo = total WHERE nofactura = factura;
DELETE FROM detalle_temp WHERE token_user = token;
TRUNCATE TABLE tbl_tmp_tokenuser;
SELECT * FROM factura WHERE nofactura = factura;
ELSE
SELECT 0;
END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `idcliente` int(11) NOT NULL,
  `dni` int(8) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `telefono` varchar(30) NOT NULL,
  `direccion` varchar(200) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `correo` varchar(20) NOT NULL,
  `fecha` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`idcliente`, `dni`, `nombre`, `telefono`, `direccion`, `usuario_id`, `correo`, `fecha`) VALUES
(1, 1098765432, 'Carlos Sanchez', '3123456789', 'Carrera 15 #134-45', 1, 'carloschez@gmail.com', '2024-08-15'),
(2, 1098765433, 'Ana María López', '3159876543', 'Calle 140 #7-12', 1, 'analopez56465416@gmail.com', '2024-08-15'),
(3, 1098765447, 'Camila Ramírez', '3127654321', 'Calle 124 #11-45', 1, 'camiramirez21685@gmail.com', '2024-08-15'),
(4, 1098765448, 'Miguel Ángel Díaz', '3207654321', 'Carrera 13 #128-34', 1, 'miguel.diaz@gmail.com', '2024-08-15'),
(5, 1098765462, 'Esteban Castro', '3159876543', 'Carrera 12 #132-45', 1, 'esteban.castro@gmail.com', '2024-08-15'),
(6, 1098765434, 'Julio Martínez', '3201234567', 'Avenida 19 #120-90', 1, 'julio.martinez@gmail.com', '2024-08-16'),
(7, 1098765435, 'Lucía Ramírez', '3119876543', 'Calle 127 #11A-34', 1, 'lucia.ramirez@gmail.com', '2024-08-16'),
(8, 1098765449, 'Natalia Romero', '3119876543', 'Calle 135 #10-56', 1, 'natalia.romero@gmail.com', '2024-08-16'),
(9, 1098765450, 'Daniela Mejía', '3137654321', 'Carrera 14 #125-67', 1, 'daniela.mejia@gmail.com', '2024-08-16'),
(10, 1098765463, 'Patricia Peña', '3107654321', 'Calle 124 #16-78', 1, 'patricia.pena@mail.com', '2024-08-16'),
(11, 1098765436, 'Pedro Gómez', '3187654321', 'Carrera 7 #150-32', 1, 'pedro.gomez@mail.com', '2024-08-17'),
(12, 1098765437, 'Mariana Torres', '3212345678', 'Calle 134 #9A-56', 1, 'mariana.torres@mail.com', '2024-08-17'),
(13, 1098765451, 'Luis Fernando Acosta', '3107654321', 'Avenida 7 #140-23', 1, 'luis.acosta@mail.com', '2024-08-17'),
(14, 1098765464, 'Ricardo Luna', '3129876543', 'Carrera 7 #150-30', 1, 'ricardo.luna@mail.com', '2024-08-17'),
(15, 1098765438, 'Juan Carlos Rojas', '3223456789', 'Carrera 13 #120-45', 1, 'juan.rojas@mail.com', '2024-08-18'),
(16, 1098765439, 'Paula Fernández', '3131234567', 'Calle 116 #16-89', 1, 'paula.fernandez@mail.com', '2024-08-18'),
(17, 1098765452, 'Sebastián Rivera', '3123456789', 'Carrera 15 #137-12', 1, 'sebastian.rivera@mail.com', '2024-08-18'),
(18, 1098765453, 'Mónica Rodríguez', '3209876543', 'Calle 134 #8A-45', 1, 'monica.rodriguez@mail.com', '2024-08-18'),
(19, 1098765440, 'Fernando Quintero', '3129876543', 'Avenida 9 #140-78', 1, 'fernando.quintero@mail.com', '2024-08-19'),
(20, 1098765441, 'Sofía Vargas', '3157654321', 'Carrera 11 #145-23', 1, 'sofia.vargas@mail.com', '2024-08-19'),
(21, 1098765455, 'Jorge Castillo', '3139876543', 'Avenida 9 #124-56', 1, 'jorge.castillo@mail.com', '2024-08-19'),
(22, 1098765456, 'Lorena Suárez', '3113456789', 'Calle 140 #9-23', 1, 'lorena.suarez@mail.com', '2024-08-19'),
(23, 1098765442, 'Raúl Moreno', '3101234567', 'Calle 122 #14-67', 1, 'raul.moreno@mail.com', '2024-08-20'),
(24, 1098765457, 'David Reyes', '3187654321', 'Carrera 11 #136-45', 1, 'david.reyes@mail.com', '2024-08-20'),
(25, 1098765458, 'Angela Gómez', '3123456789', 'Calle 120 #13-67', 1, 'angela.gomez@mail.com', '2024-08-20'),
(26, 1098765443, 'Laura Pérez', '3209876543', 'Carrera 15 #130-89', 1, 'laura.perez@mail.com', '2024-08-20'),
(27, 1098765444, 'Alejandro Ruiz', '3112345678', 'Calle 127 #9-54', 1, 'alejandro.ruiz@mail.com', '2024-08-21'),
(28, 1098765445, 'Valentina García', '3187654321', 'Carrera 7 #140-19', 1, 'valentina.garcia@mail.com', '2024-08-21'),
(29, 1098765459, 'Mauricio Romero', '3212345678', 'Carrera 16 #127-89', 1, 'mauricio.romero@mail.com', '2024-08-21'),
(30, 1098765460, 'Gloria Paredes', '3137654321', 'Calle 115 #14-23', 1, 'gloria.paredes@mail.com', '2024-08-21'),
(31, 1098765446, 'Andrés Torres', '3213456789', 'Avenida 19 #134-12', 1, 'andres.torres@mail.com', '2024-08-22'),
(32, 1098765461, 'Carlos Mendez', '3221234567', 'Avenida 19 #122-56', 1, 'carlos.mendez@mail.com', '2024-08-22'),
(33, 1098765463, 'Adriana Herrera', '3227654321', 'Calle 119 #12-78', 1, 'adriana.herrera@mail.com', '2024-08-22');


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion`
--

CREATE TABLE `configuracion` (
  `id` int(11) NOT NULL,
  `nit` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `razon_social` varchar(100) NOT NULL,
  `telefono` varchar(30) NOT NULL,
  `email` varchar(100) NOT NULL,
  `direccion` text NOT NULL,
  `igv` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `configuracion`
--

INSERT INTO `configuracion` (`id`, `nit`, `nombre`, `razon_social`, `telefono`, `email`, `direccion`, `igv`) VALUES
(1, 1013621668, 'PROYECTO UNAD', 'Solución de software para costureras y zapateros', '3158632523', 'mavasquezmo@unadvirtual.edu.co', 'Bogotá D.C.', 1.19);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `costos`
--

CREATE TABLE `costos` (
  `id` int(10) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `concepto` varchar(30) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefactura`
--

CREATE TABLE `detallefactura` (
  `correlativo` bigint(20) NOT NULL,
  `nofactura` bigint(20) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `observacion` varchar(50) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  `mprecio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `detallefactura`
--

INSERT INTO `detallefactura` (`correlativo`, `nofactura`, `codproducto`, `observacion`, `cantidad`, `precio_venta`, `mprecio`) VALUES
(0, 0, 2, '-', 1, 00.00, 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefactura2`
--

CREATE TABLE `detallefactura2` (
  `correlativo` bigint(20) NOT NULL,
  `nofactura` bigint(20) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `observacion` varchar(50) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  `mprecio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `detallefactura2`
--

INSERT INTO `detallefactura2` (`correlativo`, `nofactura`, `codproducto`, `observacion`, `cantidad`, `precio_venta`, `mprecio`) VALUES
(0, 0, 2, '-', 1, 00.00, 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefacturabaja`
--

CREATE TABLE `detallefacturabaja` (
  `correlativo` bigint(20) NOT NULL,
  `nofactura` bigint(20) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `observacion` varchar(50) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  `mprecio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefacturanula`
--

CREATE TABLE `detallefacturanula` (
  `correlativo` bigint(20) NOT NULL,
  `nofactura` bigint(20) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `observacion` varchar(50) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  `mprecio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `detallefacturanula`
--

INSERT INTO `detallefacturanula` (`correlativo`, `nofactura`, `codproducto`, `observacion`, `cantidad`, `precio_venta`, `mprecio`) VALUES
(0, 0, 2, '-', 1, 00.00, 0.00);


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefactura_ele`
--

CREATE TABLE `detallefactura_ele` (
  `correlativo` bigint(20) NOT NULL,
  `nofactura` bigint(20) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `observacion` varchar(50) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  `mprecio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_temp`
--

CREATE TABLE `detalle_temp` (
  `correlativo` int(11) NOT NULL,
  `token_user` varchar(50) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `observacion` varchar(50) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  `mprecio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas`
--

CREATE TABLE `entradas` (
  `correlativo` int(11) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `cantidad` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estadistica`
--

CREATE TABLE `estadistica` (
  `dia` date NOT NULL,
  `anno` int(10) DEFAULT 0,
  `mes` varchar(10) DEFAULT '0',
  `ventradas` decimal(10,2) DEFAULT 0.00,
  `abono` decimal(10,2) NOT NULL,
  `pentradas` int(10) DEFAULT 0,
  `promedioentradas` decimal(10,2) NOT NULL,
  `vsalidas` decimal(10,2) DEFAULT 0.00,
  `psalidas` int(10) DEFAULT 0,
  `promediosalidas` decimal(10,2) NOT NULL,
  `gastos` decimal(10,2) DEFAULT 0.00,
  `neto` decimal(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `estadistica`
--

INSERT INTO `estadistica` (`dia`, `anno`, `mes`, `ventradas`, `abono`, `pentradas`, `promedioentradas`, `vsalidas`, `psalidas`, `promediosalidas`, `gastos`, `neto`) VALUES
('2024-04-22', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-04-23', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-04-24', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-04-25', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-04-26', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-04-27', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-04-28', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-04-29', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-04-30', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-01', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-02', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-03', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-04', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-05', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-06', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-07', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-08', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-09', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-10', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-11', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-12', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-13', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-14', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-15', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-16', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-17', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-18', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-19', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-20', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-21', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-22', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-23', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-24', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-25', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-26', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-27', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-28', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-29', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-30', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-05-31', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-01', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-02', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-03', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-04', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-05', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-06', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-07', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-08', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-09', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-10', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-11', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-12', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-13', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-14', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-15', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-16', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-17', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-18', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-19', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-20', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-21', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-22', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-23', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-24', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-25', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-26', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-27', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-28', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-29', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-06-30', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-01', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-02', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-03', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-04', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-05', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-06', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-07', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-08', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-09', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-10', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-11', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-12', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-13', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-14', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-15', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-16', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-17', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-18', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-19', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-20', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-21', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-22', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-23', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-24', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-25', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-26', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-27', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-28', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-29', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-30', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-07-31', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-01', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-02', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-03', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-04', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-05', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-06', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-07', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-08', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-09', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-10', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-11', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-12', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-13', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-14', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-15', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-16', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-17', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-18', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-19', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-20', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-21', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-22', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-23', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-24', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-25', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-26', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-27', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-28', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-29', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-30', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-08-31', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-01', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-02', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-03', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-04', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-05', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-06', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-07', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-08', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-09', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-10', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-11', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-12', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-13', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-14', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-15', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-16', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-17', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-18', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-19', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-20', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-21', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-22', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-23', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-24', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-25', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-26', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-27', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-28', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-29', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-09-30', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-01', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-02', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-03', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-04', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-05', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-06', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-07', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-08', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-09', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-10', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-11', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-12', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-13', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-14', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-15', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-16', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-17', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-18', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-19', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-20', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-21', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-22', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-23', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-24', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-25', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-26', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-27', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-28', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-29', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-30', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-10-31', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-01', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-02', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-03', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-04', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-05', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-06', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-07', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-08', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-09', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-10', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-11', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-12', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-13', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-14', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-15', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-16', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-17', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-18', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-19', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-20', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-21', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-22', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-23', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-24', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-25', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-26', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-27', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-28', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-29', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-11-30', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-01', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-02', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-03', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-04', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-05', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-06', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-07', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-08', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-09', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-10', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-11', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-12', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-13', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-14', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-15', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-16', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-17', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-18', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-19', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-20', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-21', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-22', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-23', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-24', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-25', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-26', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-27', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-28', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-29', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-30', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00),
('2024-12-31', 0, '0', 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00, 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estadistica_mes`
--

CREATE TABLE `estadistica_mes` (
  `mes` int(20) NOT NULL,
  `periodo` varchar(20) NOT NULL,
  `ventradasm` int(20) NOT NULL,
  `pentradasm` int(20) NOT NULL,
  `vsalidasm` int(20) NOT NULL,
  `psalidasm` int(20) NOT NULL,
  `gastosm` int(20) NOT NULL,
  `netom` int(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado`
--

CREATE TABLE `estado` (
  `idestado` int(5) NOT NULL,
  `estado` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estado`
--

INSERT INTO `estado` (`idestado`, `estado`) VALUES
(1, 'EN PROCESO'),
(2, 'FINALIZADA'),
(3, 'ANULADA'),
(4, 'FACTURADA'),
(5, 'BAJA');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura`
--

CREATE TABLE `factura` (
  `nofactura` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario` int(11) NOT NULL,
  `codcliente` int(11) NOT NULL,
  `totalfactura` decimal(10,2) NOT NULL,
  `abono` decimal(10,2) NOT NULL,
  `metodoabono` varchar(20) NOT NULL,
  `referenciaabono` varchar(20) NOT NULL,
  `saldo` decimal(10,2) NOT NULL,
  `mpago` varchar(20) NOT NULL,
  `referenciapago` varchar(20) NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 1,
  `fechafinal` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `factura`
--

INSERT INTO `factura` (`nofactura`, `fecha`, `usuario`, `codcliente`, `totalfactura`, `abono`, `metodoabono`, `referenciaabono`, `saldo`, `mpago`, `referenciapago`, `estado`, `fechafinal`) VALUES
(1, '2024-08-23 10:15:30', 1, 1, 8000.00, 3000.00, 'efectivo', 'ref001', 5000.00, 'efectivo', '', 2, '2024-08-25 15:30:00'),
(2, '2024-08-23 11:45:22', 1, 2, 12000.00, 5000.00, 'nequi', 'ref002', 7000.00, 'nequi', '', 2, '2024-08-25 16:00:00'),
(3, '2024-08-23 14:00:00', 1, 3, 14000.00, 4000.00, 'daviplata', 'ref003', 10000.00, 'daviplata', '', 2, '2024-08-26 17:00:00'),
(4, '2024-08-23 12:30:45', 1, 4, 10000.00, 2000.00, 'efectivo', 'ref004', 8000.00, 'efectivo', '', 2, '2024-08-26 13:00:00'),
(5, '2024-08-23 15:15:10', 1, 5, 15000.00, 6000.00, 'nequi', 'ref005', 9000.00, 'nequi', '', 3, '2024-08-26 15:15:10'),
(6, '2024-08-23 16:45:05', 1, 6, 14000.00, 7000.00, 'daviplata', 'ref006', 7000.00, 'daviplata', '', 2, '2024-08-26 17:45:05'),
(7, '2024-08-23 09:30:30', 1, 7, 8000.00, 3000.00, 'efectivo', 'ref007', 5000.00, 'efectivo', '', 2, '2024-08-26 10:30:00'),
(8, '2024-08-23 14:15:40', 1, 8, 15000.00, 6000.00, 'nequi', 'ref008', 9000.00, 'nequi', '', 2, '2024-08-26 15:15:00'),
(9, '2024-08-23 11:00:20', 1, 9, 9000.00, 4000.00, 'daviplata', 'ref009', 5000.00, 'daviplata', '', 2, '2024-08-26 16:00:00'),
(10, '2024-08-23 13:30:10', 1, 10, 6000.00, 2000.00, 'efectivo', 'ref010', 4000.00, 'efectivo', '', 2, '2024-08-26 14:30:10'),
(11, '2024-08-23 10:15:50', 1, 11, 7000.00, 3000.00, 'nequi', 'ref011', 4000.00, 'nequi', '', 2, '2024-08-27 11:15:50'),
(12, '2024-08-23 12:00:00', 1, 12, 8000.00, 2000.00, 'efectivo', 'ref012', 6000.00, 'efectivo', '', 2, '2024-08-27 13:00:00'),
(13, '2024-08-23 15:30:45', 1, 13, 13000.00, 5000.00, 'daviplata', 'ref013', 8000.00, 'daviplata', '', 2, '2024-08-27 14:00:00'),
(14, '2024-08-24 14:15:10', 1, 14, 10000.00, 3000.00, 'nequi', 'ref014', 7000.00, 'nequi', '', 2, '2024-08-27 15:15:10'),
(15, '2024-08-24 16:45:05', 1, 15, 12000.00, 6000.00, 'daviplata', 'ref015', 6000.00, 'daviplata', '', 2, '2024-08-27 17:45:05'),
(16, '2024-08-24 09:30:30', 1, 16, 7000.00, 3000.00, 'efectivo', 'ref016', 4000.00, 'efectivo', '', 2, '2024-08-27 10:30:00'),
(17, '2024-08-24 14:15:40', 1, 17, 14000.00, 6000.00, 'nequi', 'ref017', 8000.00, 'nequi', '', 3, '2024-08-27 15:15:00'),
(18, '2024-08-24 11:00:20', 1, 18, 10000.00, 4000.00, 'daviplata', 'ref018', 6000.00, 'daviplata', '', 2, '2024-08-27 16:00:00'),
(19, '2024-08-24 13:30:10', 1, 19, 8000.00, 2000.00, 'efectivo', 'ref019', 6000.00, 'efectivo', '', 2, '2024-08-27 14:30:10'),
(20, '2024-08-24 10:15:50', 1, 20, 15000.00, 7000.00, 'nequi', 'ref020', 8000.00, 'nequi', '', 2, '2024-08-28 11:15:50'),
(21, '2024-08-24 12:00:00', 1, 21, 6000.00, 2000.00, 'efectivo', 'ref021', 4000.00, 'efectivo', '', 2, '2024-08-28 13:00:00'),
(22, '2024-08-24 15:30:45', 1, 22, 13000.00, 5000.00, 'daviplata', 'ref022', 8000.00, 'daviplata', '', 3, '2024-08-28 14:00:00'),
(23, '2024-08-25 14:15:10', 1, 23, 14000.00, 6000.00, 'nequi', 'ref023', 8000.00, 'nequi', '', 2, '2024-08-28 15:15:10'),
(24, '2024-08-25 16:45:05', 1, 24, 9000.00, 4000.00, 'daviplata', 'ref024', 5000.00, 'daviplata', '', 2, '2024-08-28 17:45:05'),
(25, '2024-08-25 09:30:30', 1, 25, 10000.00, 3000.00, 'efectivo', 'ref025', 7000.00, 'efectivo', '', 2, '2024-08-28 10:30:00'),
(26, '2024-08-25 14:15:40', 1, 26, 12000.00, 5000.00, 'nequi', 'ref026', 7000.00, 'nequi', '', 2, '2024-08-28 15:15:00'),
(27, '2024-08-25 11:00:20', 1, 27, 9000.00, 3000.00, 'daviplata', 'ref027', 6000.00, 'daviplata', '', 2, '2024-08-28 16:00:00'),
(28, '2024-08-25 13:30:10', 1, 28, 13000.00, 4000.00, 'efectivo', 'ref028', 9000.00, 'efectivo', '', 2, '2024-08-28 14:30:10'),
(29, '2024-08-25 10:15:50', 1, 29, 8000.00, 2000.00, 'nequi', 'ref029', 6000.00, 'nequi', '', 2, '2024-08-29 11:15:50'),
(30, '2024-08-25 12:00:00', 1, 30, 15000.00, 6000.00, 'efectivo', 'ref030', 9000.00, 'efectivo', '', 2, '2024-08-29 13:00:00'),
(31, '2024-08-26 15:30:45', 1, 31, 12000.00, 5000.00, 'daviplata', 'ref031', 7000.00, 'daviplata', '', 3, '2024-08-29 14:00:00'),
(32, '2024-08-26 14:15:10', 1, 32, 11000.00, 4000.00, 'nequi', 'ref032', 7000.00, 'nequi', '', 2, '2024-08-29 15:15:10'),
(33, '2024-08-26 16:45:05', 1, 33, 7000.00, 3000.00, 'daviplata', 'ref033', 4000.00, 'daviplata', '', 2, '2024-08-29 17:45:05'),
(34, '2024-08-27 09:30:30', 1, 15, 15000.00, 6000.00, 'efectivo', 'ref034', 9000.00, 'efectivo', '', 2, '2024-08-29 10:30:00'),
(35, '2024-08-27 14:15:40', 1, 16, 13000.00, 5000.00, 'nequi', 'ref035', 8000.00, 'nequi', '', 2, '2024-08-29 15:15:00'),
(36, '2024-08-28 11:00:20', 1, 17, 14000.00, 7000.00, 'daviplata', 'ref036', 7000.00, 'daviplata', '', 1, '2024-08-28 11:00:20'),
(37, '2024-08-28 13:30:10', 1, 18, 9000.00, 3000.00, 'efectivo', 'ref037', 6000.00, 'efectivo', '', 1, '2024-08-28 13:30:10'),
(38, '2024-08-28 10:15:50', 1, 19, 11000.00, 4000.00, 'nequi', 'ref038', 7000.00, 'nequi', '', 1, '2024-08-28 10:15:50'),
(39, '2024-08-29 12:00:00', 1, 20, 10000.00, 3000.00, 'efectivo', 'ref039', 7000.00, 'efectivo', '', 1, '2024-08-29 12:00:00'),
(40, '2024-08-29 15:30:45', 1, 21, 9000.00, 4000.00, 'daviplata', 'ref040', 5000.00, 'daviplata', '', 1, '2024-08-29 15:30:45');


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura2`
--

CREATE TABLE `factura2` (
  `nofactura` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario` int(11) NOT NULL,
  `codcliente` int(11) NOT NULL,
  `totalfactura` decimal(10,2) NOT NULL,
  `abono` decimal(10,2) NOT NULL,
  `metodoabono` varchar(20) NOT NULL,
  `referenciaabono` varchar(20) NOT NULL,
  `saldo` decimal(10,2) NOT NULL,
  `mpago` varchar(20) NOT NULL,
  `referenciapago` varchar(20) NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 1,
  `fechafinal` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `factura2`
--
INSERT INTO `factura2` (`nofactura`, `fecha`, `usuario`, `codcliente`, `totalfactura`, `abono`, `metodoabono`, `referenciaabono`, `saldo`, `mpago`, `referenciapago`, `estado`, `fechafinal`) VALUES
(1, '2024-08-23 10:15:30', 1, 1, 8000.00, 3000.00, 'efectivo', 'ref001', 5000.00, 'efectivo', '', 2, '2024-08-25 15:30:00'),
(2, '2024-08-23 11:45:22', 1, 2, 12000.00, 5000.00, 'nequi', 'ref002', 7000.00, 'nequi', '', 2, '2024-08-25 16:00:00'),
(3, '2024-08-23 14:00:00', 1, 3, 14000.00, 4000.00, 'daviplata', 'ref003', 10000.00, 'daviplata', '', 2, '2024-08-26 17:00:00'),
(4, '2024-08-23 12:30:45', 1, 4, 10000.00, 2000.00, 'efectivo', 'ref004', 8000.00, 'efectivo', '', 2, '2024-08-26 13:00:00'),
(6, '2024-08-23 16:45:05', 1, 6, 14000.00, 7000.00, 'daviplata', 'ref006', 7000.00, 'daviplata', '', 2, '2024-08-26 17:45:05'),
(7, '2024-08-23 09:30:30', 1, 7, 8000.00, 3000.00, 'efectivo', 'ref007', 5000.00, 'efectivo', '', 2, '2024-08-26 10:30:00'),
(8, '2024-08-23 14:15:40', 1, 8, 15000.00, 6000.00, 'nequi', 'ref008', 9000.00, 'nequi', '', 2, '2024-08-26 15:15:00'),
(9, '2024-08-23 11:00:20', 1, 9, 9000.00, 4000.00, 'daviplata', 'ref009', 5000.00, 'daviplata', '', 2, '2024-08-26 16:00:00'),
(10, '2024-08-23 13:30:10', 1, 10, 6000.00, 2000.00, 'efectivo', 'ref010', 4000.00, 'efectivo', '', 2, '2024-08-26 14:30:10'),
(11, '2024-08-23 10:15:50', 1, 11, 7000.00, 3000.00, 'nequi', 'ref011', 4000.00, 'nequi', '', 2, '2024-08-27 11:15:50'),
(12, '2024-08-23 12:00:00', 1, 12, 8000.00, 2000.00, 'efectivo', 'ref012', 6000.00, 'efectivo', '', 2, '2024-08-27 13:00:00'),
(13, '2024-08-23 15:30:45', 1, 13, 13000.00, 5000.00, 'daviplata', 'ref013', 8000.00, 'daviplata', '', 2, '2024-08-27 14:00:00'),
(14, '2024-08-24 14:15:10', 1, 14, 10000.00, 3000.00, 'nequi', 'ref014', 7000.00, 'nequi', '', 2, '2024-08-27 15:15:10'),
(15, '2024-08-24 16:45:05', 1, 15, 12000.00, 6000.00, 'daviplata', 'ref015', 6000.00, 'daviplata', '', 2, '2024-08-27 17:45:05'),
(16, '2024-08-24 09:30:30', 1, 16, 7000.00, 3000.00, 'efectivo', 'ref016', 4000.00, 'efectivo', '', 2, '2024-08-27 10:30:00'),
(18, '2024-08-24 11:00:20', 1, 18, 10000.00, 4000.00, 'daviplata', 'ref018', 6000.00, 'daviplata', '', 2, '2024-08-27 16:00:00'),
(19, '2024-08-24 13:30:10', 1, 19, 8000.00, 2000.00, 'efectivo', 'ref019', 6000.00, 'efectivo', '', 2, '2024-08-27 14:30:10'),
(20, '2024-08-24 10:15:50', 1, 20, 15000.00, 7000.00, 'nequi', 'ref020', 8000.00, 'nequi', '', 2, '2024-08-28 11:15:50'),
(21, '2024-08-24 12:00:00', 1, 21, 6000.00, 2000.00, 'efectivo', 'ref021', 4000.00, 'efectivo', '', 2, '2024-08-28 13:00:00'),
(23, '2024-08-25 14:15:10', 1, 23, 14000.00, 6000.00, 'nequi', 'ref023', 8000.00, 'nequi', '', 2, '2024-08-28 15:15:10'),
(24, '2024-08-25 16:45:05', 1, 24, 9000.00, 4000.00, 'daviplata', 'ref024', 5000.00, 'daviplata', '', 2, '2024-08-28 17:45:05'),
(25, '2024-08-25 09:30:30', 1, 25, 10000.00, 3000.00, 'efectivo', 'ref025', 7000.00, 'efectivo', '', 2, '2024-08-28 10:30:00'),
(26, '2024-08-25 14:15:40', 1, 26, 12000.00, 5000.00, 'nequi', 'ref026', 7000.00, 'nequi', '', 2, '2024-08-28 15:15:00'),
(27, '2024-08-25 11:00:20', 1, 27, 9000.00, 3000.00, 'daviplata', 'ref027', 6000.00, 'daviplata', '', 2, '2024-08-28 16:00:00'),
(28, '2024-08-25 13:30:10', 1, 28, 13000.00, 4000.00, 'efectivo', 'ref028', 9000.00, 'efectivo', '', 2, '2024-08-28 14:30:10'),
(29, '2024-08-25 10:15:50', 1, 29, 8000.00, 2000.00, 'nequi', 'ref029', 6000.00, 'nequi', '', 2, '2024-08-29 11:15:50'),
(30, '2024-08-25 12:00:00', 1, 30, 15000.00, 6000.00, 'efectivo', 'ref030', 9000.00, 'efectivo', '', 2, '2024-08-29 13:00:00'),
(32, '2024-08-26 14:15:10', 1, 32, 11000.00, 4000.00, 'nequi', 'ref032', 7000.00, 'nequi', '', 2, '2024-08-29 15:15:10'),
(33, '2024-08-26 16:45:05', 1, 33, 7000.00, 3000.00, 'daviplata', 'ref033', 4000.00, 'daviplata', '', 2, '2024-08-29 17:45:05'),
(34, '2024-08-27 09:30:30', 1, 15, 15000.00, 6000.00, 'efectivo', 'ref034', 9000.00, 'efectivo', '', 2, '2024-08-29 10:30:00'),
(35, '2024-08-27 14:15:40', 1, 16, 13000.00, 5000.00, 'nequi', 'ref035', 8000.00, 'nequi', '', 2, '2024-08-29 15:15:00');
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturabaja`
--

CREATE TABLE `facturabaja` (
  `nofactura` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario` int(11) NOT NULL,
  `codcliente` int(11) NOT NULL,
  `totalfactura` decimal(10,2) NOT NULL,
  `abono` decimal(10,2) NOT NULL,
  `metodoabono` varchar(20) NOT NULL,
  `referenciaabono` varchar(20) NOT NULL,
  `saldo` decimal(10,2) NOT NULL,
  `mpago` varchar(20) NOT NULL,
  `referenciapago` varchar(20) NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 1,
  `fechafinal` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturanula`
--

CREATE TABLE `facturanula` (
  `nofactura` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario` int(11) NOT NULL,
  `codcliente` int(11) NOT NULL,
  `totalfactura` decimal(10,2) NOT NULL,
  `abono` decimal(10,2) NOT NULL,
  `metodoabono` varchar(20) NOT NULL,
  `referenciaabono` varchar(20) NOT NULL,
  `saldo` decimal(10,2) NOT NULL,
  `mpago` varchar(20) NOT NULL,
  `referenciapago` varchar(20) NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 1,
  `fechafinal` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `facturanula`
--

INSERT INTO `facturanula` (`nofactura`, `fecha`, `usuario`, `codcliente`, `totalfactura`, `abono`, `metodoabono`, `referenciaabono`, `saldo`, `mpago`, `referenciapago`, `estado`, `fechafinal`) VALUES
(5, '2024-08-23 15:15:10', 1, 5, 15000.00, 6000.00, 'nequi', 'ref005', 9000.00, 'nequi', '', 3, '2024-08-26 15:15:10'),
(22, '2024-08-24 15:30:45', 1, 22, 13000.00, 5000.00, 'daviplata', 'ref022', 8000.00, 'daviplata', '', 3, '2024-08-28 14:00:00'),
(31, '2024-08-26 15:30:45', 1, 31, 12000.00, 5000.00, 'daviplata', 'ref031', 7000.00, 'daviplata', '', 3, '2024-08-29 14:00:00');


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura_ele`
--

CREATE TABLE `factura_ele` (
  `nofactura` int(11) NOT NULL,
  `noorden` int(10) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario` int(11) NOT NULL,
  `codcliente` int(11) NOT NULL,
  `totalfactura` decimal(10,2) NOT NULL,
  `abono` decimal(10,2) NOT NULL,
  `metodoabono` varchar(20) NOT NULL,
  `referenciaabono` varchar(20) NOT NULL,
  `saldo` decimal(10,2) NOT NULL,
  `mpago` varchar(20) NOT NULL,
  `referenciapago` varchar(20) NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 1,
  `fechafinal` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `codproducto` int(11) NOT NULL,
  `descripcion` varchar(200) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `existencia` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`codproducto`, `descripcion`, `precio`, `existencia`, `usuario_id`) VALUES
(1, 'Ajuste de pantalones', 8000.00, 99990, 1),
(2, 'Cambio de cremalleras ', 12000.00, 99993, 1),
(3, 'Arreglo de dobladillos', 7000.00, 99996, 1),
(4, 'Reducción de tallas en camisas', 10000.00, 99981, 1),
(5, 'Confección de cortinas', 15000.00, 99989, 1),
(6, 'Ajuste de vestidos', 14000.00, 99961, 1),
(7, 'Reparación de roturas en jeans', 6000.00, 99997, 1),
(8, 'Cambio de botones en abrigos', 5000.00, 99994, 1),
(9, 'Confección de cojines decorativos', 9000.00, 99997, 1),
(10, 'Personalización de camisetas', 11000.00, 99995, 1),
(11, 'Ajuste de mangas en chaquetas', 13000.00, 99995, 1),
(12, 'Arreglo de roturas en bolsos', 7000.00, 99996, 1),
(13, 'Confección de uniformes escolares', 14000.00, 99999, 1),
(14, 'Reparación de cremalleras en bolsos', 6000.00, 99997, 1),
(15, 'Ajuste de tallas en faldas', 9000.00, 99959, 1);


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `codproveedor` int(11) NOT NULL,
  `proveedor` varchar(100) NOT NULL,
  `contacto` varchar(100) NOT NULL,
  `telefono` int(11) NOT NULL,
  `direccion` varchar(100) NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `idrol` int(11) NOT NULL,
  `rol` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`idrol`, `rol`) VALUES
(1, 'Administrador'),
(2, 'Supervisor'),
(3, 'Servicio');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `salidas`
--

CREATE TABLE `salidas` (
  `id` int(10) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `concepto` varchar(30) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `salidas`
--

INSERT INTO `salidas` (`id`, `fecha`, `concepto`, `precio`, `usuario_id`) VALUES
(1, '2024-08-16 09:45:12', 'Recibo Codensa agosto 2024', 28000.00, 1),
(2, '2024-08-17 14:30:45', 'Compra de materiales', 15000.00, 1),
(3, '2024-08-18 10:15:32', 'Pago servicio de internet', 32000.00, 1),
(4, '2024-08-19 11:50:50', 'Recarga de celular', 10000.00, 1),
(5, '2024-08-20 16:22:18', 'Recibo Vanti', 30000.00, 1),
(6, '2024-08-21 13:35:42', 'Mantenimiento maquina coser', 35000.00, 1),
(7, '2024-08-22 08:45:10', 'Pago prestamo', 20000.00, 1),
(8, '2024-08-23 15:10:24', 'Compra de materiales', 12000.00, 1),
(9, '2024-08-24 12:25:36', 'Gastos de transporte', 18000.00, 1),
(10, '2024-08-25 09:50:58', 'COmpra tela roja', 27000.00, 1),
(11, '2024-08-26 14:05:15', 'Pago prestamo', 25000.00, 1),
(12, '2024-08-27 17:30:40', 'Recibo adminsitracion agosto 2024', 15000.00, 1),
(13, '2024-08-28 10:22:17', 'Compra de café', 8000.00, 1);


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idusuario` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `cedula` int(20) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `usuario` varchar(20) NOT NULL,
  `clave` varchar(50) NOT NULL,
  `rol` int(11) NOT NULL,
  `telefono` varchar(30) NOT NULL,
  `estado` int(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idusuario`, `nombre`, `cedula`, `correo`, `usuario`, `clave`, `rol`, `telefono`, `estado`) VALUES
(1, 'ADMIN', 0, 'marcelagmcm@gmail.com', 'admin', '21232f297a57a5a743894a0e4a801fc3', 1, '3158246716', 1);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`idcliente`);

--
-- Indices de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `costos`
--
ALTER TABLE `costos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `detallefactura`
--
ALTER TABLE `detallefactura`
  ADD PRIMARY KEY (`correlativo`);

--
-- Indices de la tabla `detallefactura2`
--
ALTER TABLE `detallefactura2`
  ADD PRIMARY KEY (`correlativo`);

--
-- Indices de la tabla `detallefacturabaja`
--
ALTER TABLE `detallefacturabaja`
  ADD PRIMARY KEY (`correlativo`);

--
-- Indices de la tabla `detallefacturanula`
--
ALTER TABLE `detallefacturanula`
  ADD PRIMARY KEY (`correlativo`);

--
-- Indices de la tabla `detallefactura_ele`
--
ALTER TABLE `detallefactura_ele`
  ADD PRIMARY KEY (`correlativo`);

--
-- Indices de la tabla `detalle_temp`
--
ALTER TABLE `detalle_temp`
  ADD PRIMARY KEY (`correlativo`);

--
-- Indices de la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD PRIMARY KEY (`correlativo`);

--
-- Indices de la tabla `estadistica`
--
ALTER TABLE `estadistica`
  ADD PRIMARY KEY (`dia`);

--
-- Indices de la tabla `estadistica_mes`
--
ALTER TABLE `estadistica_mes`
  ADD PRIMARY KEY (`periodo`);

--
-- Indices de la tabla `estado`
--
ALTER TABLE `estado`
  ADD PRIMARY KEY (`idestado`);

--
-- Indices de la tabla `factura`
--
ALTER TABLE `factura`
  ADD PRIMARY KEY (`nofactura`);

--
-- Indices de la tabla `factura2`
--
ALTER TABLE `factura2`
  ADD PRIMARY KEY (`nofactura`);

--
-- Indices de la tabla `facturabaja`
--
ALTER TABLE `facturabaja`
  ADD PRIMARY KEY (`nofactura`);

--
-- Indices de la tabla `facturanula`
--
ALTER TABLE `facturanula`
  ADD PRIMARY KEY (`nofactura`);

--
-- Indices de la tabla `factura_ele`
--
ALTER TABLE `factura_ele`
  ADD PRIMARY KEY (`nofactura`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`codproducto`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`codproveedor`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`idrol`);

--
-- Indices de la tabla `salidas`
--
ALTER TABLE `salidas`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idusuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `idcliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `costos`
--
ALTER TABLE `costos`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `detallefactura`
--
ALTER TABLE `detallefactura`
  MODIFY `correlativo` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=273;

--
-- AUTO_INCREMENT de la tabla `detallefactura2`
--
ALTER TABLE `detallefactura2`
  MODIFY `correlativo` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=264;

--
-- AUTO_INCREMENT de la tabla `detallefacturabaja`
--
ALTER TABLE `detallefacturabaja`
  MODIFY `correlativo` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT de la tabla `detallefacturanula`
--
ALTER TABLE `detallefacturanula`
  MODIFY `correlativo` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=258;

--
-- AUTO_INCREMENT de la tabla `detallefactura_ele`
--
ALTER TABLE `detallefactura_ele`
  MODIFY `correlativo` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=185;

--
-- AUTO_INCREMENT de la tabla `detalle_temp`
--
ALTER TABLE `detalle_temp`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=234;

--
-- AUTO_INCREMENT de la tabla `entradas`
--
ALTER TABLE `entradas`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `estado`
--
ALTER TABLE `estado`
  MODIFY `idestado` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `factura`
--
ALTER TABLE `factura`
  MODIFY `nofactura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT de la tabla `factura2`
--
ALTER TABLE `factura2`
  MODIFY `nofactura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=131;

--
-- AUTO_INCREMENT de la tabla `facturabaja`
--
ALTER TABLE `facturabaja`
  MODIFY `nofactura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT de la tabla `facturanula`
--
ALTER TABLE `facturanula`
  MODIFY `nofactura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=129;

--
-- AUTO_INCREMENT de la tabla `factura_ele`
--
ALTER TABLE `factura_ele`
  MODIFY `nofactura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `codproducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `codproveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `idrol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `salidas`
--
ALTER TABLE `salidas`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idusuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
