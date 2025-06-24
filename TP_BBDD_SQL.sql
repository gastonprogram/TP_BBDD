
CREATE DATABASE SISTEMA_PROPIEDADES_BD;
GO

USE SISTEMA_PROPIEDADES_BD;
GO

-- 1. Tablas base
CREATE TABLE DIRECCION (
    ID_direccion INT PRIMARY KEY IDENTITY(1,1),
    Calle VARCHAR(100),
    Numero VARCHAR(10),
    Barrio VARCHAR(100),
    Ciudad VARCHAR(100),
    Provincia VARCHAR(100),
    Codigo_postal VARCHAR(20),
    Piso VARCHAR(10),
    Departamento VARCHAR(10),
    Observaciones TEXT
);

CREATE TABLE PROPIETARIO (
    ID_propietario INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    Telefono VARCHAR(100),
    Fecha_registro DATE,
    Fecha_nacimiento DATE,
    Estado BIT, 
    Cuit VARCHAR(100)
);

CREATE TABLE PROPIEDAD (
    ID_propiedad INT PRIMARY KEY IDENTITY(1,1),
    Descripcion TEXT,
    ID_direccion INT,
    Valor_usd FLOAT,
    Metros_cuadrados INT,
    Cantidad_ambientes INT,
    Fecha_contruccion DATE,
    Tipo VARCHAR(100),
    ID_propietario INT,
    FOREIGN KEY (ID_direccion) REFERENCES DIRECCION(ID_direccion),
    FOREIGN KEY (ID_propietario) REFERENCES PROPIETARIO(ID_propietario)
);

CREATE TABLE CLIENTE (
    ID_cliente INT PRIMARY KEY IDENTITY(1,1),
    DNI VARCHAR(100),
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    Estado BIT,
    Fecha_nacimiento DATE,
    Fecha_registro DATE,
    Telefono VARCHAR(100)
);

CREATE TABLE AGENTES_INMOBILIARIO (
    ID_agente INT PRIMARY KEY IDENTITY(1,1),
    DNI VARCHAR(100),
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    Telefono VARCHAR(100),
    Comision VARCHAR(100),
    Fecha_nacimiento DATE,
    Fecha_registro DATE,
    Estado BIT
);

-- CONTRATO con FK a propiedad, cliente y agente
CREATE TABLE CONTRATO (
    ID_contrato INT PRIMARY KEY IDENTITY(1,1),
    Condiciones TEXT,
    Precio_final FLOAT,
    Fecha DATE,
    Forma_pago VARCHAR(100),
    ID_propiedad INT,
    ID_cliente INT,
    ID_agente INT,
    FOREIGN KEY (ID_propiedad) REFERENCES PROPIEDAD(ID_propiedad),
    FOREIGN KEY (ID_cliente) REFERENCES CLIENTE(ID_cliente),
    FOREIGN KEY (ID_agente) REFERENCES AGENTES_INMOBILIARIO(ID_agente)
);

CREATE TABLE PAGO (
    ID_pago INT PRIMARY KEY IDENTITY(1,1),
    Fecha_pago DATE,
    Monto FLOAT,
    Metodo_pago VARCHAR(100),
    Descripcion VARCHAR(200),
    Estado_pago BIT,  -- 1: pagado, 0: pendiente
    ID_contrato INT,
    FOREIGN KEY (ID_contrato) REFERENCES CONTRATO(ID_contrato)
);


CREATE TABLE VISITA (
    ID_visita INT PRIMARY KEY IDENTITY(1,1),
    Fecha_visita DATE,
    Comentarios TEXT,
    Estado BIT,  -- 1: realizada, 0: pendiente
    ID_propiedad INT,
    FOREIGN KEY (ID_propiedad) REFERENCES PROPIEDAD(ID_propiedad)
);


-----PROCEDIMIENTOS ALMACENADO DE INGRESO DE DATOS--------------------------------------------------------------------------------------------

-- direccion
GO
CREATE PROCEDURE sp_InsertarDireccion
    @Calle VARCHAR(100),
    @Numero VARCHAR(10),
    @Barrio VARCHAR(100),
    @Ciudad VARCHAR(100),
    @Provincia VARCHAR(100),
    @Codigo_postal VARCHAR(20),
    @Piso VARCHAR(10),
    @Departamento VARCHAR(10),
    @Observaciones TEXT
