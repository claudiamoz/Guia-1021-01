-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 11-11-2016 a las 23:00:33
-- Versión del servidor: 10.1.16-MariaDB
-- Versión de PHP: 5.6.24

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `dblaravel`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `pa_seg_breadcrums` (`parIdMenuSistema` INTEGER)  BEGIN

	declare vIdPadre integer;
    declare pista varchar(900);
    
    
    set vIdPadre = (select IdPadre from MenuSistema where IdMenuSistema = parIdMenuSistema);
    
    if vIdPadre is not null then
		set pista = concat('.', parIdMenuSistema, '.');
	end if;
    
    
    while ( vIdPadre is not null) do
    
		set pista = concat('.',vIdPadre,pista);       
        set vIdPadre = (select IdPadre from MenuSistema where IdMenuSistema = vIdPadre);
    
    end while;
    
    
    select pista;
    
    
    

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pa_seg_CambiarClave` (`parInicioSesion` VARCHAR(20), `parClave` VARCHAR(20))  BEGIN

 declare r integer;
 
 set r = 0;

 if(	char_length(parClave) >= 8 
		AND parClave REGEXP BINARY '[A-Z]' 
        AND parClave REGEXP BINARY '[a-z]' 
        AND parClave REGEXP BINARY '[0-9]'
	) then
	
    UPDATE Usuario 
		SET Clave = aes_encrypt(parClave, 'llave') 
	WHERE 
		InicioSesion = parInicioSesion;
    set r = 1;    
end if;
    
    select r;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pa_seg_CargarMenuPerfil` (`parIdPerfil` VARCHAR(20))  BEGIN

	select * 
    from MenuSistema 
    where IdMenuSistema in (
								select IdMenuSistema 
								from PerfilDetalle 
                                where IdPerfil = parIdPerfil
							)
         or 
         
		 IdMenuSistema	in	(	select		IdPadre 	
								from		PerfilDetalle a
								inner join MenuSistema b on a.IdMenuSistema = b.MenuSistema
								where		a.IdPerfil = parIdPerfil									
							)	
         
		;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pa_seg_CargarPerfiles` (`parInicioSesion` VARCHAR(20))  BEGIN
	select * 
    from perfil
    where IdPerfil in (
						select a.IdPerfil 
						from UsuarioPerfil a
                        left join Usuario b on a.IdUsuario = b.IdUsuario
                        where b.InicioSesion = parInicioSesion		
						) ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pa_seg_EvaluarCuenta` (`parInicioSesion` VARCHAR(20))  BEGIN

	select count(*) as CuentaValida from usuario where InicioSesion=parInicioSesion;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pa_seg_VerificarClave` (`parInicioSesion` VARCHAR(20), `parClave` VARCHAR(20))  BEGIN


	select count(*) as CuentaValida 
    from usuario 
    where InicioSesion = parInicioSesion
			and AES_DECRYPT(Clave,'llave') = parClave;
            

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `menusistema`
--

CREATE TABLE `menusistema` (
  `IdMenuSistema` int(11) NOT NULL,
  `Titulo` varchar(100) NOT NULL,
  `Descripcion` varchar(500) DEFAULT NULL,
  `Url` varchar(250) NOT NULL,
  `Icono` varchar(250) DEFAULT NULL,
  `IdPadre` int(11) DEFAULT NULL,
  `Nivel` int(11) NOT NULL,
  `Jerarquia` varchar(500) NOT NULL,
  `Activo` bit(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `menusistema`
--

INSERT INTO `menusistema` (`IdMenuSistema`, `Titulo`, `Descripcion`, `Url`, `Icono`, `IdPadre`, `Nivel`, `Jerarquia`, `Activo`) VALUES
(1, 'Catálogos', 'Catalogos', '#', '#', NULL, 0, '.1.', b'1'),
(2, 'Productos', 'Productos', '#', '#', 1, 1, '.1.2.', b'1'),
(3, 'Intangibles', 'Intangibles', '#', '#', 2, 2, '.1.2.3.', b'1'),
(4, 'Software', 'Software', '#', '#', 1, 3, '.1.2.3.4.', b'1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2014_10_12_000000_create_users_table', 1),
(2, '2014_10_12_100000_create_password_resets_table', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfil`
--

