-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 20-12-2021 a las 15:23:02
-- Versión del servidor: 10.4.13-MariaDB
-- Versión de PHP: 7.4.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "-05:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `Proyecto`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER= `root`@`localhost` PROCEDURE `actualizar_precio_producto` (IN `n_cantidad` INT, IN `n_precio` DECIMAL(10,2), IN `codigo` INT)  BEGIN
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

CREATE DEFINER= `root`@`localhost` PROCEDURE `add_detalle_temp` (`codigo` INT, `cantidad` INT, `observacion` VARCHAR(50), `mprecio` DECIMAL(10,2), `token_user` VARCHAR(50))  BEGIN
DECLARE precio_actual decimal(10,2);
SELECT precio INTO precio_actual FROM producto WHERE codproducto = codigo;
INSERT INTO detalle_temp(token_user, codproducto, cantidad, observacion, precio_venta, mprecio) VALUES (token_user, codigo, cantidad, observacion, precio_actual, mprecio);
SELECT tmp.correlativo, tmp.codproducto, p.descripcion, tmp.cantidad, tmp.observacion, tmp.precio_venta, tmp.mprecio FROM detalle_temp tmp INNER JOIN producto p ON tmp.codproducto = p.codproducto WHERE tmp.token_user = token_user;
END$$

CREATE DEFINER= `root`@`localhost` PROCEDURE `data` ()  BEGIN
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

CREATE DEFINER= `root`@`localhost` PROCEDURE `data2` ()  BEGIN
DECLARE egresos INT;
SELECT SUM(precio) INTO egresos FROM salidas;
SELECT egresos;
END$$

CREATE DEFINER= `root`@`localhost` PROCEDURE `del_detalle_temp` (`id_detalle` INT, `token` VARCHAR(50))  BEGIN
DELETE FROM detalle_temp WHERE correlativo = id_detalle;
SELECT tmp.correlativo, tmp.codproducto, p.descripcion, tmp.cantidad, tmp.observacion,tmp.precio_venta FROM detalle_temp tmp INNER JOIN producto p ON tmp.codproducto = p.codproducto WHERE tmp.token_user = token;
END$$

CREATE DEFINER= `root`@`localhost` PROCEDURE `filldates` (`dateStart` DATE, `dateEnd` DATE)  BEGIN
  WHILE dateStart <= dateEnd DO
    INSERT INTO estadistica (dia) VALUES (dateStart);
    SET dateStart = DATE_ADD(dateStart, INTERVAL 1 DAY);
  END WHILE;
END$$

CREATE DEFINER= `root`@`localhost` PROCEDURE `procesar_venta` (IN `cod_usuario` INT, IN `cod_cliente` INT, IN `token` VARCHAR(50))  BEGIN
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
  `nombre` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `telefono` varchar(30) COLLATE utf8_spanish_ci NOT NULL,
  `direccion` varchar(200) COLLATE utf8_spanish_ci NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `correo` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `fecha` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `cliente`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion`
--

CREATE TABLE `configuracion` (
  `id` int(11) NOT NULL,
  `nit` int(11) NOT NULL,
  `nombre` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `razon_social` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `telefono` varchar(30) COLLATE utf8_spanish_ci NOT NULL,
  `email` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `direccion` text COLLATE utf8_spanish_ci NOT NULL,
  `igv` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `configuracion`
--

INSERT INTO `configuracion` (`id`, `nit`, `nombre`, `razon_social`, `telefono`, `email`, `direccion`, `igv`) VALUES
(1, 1012365874, 'LIMPUS', 'Lavaseco', '3112420201', 'limpus@gmail.com', 'Carrera 105 Nro. 64c-22', '1.19');

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `costos`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefactura`
--