AS
BEGIN
    BEGIN TRY
        INSERT INTO DIRECCION (Calle, Numero, Barrio, Ciudad, Provincia, Codigo_postal, Piso, Departamento, Observaciones)
        VALUES (@Calle, @Numero, @Barrio, @Ciudad, @Provincia, @Codigo_postal, @Piso, @Departamento, @Observaciones);

        PRINT 'Dirección insertada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar dirección.';
        PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
        PRINT 'Código de error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


--propietario


GO
CREATE PROCEDURE sp_InsertarPropietario
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @Telefono VARCHAR(100),
    @Fecha_registro DATE,
    @Fecha_nacimiento DATE,
    @Estado BIT,
    @Cuit VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        INSERT INTO PROPIETARIO (Nombre, Apellido, Telefono, Fecha_registro, Fecha_nacimiento, Estado, Cuit)
        VALUES (@Nombre, @Apellido, @Telefono, @Fecha_registro, @Fecha_nacimiento, @Estado, @Cuit);

        PRINT 'Propietario insertado exitosamente.';
    END TRY
    BEGIN CATCH 
        PRINT 'Error al insertar propietario.';
        PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
        PRINT 'Código de error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END

-- propiedad

GO
CREATE PROCEDURE sp_InsertarPropiedad
    @Descripcion TEXT,
    @ID_direccion INT,
    @Valor_usd FLOAT,
    @Metros_cuadrados INT,
    @Cantidad_ambientes INT,
    @Fecha_contruccion DATE,
    @Tipo VARCHAR(100),
    @ID_propietario INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO PROPIEDAD (Descripcion, ID_direccion, Valor_usd, Metros_cuadrados, Cantidad_ambientes, Fecha_contruccion, Tipo, ID_propietario)
        VALUES (@Descripcion, @ID_direccion, @Valor_usd, @Metros_cuadrados, @Cantidad_ambientes, @Fecha_contruccion, @Tipo, @ID_propietario);

        PRINT 'Propiedad insertada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar propiedad.';
        PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
        PRINT 'Código de error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END

-- cliente

GO
CREATE PROCEDURE sp_InsertarCliente
    @DNI VARCHAR(100),
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @Estado BIT,
    @Fecha_nacimiento DATE,
    @Fecha_registro DATE,
    @Telefono VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        INSERT INTO CLIENTE (DNI, Nombre, Apellido, Estado, Fecha_nacimiento, Fecha_registro, Telefono)
        VALUES (@DNI, @Nombre, @Apellido, @Estado, @Fecha_nacimiento, @Fecha_registro, @Telefono);

        PRINT 'Cliente insertado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar cliente.';
        PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
        PRINT 'Código de error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END



-- agente


GO
CREATE PROCEDURE sp_InsertarAgente
    @DNI VARCHAR(100),
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @Telefono VARCHAR(100),
    @Comision VARCHAR(100),
    @Fecha_nacimiento DATE,
    @Fecha_registro DATE,
    @Estado BIT
AS
BEGIN
    BEGIN TRY
        INSERT INTO AGENTES_INMOBILIARIO (DNI, Nombre, Apellido, Telefono, Comision, Fecha_nacimiento, Fecha_registro, Estado)
        VALUES (@DNI, @Nombre, @Apellido, @Telefono, @Comision, @Fecha_nacimiento, @Fecha_registro, @Estado);

        PRINT 'Agente insertado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar agente.';
        PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
        PRINT 'Código de error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END

-- contrato


GO
CREATE PROCEDURE sp_InsertarContrato
    @Condiciones TEXT,
    @Precio_final FLOAT,
    @Fecha DATE,
    @Forma_pago VARCHAR(100),
    @ID_propiedad INT,
    @ID_cliente INT,
    @ID_agente INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO CONTRATO (Condiciones, Precio_final, Fecha, Forma_pago, ID_propiedad, ID_cliente, ID_agente)
        VALUES (@Condiciones, @Precio_final, @Fecha, @Forma_pago, @ID_propiedad, @ID_cliente, @ID_agente);

        PRINT 'Contrato insertado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar contrato.';
        PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
        PRINT 'Código de error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END

-- pagos

GO
CREATE PROCEDURE sp_InsertarPago
    @Fecha_pago DATE,
    @Monto FLOAT,
    @Metodo_pago VARCHAR(100),
    @Descripcion VARCHAR(200),
    @Estado_pago BIT,
    @ID_contrato INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO PAGOS (Fecha_pago, Monto, Metodo_pago, Descripcion, Estado_pago, ID_contrato)
        VALUES (@Fecha_pago, @Monto, @Metodo_pago, @Descripcion, @Estado_pago, @ID_contrato);

        PRINT 'Pago insertado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar pago.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