CREATE TABLE `perfil` (
  `IdPerfil` varchar(20) NOT NULL,
  `Nombre` varchar(50) DEFAULT NULL,
  `Descripcion` varchar(500) DEFAULT NULL,
  `Activo` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `perfil`
--

INSERT INTO `perfil` (`IdPerfil`, `Nombre`, `Descripcion`, `Activo`) VALUES
('admon', 'admon', 'Administración', b'1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfildetalle`
--

CREATE TABLE `perfildetalle` (
  `IdPerfil` varchar(20) NOT NULL,
  `IdMenuSistema` int(11) NOT NULL,
  `Activo` bit(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `perfildetalle`
--

INSERT INTO `perfildetalle` (`IdPerfil`, `IdMenuSistema`, `Activo`) VALUES
('admon', 4, b'1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Elmer Merlos Jr.', 'emerlosjr@gmail.com', '$2y$10$KGyuQOlQH0/GoVCCmbxPv.8Jz/qD0qJjPd8WBAAidji6w7vxoEp66', 'yvMBxIW3aRbqRJ3ClFqGiviKfImnjNB2uP6iQdj9ITzWq3dgmxJBV04iqrMU', '2016-11-11 21:20:20', '2016-11-12 03:54:28'),
(2, 'Administrador', 'admin@gmail.com', '$2y$10$SYG78QsLxl.29huNAKS7pOrnCQwFQq6pwZvsiYzCj7jm8P8Zctuua', 'V4btrWuzEbdogc5tJtXDulDeva5J2ARKr3C9VP7V62C3BwXaUB6mYn3XtQg3', '2016-11-12 00:33:40', '2016-11-12 00:34:14');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `IdUsuario` int(11) NOT NULL,
  `Nombres` varchar(100) DEFAULT NULL,
  `Apellidos` varchar(100) DEFAULT NULL,
  `InicioSesion` varchar(20) DEFAULT NULL,
  `Correo` varchar(200) DEFAULT NULL,
  `Activo` tinyint(4) DEFAULT NULL,
  `Clave` blob
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`IdUsuario`, `Nombres`, `Apellidos`, `InicioSesion`, `Correo`, `Activo`, `Clave`) VALUES
(1, 'Edwin', 'Paredes', 'erolandopc', 'erolandopc@gmail.com', 1, 0x07a5d8a7c55927581c91a180fd0618f9);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarioperfil`
--

CREATE TABLE `usuarioperfil` (
  `IdUsuario` int(11) NOT NULL,
  `IdPerfil` varchar(20) NOT NULL,
  `Activo` bit(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `menusistema`
--
ALTER TABLE `menusistema`
  ADD PRIMARY KEY (`IdMenuSistema`);

--
-- Indices de la tabla `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `password_resets`
--
ALTER TABLE `password_resets`
  ADD KEY `password_resets_email_index` (`email`),
  ADD KEY `password_resets_token_index` (`token`);

--
-- Indices de la tabla `perfil`
--
ALTER TABLE `perfil`
  ADD PRIMARY KEY (`IdPerfil`);

--
-- Indices de la tabla `perfildetalle`
--
ALTER TABLE `perfildetalle`
  ADD PRIMARY KEY (`IdPerfil`,`IdMenuSistema`),
  ADD KEY `fk_PerfilDetalle_Perfil1_idx` (`IdPerfil`),
  ADD KEY `fk_PerfilDetalle_MenuSistema1_idx` (`IdMenuSistema`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`IdUsuario`);

--
-- Indices de la tabla `usuarioperfil`
--
ALTER TABLE `usuarioperfil`
  ADD PRIMARY KEY (`IdUsuario`,`IdPerfil`),
  ADD KEY `fk_UsuarioPerfil_Perfil1_idx` (`IdPerfil`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `menusistema`
--
ALTER TABLE `menusistema`
  MODIFY `IdMenuSistema` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `IdUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `usuarioperfil`
--
ALTER TABLE `usuarioperfil`
  MODIFY `IdUsuario` int(11) NOT NULL AUTO_INCREMENT;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `perfildetalle`
--
ALTER TABLE `perfildetalle`
  ADD CONSTRAINT `fk_PerfilDetalle_MenuSistema1` FOREIGN KEY (`IdMenuSistema`) REFERENCES `menusistema` (`IdMenuSistema`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_PerfilDetalle_Perfil1` FOREIGN KEY (`IdPerfil`) REFERENCES `perfil` (`IdPerfil`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `usuarioperfil`
--
ALTER TABLE `usuarioperfil`
  ADD CONSTRAINT `fk_UsuarioPerfil_Perfil1` FOREIGN KEY (`IdPerfil`) REFERENCES `perfil` (`IdPerfil`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_UsuarioPerfil_Usuario` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