CREATE TABLE `detallefactura` (
  `correlativo` bigint(20) NOT NULL,
  `nofactura` bigint(20) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `observacion` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  `mprecio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `detallefactura`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefactura2`
--

CREATE TABLE `detallefactura2` (
  `correlativo` bigint(20) NOT NULL,
  `nofactura` bigint(20) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `observacion` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  `mprecio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `detallefactura2`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefacturabaja`
--

CREATE TABLE `detallefacturabaja` (
  `correlativo` bigint(20) NOT NULL,
  `nofactura` bigint(20) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `observacion` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  `mprecio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `detallefacturabaja`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefacturanula`
--

CREATE TABLE `detallefacturanula` (
  `correlativo` bigint(20) NOT NULL,
  `nofactura` bigint(20) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `observacion` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  `mprecio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `detallefacturanula`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefactura_ele`
--

CREATE TABLE `detallefactura_ele` (
  `correlativo` bigint(20) NOT NULL,
  `nofactura` bigint(20) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `observacion` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  `mprecio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `detallefactura_ele`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_temp`
--

CREATE TABLE `detalle_temp` (
  `correlativo` int(11) NOT NULL,
  `token_user` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `codproducto` int(11) NOT NULL,
  `observacion` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `estadistica`
--
INSERT INTO `estadistica` (`dia`, `anno`, `mes`, `ventradas`, `abono`, `pentradas`, `promedioentradas`, `vsalidas`, `psalidas`, `promediosalidas`, `gastos`, `neto`) VALUES
('2021-12-20', 2021, 'December', '0.00', '0.00', 0, '0.00', '0.00', 0, '0.00', '0.00', '0.00'),
('2021-12-21', 2021, 'December', '0.00', '0.00', 0, '0.00', '0.00', 0, '0.00', '0.00', '0.00'),
('2021-12-22', 2021, 'December', '0.00', '0.00', 0, '0.00', '0.00', 0, '0.00', '0.00', '0.00'),
('2021-12-23', 2021, 'December', '0.00', '0.00', 0, '0.00', '0.00', 0, '0.00', '0.00', '0.00'),
('2021-12-24', 2021, 'December', '0.00', '0.00', 0, '0.00', '0.00', 0, '0.00', '0.00', '0.00'),
('2021-12-25', 2021, 'December', '0.00', '0.00', 0, '0.00', '0.00', 0, '0.00', '0.00', '0.00'),
('2021-12-26', 2021, 'December', '0.00', '0.00', 0, '0.00', '0.00', 0, '0.00', '0.00', '0.00'),
('2021-12-27', 2021, 'December', '0.00', '0.00', 0, '0.00', '0.00', 0, '0.00', '0.00', '0.00'),
('2021-12-28', 2021, 'December', '0.00', '0.00', 0, '0.00', '0.00', 0, '0.00', '0.00', '0.00'),
('2021-12-29', 2021, 'December', '0.00', '0.00', 0, '0.00', '0.00', 0, '0.00', '0.00', '0.00'),
('2021-12-30', 2021, 'December', '0.00', '0.00', 0, '0.00', '0.00', 0, '0.00', '0.00', '0.00'),
('2021-12-31', 2021, 'December', '0.00', '0.00', 0, '0.00', '0.00', 0, '0.00', '0.00', '0.00');

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `estadistica_mes`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado`
--

CREATE TABLE `estado` (
  `idestado` int(5) NOT NULL,
  `estado` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `estado`
--

INSERT INTO `estado` (`idestado`, `estado`) VALUES
(1, 'EN PROCESO'),
(2, 'DESCARGADA'),
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
  `metodoabono` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `referenciaabono` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `saldo` decimal(10,2) NOT NULL,
  `mpago` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `referenciapago` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 1,
  `fechafinal` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `factura`
--

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
  `metodoabono` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `referenciaabono` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `saldo` decimal(10,2) NOT NULL,
  `mpago` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `referenciapago` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 1,
  `fechafinal` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `factura2`
--

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
  `metodoabono` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `referenciaabono` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `saldo` decimal(10,2) NOT NULL,
  `mpago` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `referenciapago` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 1,
  `fechafinal` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `facturabaja`
--

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
  `metodoabono` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `referenciaabono` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `saldo` decimal(10,2) NOT NULL,
  `mpago` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `referenciapago` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 1,
  `fechafinal` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `facturanula`
--

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
  `metodoabono` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `referenciaabono` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `saldo` decimal(10,2) NOT NULL,
  `mpago` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `referenciapago` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 1,
  `fechafinal` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `factura_ele`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `codproducto` int(11) NOT NULL,
  `descripcion` varchar(200) COLLATE utf8_spanish_ci NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `existencia` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`codproducto`, `descripcion`, `precio`, `existencia`, `usuario_id`) VALUES
(1, 'PROMO 3X13000', '13000.00', 99999, 1),
(2, 'CAMISA', '4800.00', 99999, 1),
(3, 'CAMISETA', '4800.00', 99999, 1),
(4, 'PANTALON', '4800.00', 99988, 1),
(5, 'JEANS', '4800.00', 99997, 1),
(6, 'VESTIDO HOMBRE 2 PIEZAS', '9600.00', 99967, 1),
(7, 'CORBATA', '3100.00', 99999, 1),
(8, 'CHAQUETA SENCILLA', '7000.00', 99999, 1),
(9, 'CHAQUETA ACOLCHADA', '8000.00', 99997, 1),
(10, 'CHAQUETA DE PLUMAS', '9700.00', 99999, 1),
(11, 'CHAQUETA DE CUERO', '40000.00', 99998, 1),
(12, 'CHAQUETA DE CUERINA', '13400.00', 99999, 1),
(13, 'GABAN', '8000.00', 99999, 1),
(14, 'ABRIGO', '6500.00', 99999, 1),
(15, 'SACO', '6000.00', 99966, 1),
(16, 'SUETER', '5400.00', 99999, 1),
(17, 'CHALECO SENCILLO', '5400.00', 99999, 1),
(18, 'CHALECO PLUMAS', '8400.00', 99999, 1),
(19, 'BLUSA', '4800.00', 99999, 1),
(20, 'FALDA', '4800.00', 99999, 1),
(21, 'BATA DAMA', '6400.00', 99999, 1),
(22, 'CONJUNTO DAMA', '9600.00', 99999, 1),
(23, 'SUDADERA', '10400.00', 99999, 1),
(24, 'CHAL', '5400.00', 99999, 1),
(25, 'BUFANDA', '3700.00', 99996, 1),
(26, 'BERMUDA', '4800.00', 99977, 1),
(27, 'BOTAS', '9200.00', 99999, 1),
(28, 'TENIS', '9200.00', 99999, 1),
(29, 'GORRA', '4700.00', 99999, 1),
(30, 'BOLSO DAMA', '7200.00', 99999, 1),
(31, 'MORRAL', '9200.00', 99999, 1),
(32, 'OVEROL', '11200.00', 99999, 1),
(33, 'ALMOHADA SENCILLA', '7200.00', 99999, 1),
(34, 'ALMOHADA DE PLUMAS', '18200.00', 99999, 1),
(35, 'CUBRELECHO SENCILLO', '20500.00', 99997, 1),
(36, 'CUBRELECHO DOBLE', '22500.00', 99993, 1),
(37, 'CUBRELECHO QUEEN', '25500.00', 99997, 1),
(38, 'CUBRELECHO PLUMAS SENCILLO', '35500.00', 99999, 1),
(39, 'CUBRELECHO PLUMAS DOBLE', '40500.00', 99999, 1),
(40, 'CUBRELECHO PLUMAS QUEEN', '45500.00', 99999, 1),
(41, 'DUVET', '18500.00', 99999, 1),
(42, 'JUEGO DE SABANAS SENCILLO', '13200.00', 99999, 1),
(43, 'JUEGO DE SABANAS DOBLE', '15400.00', 99999, 1),
(44, 'FUNDAS', '4200.00', 99999, 1),
(45, 'COBIJA SENCILLA', '19200.00', 99997, 1),
(46, 'COBIJA DOBLE', '21500.00', 99999, 1),
(47, 'COJIN RELLENO', '6200.00', 99999, 1),
(48, 'MANTEL', '15200.00', 99987, 1),
(49, 'TOALLA', '4700.00', 99999, 1),
(50, 'CORTINA VELO PRENSE', '1900.00', 99999, 1),
(51, 'CORTINA PESADA PRENSE', '1900.00', 99999, 1),
(52, 'TAPETE MT CUADRADO', '20400.00', 99999, 1),
(53, 'MU?ECO', '15200.00', 99999, 1),
(54, 'VESTIDO NOVIA', '30200.00', 99995, 1),
(55, 'VESTIDO QUINCIA?ERA', '25200.00', 99999, 1),
(56, 'VESTIDO FIESTA CORTO', '8200.00', 99990, 1),
(57, 'VESTIDO FIESTA LARGO', '12200.00', 99999, 1),
(58, 'VESTIDO PRIMERA COMUNI?N', '15200.00', 99968, 1),
(59, 'TINTURA PRENDA', '15200.00', 99978, 1),
(60, 'TINTURA CHAQUETA', '17500.00', 99998, 1),
(61, 'SOLO PLANCHA', '3200.00', 99999, 1),
(62, 'FORROS DE CARRO UNIDAD', '5200.00', 99995, 1),
(63, 'BOXER', '4700.00', 99997, 1),
(64, 'PAR MEDIAS', '4700.00', 99996, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `codproveedor` int(11) NOT NULL,
  `proveedor` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `contacto` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `telefono` int(11) NOT NULL,
  `direccion` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `proveedor`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `idrol` int(11) NOT NULL,
  `rol` varchar(50) COLLATE utf8_spanish_ci NOT NULL
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `salidas`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idusuario` int(11) NOT NULL,
  `nombre` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `cedula` int(20) NOT NULL,
  `correo` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `usuario` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `clave` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `rol` int(11) NOT NULL,
  `telefono` varchar(30) COLLATE utf8_spanish_ci NOT NULL,
  `estado` int(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idusuario`, `nombre`, `cedula`, `correo`, `usuario`, `clave`, `rol`, `telefono`, `estado`) VALUES
(1, 'ADMIN', 0, 'ADMIN@GMAIL.COM', 'admin', '21232f297a57a5a743894a0e4a801fc3', 1, '3153808335', 1);

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
  MODIFY `idcliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

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
  MODIFY `correlativo` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=183;

--
-- AUTO_INCREMENT de la tabla `detallefactura2`
--
ALTER TABLE `detallefactura2`
  MODIFY `correlativo` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=177;

--
-- AUTO_INCREMENT de la tabla `detallefacturabaja`
--
ALTER TABLE `detallefacturabaja`
  MODIFY `correlativo` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT de la tabla `detallefacturanula`
--
ALTER TABLE `detallefacturanula`
  MODIFY `correlativo` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;

--
-- AUTO_INCREMENT de la tabla `detallefactura_ele`
--
ALTER TABLE `detallefactura_ele`
  MODIFY `correlativo` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=72;

--
-- AUTO_INCREMENT de la tabla `detalle_temp`
--
ALTER TABLE `detalle_temp`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=153;

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
  MODIFY `nofactura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=88;

--
-- AUTO_INCREMENT de la tabla `factura2`
--
ALTER TABLE `factura2`
  MODIFY `nofactura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- AUTO_INCREMENT de la tabla `facturabaja`
--
ALTER TABLE `facturabaja`
  MODIFY `nofactura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT de la tabla `facturanula`
--
ALTER TABLE `facturanula`
  MODIFY `nofactura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT de la tabla `factura_ele`
--
ALTER TABLE `factura_ele`
  MODIFY `nofactura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `codproducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

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
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idusuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