-- visita


GO
CREATE PROCEDURE sp_InsertarVisita
    @Fecha_visita DATE,
    @Comentarios TEXT,
    @Estado BIT,
    @ID_propiedad INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO VISITA (Fecha_visita, Comentarios, Estado, ID_propiedad)
        VALUES (@Fecha_visita, @Comentarios, @Estado, @ID_propiedad);

        PRINT 'Visita insertada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar visita.';
        PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
        PRINT 'Código de error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END



----- procedimientos de edicion -------------------------


-- direccion

GO
CREATE PROCEDURE sp_EditarDireccion
    @ID_direccion INT,
    @Calle VARCHAR(100),
    @Numero VARCHAR(10),
    @Barrio VARCHAR(100),
    @Ciudad VARCHAR(100),
    @Provincia VARCHAR(100),
    @Codigo_postal VARCHAR(20),
    @Piso VARCHAR(10),
    @Departamento VARCHAR(10),
    @Observaciones TEXT
AS
BEGIN
    BEGIN TRY
        UPDATE DIRECCION
        SET Calle = @Calle,
            Numero = @Numero,
            Barrio = @Barrio,
            Ciudad = @Ciudad,
            Provincia = @Provincia,
            Codigo_postal = @Codigo_postal,
            Piso = @Piso,
            Departamento = @Departamento,
            Observaciones = @Observaciones
        WHERE ID_direccion = @ID_direccion;

        PRINT 'Dirección actualizada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar dirección.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


-- propietario

GO
CREATE PROCEDURE sp_EditarPropietario
    @ID_propietario INT,
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @Telefono VARCHAR(100),
    @Fecha_registro DATE,
    @Fecha_nacimiento DATE,
    @Estado BIT,
    @Cuit VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        UPDATE PROPIETARIO
        SET Nombre = @Nombre,
            Apellido = @Apellido,
            Telefono = @Telefono,
            Fecha_registro = @Fecha_registro,
            Fecha_nacimiento = @Fecha_nacimiento,
            Estado = @Estado,
            Cuit = @Cuit
        WHERE ID_propietario = @ID_propietario;

        PRINT 'Propietario actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar propietario.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


-- propiedad

GO
CREATE PROCEDURE sp_EditarPropiedad
    @ID_propiedad INT,
    @Descripcion TEXT,
    @ID_direccion INT,
    @Valor_usd FLOAT,
    @Metros_cuadrados INT,
    @Cantidad_ambientes INT,
    @Fecha_contruccion DATE,
    @Tipo VARCHAR(100),
    @ID_propietario INT
AS
BEGIN
    BEGIN TRY
        UPDATE PROPIEDAD
        SET Descripcion = @Descripcion,
            ID_direccion = @ID_direccion,
            Valor_usd = @Valor_usd,
            Metros_cuadrados = @Metros_cuadrados,
            Cantidad_ambientes = @Cantidad_ambientes,
            Fecha_contruccion = @Fecha_contruccion,
            Tipo = @Tipo,
            ID_propietario = @ID_propietario
        WHERE ID_propiedad = @ID_propiedad;

        PRINT 'Propiedad actualizada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar propiedad.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END

-- cliente

GO
CREATE PROCEDURE sp_EditarCliente
    @ID_cliente INT,
    @DNI VARCHAR(100),
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @Estado BIT,
    @Fecha_nacimiento DATE,
    @Fecha_registro DATE,
    @Telefono VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        UPDATE CLIENTE
        SET DNI = @DNI,
            Nombre = @Nombre,
            Apellido = @Apellido,
            Estado = @Estado,
            Fecha_nacimiento = @Fecha_nacimiento,
            Fecha_registro = @Fecha_registro,
            Telefono = @Telefono
        WHERE ID_cliente = @ID_cliente;

        PRINT 'Cliente actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar cliente.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END



-- agente

GO
CREATE PROCEDURE sp_EditarAgente
    @ID_agente INT,
    @DNI VARCHAR(100),
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @Telefono VARCHAR(100),
    @Comision VARCHAR(100),
    @Fecha_nacimiento DATE,
    @Fecha_registro DATE,
    @Estado BIT
AS
BEGIN
    BEGIN TRY
        UPDATE AGENTES_INMOBILIARIO
        SET DNI = @DNI,
            Nombre = @Nombre,
            Apellido = @Apellido,
            Telefono = @Telefono,
            Comision = @Comision,
            Fecha_nacimiento = @Fecha_nacimiento,
            Fecha_registro = @Fecha_registro,
            Estado = @Estado
        WHERE ID_agente = @ID_agente;

        PRINT 'Agente actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar agente.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


-- contrato


GO
CREATE PROCEDURE sp_EditarContrato
    @ID_contrato INT,
    @Condiciones TEXT,
    @Precio_final FLOAT,
    @Fecha DATE,
    @Forma_pago VARCHAR(100),
    @ID_propiedad INT,
    @ID_cliente INT,
    @ID_agente INT
AS
BEGIN
    BEGIN TRY
        UPDATE CONTRATO
        SET Condiciones = @Condiciones,
            Precio_final = @Precio_final,
            Fecha = @Fecha,
            Forma_pago = @Forma_pago,
            ID_propiedad = @ID_propiedad,
            ID_cliente = @ID_cliente,
            ID_agente = @ID_agente
        WHERE ID_contrato = @ID_contrato;

        PRINT 'Contrato actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar contrato.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END



-- pago

GO
CREATE PROCEDURE sp_EditarPago
    @ID_pago INT,
    @Fecha_pago DATE,
    @Monto FLOAT,
    @Metodo_pago VARCHAR(100),
    @Descripcion VARCHAR(200),
    @Estado_pago BIT,
    @ID_contrato INT
AS
BEGIN
    BEGIN TRY
        UPDATE PAGO
        SET Fecha_pago = @Fecha_pago,
            Monto = @Monto,
            Metodo_pago = @Metodo_pago,
            Descripcion = @Descripcion,
            Estado_pago = @Estado_pago,
            ID_contrato = @ID_contrato
        WHERE ID_pago = @ID_pago;

        PRINT 'Pago actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar pago.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END



-- visita

GO
CREATE PROCEDURE sp_EditarVisita
    @ID_visita INT,
    @Fecha_visita DATE,
    @Comentarios TEXT,
    @Estado BIT,
    @ID_propiedad INT
AS
BEGIN
    BEGIN TRY
        UPDATE VISITA
        SET Fecha_visita = @Fecha_visita,
            Comentarios = @Comentarios,
            Estado = @Estado,
            ID_propiedad = @ID_propiedad
        WHERE ID_visita = @ID_visita;

        PRINT 'Visita actualizada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar visita.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


--------------------------   Procedimientos de eliminacion    ------------------------------------------------------------------------------------

-- direccion

GO
CREATE PROCEDURE sp_EliminarDireccion
    @ID_direccion INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM DIRECCION
        WHERE ID_direccion = @ID_direccion;

        PRINT 'Dirección eliminada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar dirección.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


-- propietario

GO
CREATE PROCEDURE sp_EliminarPropietario
    @ID_propietario INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM PROPIETARIO
        WHERE ID_propietario = @ID_propietario;

        PRINT 'Propietario eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar propietario.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


-- propiedad


GO
CREATE PROCEDURE sp_EliminarPropiedad
    @ID_propiedad INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM PROPIEDAD
        WHERE ID_propiedad = @ID_propiedad;

        PRINT 'Propiedad eliminada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar propiedad.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


-- cliente

GO
CREATE PROCEDURE sp_EliminarCliente
    @ID_cliente INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM CLIENTE
        WHERE ID_cliente = @ID_cliente;

        PRINT 'Cliente eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar cliente.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


-- agente

GO
CREATE PROCEDURE sp_EliminarAgente
    @ID_agente INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM AGENTES_INMOBILIARIO
        WHERE ID_agente = @ID_agente;

        PRINT 'Agente eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar agente.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


-- contrato

GO
CREATE PROCEDURE sp_EliminarContrato
    @ID_contrato INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM CONTRATO
        WHERE ID_contrato = @ID_contrato;

        PRINT 'Contrato eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar contrato.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


-- pago

GO
CREATE PROCEDURE sp_EliminarPago
    @ID_pago INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM PAGO
        WHERE ID_pago = @ID_pago;

        PRINT 'Pago eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar pago.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END


-- visita


GO
CREATE PROCEDURE sp_EliminarVisita
    @ID_visita INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM VISITA
        WHERE ID_visita = @ID_visita;

        PRINT 'Visita eliminada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar visita.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END






------
--
--
--
--
---
--
--
---
--
---
---



---------------------- esto hay que corregir ------------------------------------


-------------- Ingresar los datos con los procedimientos almacenados ------------------------------------------------------------------------------------------------------------


--1 Primero inserto el contrato 
EXEC INGRESO_CONTRATOS
    @Condiciones = 'Contrato por 12 meses, incluye mantenimiento',
    @Precio_final = 150000,
    @Fecha = '2025-06-10',
    @Forma_pago = 'Transferencia';


	
--2 Ingreso una propiedad
EXEC INGRESO_PROPIEDADES 
	@Descripcion = 'Piso completo con gran vista a la 9 de julio',
	@Direccion = 'Indepencia y Lima ',
	@Valor_usd = 600000,
	@Metros_cuadrados = 500,
	@Cantidad_ambientes= 5,
	@Fecha_contruccion = '2019-06-13',
	@Tipo = 'Departamento',
	@ID_contrato = 1;

--3 Ingreso de propietarios
EXEC INGRESO_PROPIETARIOS
		@Nombre= 'Juan',
		@Apellido = 'Scotti',
		@Telefono = '11 2030-0522', 
		@Fecha_registro ='2012-04-22',
		@Fecha_nacimiento= '2005-06-11',
		@Estado= 1,
		@Cuit ='20-32895712-5',
		@ID_propiedad =1;


--4 Ingreso de Agente inmobiliario 
EXEC INGRESO_AGENTES 
    @DNI = '28934765',
    @Nombre = 'Carlos',
    @Apellido = 'Mendoza',
    @Telefono = '11-3344-5566',
    @Comision = '5%',
    @Fecha_nacimiento = '1990-08-15',
    @Fecha_registro = '2023-06-01',
    @Estado = 1,
    @ID_contrato = 1;



--5 Ingreso de cliente 
	EXEC INGRESO_CIENTES
    @DNI = '12345678',
    @Nombre = 'Laura',
    @Apellido = 'Pérez',
    @Estado = 1,
    @Fecha_nacimiento = '1990-08-15',
    @Fecha_registro = '2025-06-12',
    @Telefono = '1123456789',
    @ID_contrato = 1;


----VISTAS--------------------------------------------------------------------------------------------------------------------------------
--1 
CREATE VIEW VISTA_DEPARTAMENTOS_VALOR_MAS_500000 AS
	SELECT * FROM PROPIEDADES WHERE Valor_usd>500000;


			---Ejecuto---

SELECT * FROM VISTA_DEPARTAMENTOS_VALOR_MAS_500000;


---2

CREATE VIEW VISTA_DEPTOS_MENORES_250000
AS
    Select * from PROPIEDADES WHERE Valor_usd <250000;

			---Ejecuto---

SELECT * FROM VISTA_DEPTOS_MENORES_250000;



---- vista de informacion relevante de una propiedad

CREATE VIEW vw_PropiedadesDetalladas AS
SELECT 
    p.ID_propiedad,
    p.Descripcion,
    p.Valor_usd,
    p.Metros_cuadrados,
    p.Cantidad_ambientes,
    p.Fecha_contruccion,
    p.Tipo,
    pr.Nombre + ' ' + pr.Apellido AS Propietario,
    d.Calle + ' ' + d.Numero + ', ' + d.Barrio + ', ' + d.Ciudad AS Direccion
FROM PROPIEDAD p
JOIN PROPIETARIO pr ON p.ID_propietario = pr.ID_propietario
JOIN DIRECCION d ON p.ID_direccion = d.ID_direccion;

----- vista de contratos completos

CREATE VIEW vw_ContratosCompletos AS
SELECT 
    c.ID_contrato,
    c.Fecha,
    c.Forma_pago,
    c.Precio_final,
    c.Condiciones,
    cl.Nombre + ' ' + cl.Apellido AS Cliente,
    a.Nombre + ' ' + a.Apellido AS Agente,
    p.Descripcion AS Propiedad
FROM CONTRATO c
JOIN CLIENTE cl ON c.ID_cliente = cl.ID_cliente
JOIN AGENTES_INMOBILIARIO a ON c.ID_agente = a.ID_agente
JOIN PROPIEDAD p ON c.ID_propiedad = p.ID_propiedad;


----- vistas de visitas pendientes

CREATE VIEW vw_VisitasPendientes AS
SELECT 
    v.ID_visita,
    v.Fecha_visita,
    v.Comentarios,
    p.Descripcion AS Propiedad,
    d.Calle + ' ' + d.Numero + ', ' + d.Barrio + ', ' + d.Ciudad AS Direccion
FROM VISITA v
JOIN PROPIEDAD p ON v.ID_propiedad = p.ID_propiedad
JOIN DIRECCION d ON p.ID_direccion = d.ID_direccion
WHERE v.Estado = 0; -- pendientes





----READ---


SELECT * FROM PROPIEDADES WHERE Fecha_contruccion>'2020-01-01';

SELECT Nombre, Apellido COUNT (ID_PROPIETARIO) AS Cantidad_propiedades FROM PROPIETARIOS GROUP BY Nombre, Apellido;

SELECT Nombre,Apellido FROM CLIENTE WHERE Nombre LIKE 'L%' or Apellido LIKE '%o';

SELECT ID_cliente, Nombre, Apellido FROM CLIENTE WHERE Telefono IS NULL;

SELECT  * FROM PROPIEDADES WHERE Fecha_contruccion<'2019-31-12';

SELECT * FROM VISITAS WHERE Fecha_visita >= DATEADD(DAY, -7, GETDATE());

SELECT ID_CLIENTE, Nombre, Apellido, Fecha_registro FROM CLIENTE WHERE Fecha_registro >= DATEADD(MONTH, -1, GETDATE());

SELECT ID_agente, Nombre, Apellido, Comision FROM AGENTES_INMOBILIARIOS WHERE Estado = 1 AND Comision IS NOT NULL;

SELECT ID_propietario, Nombre, Apellido, Cuit FROM PROPIETARIOS WHERE Cuit IS NOT NULL AND Estado = 1;

SELECT ID_CLIENTE, Nombre, Apellido FROM CLIENTE WHERE Telefono IS NULL OR Telefono = '';

SELECT ID_pago, Fecha_pago, Monto, Metodo_pago FROM PAGOS WHERE Estado_pago = 0;

SELECT 
    D.Barrio AS Barrio_o_Zona,
    COUNT(P.ID_contrato) AS Cantidad_Contratos
FROM PROPIEDADES P
INNER JOIN DIRECCION D ON P.ID_direccion = D.ID_direccion
WHERE P.ID_contrato IS NOT NULL
GROUP BY D.Barrio
ORDER BY Cantidad_Contratos DESC;


---TRIGGERS---------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER TR_CrearPago_Auto
ON CONTRATO
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO PAGO (Fecha_pago, Monto, Metodo_pago, Descripcion, Estado_pago)
    SELECT 
        GETDATE(),                      -- Fecha actual como fecha de pago
        i.Precio_final,                -- Monto desde el contrato
        'Transferencia',              -- Método por defecto (puedes cambiarlo)
        CONCAT('Pago inicial para contrato ID: ', i.ID_contrato),  -- Descripción
        0                              -- Estado: 0 = Pendiente
    FROM inserted i;
END;


CREATE TRIGGER TR_Agregar_Fecha_Registro_Cliente
ON CLIENTE
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE C
    SET Fecha_registro = GETDATE()
    FROM CLIENTE C
    INNER JOIN inserted i ON C.ID_CLIENTE = i.ID_CLIENTE
    WHERE i.Fecha_registro IS NULL;
END;

----- verificar que no se superponga ----------------------------
CREATE TRIGGER trg_VisitaUnicaPorDia
ON VISITA
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM VISITA v
        JOIN inserted i ON v.ID_propiedad = i.ID_propiedad AND v.Fecha_visita = i.Fecha_visita
    )
    BEGIN
        RAISERROR('Ya existe una visita programada para esta propiedad en esa fecha.', 16, 1);
        RETURN;
    END

    INSERT INTO VISITA (Fecha_visita, Comentarios, Estado, ID_propiedad)
    SELECT Fecha_visita, Comentarios, Estado, ID_propiedad
    FROM inserted;
END


---AGREGACION Y AGRUPAMIENTO---
SELECT COUNT(*) FROM PROPIEDADES;

SELECT AVG(Valor_usd)FROM PROPIEDADES;

SELECT MIN(Valor_usd) FROM PROPIEDADES;

SELECT MAX(Valor_usd) FROM PROPIEDADES;





----FUNCION -------------------------------------------------------------------------------------
GO
CREATE FUNCTION fn_BarriosMayorPrecioMetroCuadrado()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        D.Barrio,
        AVG(CAST(P.Valor_usd AS FLOAT) / NULLIF(P.Metros_cuadrados, 0)) AS Precio_Promedio_Metro_Cuadrado
    FROM PROPIEDAD P
    INNER JOIN DIRECCION D ON P.ID_direccion = D.ID_direccion
    WHERE P.Metros_cuadrados > 0
    GROUP BY D.Barrio
    ORDER BY Precio_Promedio_Metro_Cuadrado DESC
);
