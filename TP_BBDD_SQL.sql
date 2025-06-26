
CREATE DATABASE SISTEMA_PROPIEDADES_BD;
GO

USE SISTEMA_PROPIEDADES_BD;
GO

CREATE DATABASE SISTEMA__BD;
GO

USE SISTEMA__BD;
GO

-- 1. Tablas base


CREATE TABLE DIRECCION (
    ID_direccion INT CONSTRAINT PK_Direccion PRIMARY KEY IDENTITY(1,1),
    Calle VARCHAR(100) NOT NULL,
    Numero VARCHAR(10) NOT NULL,
    Barrio VARCHAR(100),
    Ciudad VARCHAR(100) NOT NULL,
    Provincia VARCHAR(100) NOT NULL,
    Codigo_postal VARCHAR(20),
    Piso VARCHAR(10),
    Departamento VARCHAR(10),
    Observaciones TEXT
);

GO

CREATE TABLE PROPIETARIO (
    ID_propietario INT CONSTRAINT PK_Propietario PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Telefono VARCHAR(100) NOT NULL,
    Fecha_registro DATE,
    Fecha_nacimiento DATE,
    Estado BIT,
    Cuit VARCHAR(100) NOT NULL,
    CONSTRAINT CK_FechaNacimiento_Propietario CHECK (Fecha_nacimiento <= GETDATE()),
    CONSTRAINT CK_Estado_Propietario CHECK (Estado IN (0,1))
);
GO

CREATE TABLE PROPIEDAD (
    ID_propiedad INT CONSTRAINT PK_Propiedad PRIMARY KEY IDENTITY(1,1),
    Descripcion TEXT,
    ID_direccion INT,
    Valor_usd FLOAT,
    Metros_cuadrados INT,
    Cantidad_ambientes INT,
    Fecha_contruccion DATE,
    Tipo VARCHAR(100) NOT NULL,
    ID_propietario INT,
    CONSTRAINT FK_Propiedad_Direccion FOREIGN KEY (ID_direccion) REFERENCES DIRECCION(ID_direccion),
    CONSTRAINT FK_Propiedad_Propietario FOREIGN KEY (ID_propietario) REFERENCES PROPIETARIO(ID_propietario),
    CONSTRAINT CK_Valor_Propiedad CHECK (Valor_usd >= 0),
    CONSTRAINT CK_Metros_Propiedad CHECK (Metros_cuadrados > 0),
    CONSTRAINT CK_Ambientes_Propiedad CHECK (Cantidad_ambientes > 0),
	CONSTRAINT CHK_Propiedad_Tipo CHECK (Tipo IN ('Casa', 'PH', 'Departamento')),
);
GO

CREATE TABLE CLIENTE (
    ID_cliente INT CONSTRAINT PK_Cliente PRIMARY KEY IDENTITY(1,1),
    DNI VARCHAR(100) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Estado BIT,
    Fecha_nacimiento DATE,
    Fecha_registro DATE,
    Telefono VARCHAR(100) NOT NULL,
    CONSTRAINT CK_FechaNacimiento_Cliente CHECK (Fecha_nacimiento <= GETDATE()),
    CONSTRAINT CK_Estado_Cliente CHECK (Estado IN (0,1))
);
GO

CREATE TABLE AGENTE_INMOBILIARIO (
    ID_agente INT CONSTRAINT PK_Agente PRIMARY KEY IDENTITY(1,1),
    DNI VARCHAR(100) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Telefono VARCHAR(100) NOT NULL,
    Comision VARCHAR(100),
    Fecha_nacimiento DATE,
    Fecha_registro DATE,
    Estado BIT,
    CONSTRAINT CK_FechaNacimiento_Agente CHECK (Fecha_nacimiento <= GETDATE()),
    CONSTRAINT CK_Estado_Agente CHECK (Estado IN (0,1))
);
GO

CREATE TABLE CONTRATO (
    ID_contrato INT CONSTRAINT PK_Contrato PRIMARY KEY IDENTITY(1,1),
    Condiciones TEXT,
    Precio_final FLOAT,
    Fecha DATE NOT NULL,
    Forma_pago VARCHAR(100) NOT NULL,
    ID_propiedad INT,
    ID_cliente INT,
    ID_agente INT,
    CONSTRAINT FK_Contrato_Propiedad FOREIGN KEY (ID_propiedad) REFERENCES PROPIEDAD(ID_propiedad),
    CONSTRAINT FK_Contrato_Cliente FOREIGN KEY (ID_cliente) REFERENCES CLIENTE(ID_cliente),
    CONSTRAINT FK_Contrato_Agente FOREIGN KEY (ID_agente) REFERENCES AGENTE_INMOBILIARIO(ID_agente),
    CONSTRAINT CK_Precio_Contrato CHECK (Precio_final >= 0)
);
GO

CREATE TABLE PAGO (
    ID_pago INT CONSTRAINT PK_Pago PRIMARY KEY IDENTITY(1,1),
    Fecha_pago DATE,
    Monto FLOAT,
    Metodo_pago VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(200),
    Estado_pago BIT, -------- 0: pendiente 1: ya realizado 
    ID_contrato INT,
    CONSTRAINT FK_Pago_Contrato FOREIGN KEY (ID_contrato) REFERENCES CONTRATO(ID_contrato),
    CONSTRAINT CK_Monto_Pago CHECK (Monto >= 0),
    CONSTRAINT CK_Estado_Pago CHECK (Estado_pago IN (0,1))
);
GO

CREATE TABLE VISITA (
    ID_visita INT CONSTRAINT PK_Visita PRIMARY KEY IDENTITY(1,1),
    Fecha_visita DATE NOT NULL,
    Comentarios TEXT,
    Estado BIT,   ----- 0: pendiente 1: ya hecha
    ID_propiedad INT,
    CONSTRAINT FK_Visita_Propiedad FOREIGN KEY (ID_propiedad) REFERENCES PROPIEDAD(ID_propiedad),
    CONSTRAINT CK_Estado_Visita CHECK (Estado IN (0,1))
);
GO



-----PROCEDIMIENTOS ALMACENADO DE INGRESO DE DATOS--------------------------------------------------------------------------------------------

-- direccion
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
GO

--propietario


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
GO
-- propiedad

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
GO
-- cliente

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
GO


-- agente


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
        INSERT INTO AGENTE_INMOBILIARIO (DNI, Nombre, Apellido, Telefono, Comision, Fecha_nacimiento, Fecha_registro, Estado)
        VALUES (@DNI, @Nombre, @Apellido, @Telefono, @Comision, @Fecha_nacimiento, @Fecha_registro, @Estado);

        PRINT 'Agente insertado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar agente.';
        PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
        PRINT 'Código de error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END
GO
-- contrato


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
GO
-- pagos

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
        INSERT INTO PAGO (Fecha_pago, Monto, Metodo_pago, Descripcion, Estado_pago, ID_contrato)
        VALUES (@Fecha_pago, @Monto, @Metodo_pago, @Descripcion, @Estado_pago, @ID_contrato);

        PRINT 'Pago insertado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar pago.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END
GO

-- visita


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
GO


----------------------------------- PROCEDIMIENTOS DE LECTURA DE DATOS -----------------------------------------------------------------------

----direccion-------

CREATE PROCEDURE sp_ListarDirecciones
AS
BEGIN
    BEGIN TRY
        SELECT ID_direccion,
			Calle,
			Numero,
			Barrio,
			Ciudad,
			Provincia,
			Codigo_postal,
			Piso,
			Departamento,
			Observaciones
		FROM DIRECCION;
    END TRY
    BEGIN CATCH
        PRINT 'Error al listar direcciones.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
    END CATCH
END
GO

----- propietarios ---

CREATE PROCEDURE sp_ListarPropietarios
AS
BEGIN
    BEGIN TRY
        SELECT ID_propietario,
            Nombre,
            Apellido,
            Telefono,
            Fecha_registro,
            Fecha_nacimiento,
            Estado,
            Cuit
		FROM PROPIETARIO;
    END TRY
    BEGIN CATCH
        PRINT 'Error al listar propietarios.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
    END CATCH
END
GO


----- propiedad -----
CREATE PROCEDURE sp_ListarPropiedades
AS
BEGIN
    BEGIN TRY
        SELECT ID_propiedad,
            Descripcion,
            ID_direccion,
            Valor_usd,
            Metros_cuadrados,
            Cantidad_ambientes,
            Fecha_contruccion,
            Tipo,
            ID_propietario 
		FROM PROPIEDAD;
    END TRY
    BEGIN CATCH
        PRINT 'Error al listar propiedades.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
    END CATCH
END
GO

------ cliente -----

CREATE PROCEDURE sp_ListarClientes
AS
BEGIN
    BEGIN TRY
        SELECT ID_cliente,
            DNI,
            Nombre,
            Apellido,
            Estado,
            Fecha_nacimiento,
            Fecha_registro,
            Telefono
		FROM CLIENTE;
    END TRY
    BEGIN CATCH
        PRINT 'Error al listar clientes.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
    END CATCH
END
GO


-----agentes -----
CREATE PROCEDURE sp_ListarAgentes
AS
BEGIN
    BEGIN TRY
        SELECT ID_agente,
            DNI,
            Nombre,
            Apellido,
            Telefono,
            Comision,
            Fecha_nacimiento,
            Fecha_registro,
            Estado
		FROM AGENTE_INMOBILIARIO;
    END TRY
    BEGIN CATCH
        PRINT 'Error al listar agentes inmobiliarios.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
    END CATCH
END
GO



-----contrato -------
CREATE PROCEDURE sp_ListarContratos
AS
BEGIN
    BEGIN TRY
        SELECT ID_contrato,
            Condiciones,
            Precio_final,
            Fecha,
            Forma_pago,
            ID_propiedad,
            ID_cliente,
            ID_agente
		FROM CONTRATO;
    END TRY
    BEGIN CATCH
        PRINT 'Error al listar contratos.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
    END CATCH
END
GO


------ pago -----
CREATE PROCEDURE sp_ListarPagos
AS
BEGIN
    BEGIN TRY
        SELECT ID_pago,
            Fecha_pago,
            Monto,
            Metodo_pago,
            Descripcion,
            Estado_pago,
            ID_contrato
		FROM PAGO;
    END TRY
    BEGIN CATCH
        PRINT 'Error al listar pagos.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
    END CATCH
END
GO



----- visita -----
CREATE PROCEDURE sp_ListarVisitas
AS
BEGIN
    BEGIN TRY
        SELECT  ID_visita,
            Fecha_visita,
            Comentarios,
            Estado,
            ID_propiedad 
		FROM VISITA;
    END TRY
    BEGIN CATCH
        PRINT 'Error al listar visitas.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
    END CATCH
END
GO




------------------------------------ PROCEDIMIENTOS DE EDICION DE DATOS ------------------------------------------------------------


-- direccion

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
GO

-- propietario

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
GO

-- propiedad

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
GO
-- cliente

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
GO


-- agente

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
        UPDATE AGENTE_INMOBILIARIO
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
GO

-- contrato


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
GO


-- pago

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
GO


-- visita

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
GO

--------------------------   PROCEDIMIENTOS DE ELIMINACION DE DATOS   ------------------------------------------------------------------------------------

-- direccion

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
GO

-- propietario

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
GO

-- propiedad


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
GO

-- cliente

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
GO

-- agente

CREATE PROCEDURE sp_EliminarAgente
    @ID_agente INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM AGENTE_INMOBILIARIO
        WHERE ID_agente = @ID_agente;

        PRINT 'Agente eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al eliminar agente.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    END CATCH
END
GO

-- contrato

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
GO

-- pago

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
GO

-- visita


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
GO



-------------------- INSERCION DE DATOS UTILIZANDO PROCEDIMIENTOS ----------------------------------------

------- direccion -----------
EXEC sp_InsertarDireccion 'Av. Rivadavia', '1234', 'Caballito', 'CABA', 'Buenos Aires', '1405', '1', '3', 'Frente a la plaza';
EXEC sp_InsertarDireccion 'Calle Falsa', '742', 'Springfield', 'Springfield', 'Illinois', '62704', '3', '10', 'Departamento amplio';
EXEC sp_InsertarDireccion 'Av. Corrientes', '8800', 'Villa Crespo', 'CABA', 'Buenos Aires', '1414', '7', '14', '';
EXEC sp_InsertarDireccion 'Av. Belgrano', '456', 'San Cristobal', 'CABA', 'Buenos Aires', '1200', '12', '32', 'Sin observaciones';
EXEC sp_InsertarDireccion 'Calle Mitre', '1500', 'Centro', 'Rosario', 'Santa Fe', '2000', '1', '2', 'Con balcón';
EXEC sp_InsertarDireccion 'Ruta 8', '800', 'Pilar', 'Pilar', 'Buenos Aires', '1629', '7', '10', 'Casa quinta';
EXEC sp_InsertarDireccion 'Sarmiento', '135', 'Centro', 'Mendoza', 'Mendoza', '5500', '5', '13', 'Muy luminosa';
EXEC sp_InsertarDireccion 'Av. Libertador', '3456', 'Núñez', 'CABA', 'Buenos Aires', '1429', '10', 'G', 'Vista al río';
EXEC sp_InsertarDireccion 'San Juan', '789', 'Sur', 'San Juan', 'San Juan', '5400', '2', '11', 'Balcon a la calle';
EXEC sp_InsertarDireccion 'Av. San Martín', '1000', 'Centro', 'Córdoba', 'Córdoba', '5000', '4', '19', 'Reciclado a nuevo';
EXEC sp_InsertarDireccion 'Italia', '245', 'Norte', 'La Plata', 'Buenos Aires', '1900', '6', '6', '';
EXEC sp_InsertarDireccion 'Av. Colón', '321', 'Centro', 'Salta', 'Salta', '4400', '5', '13', 'Ideal para oficina';
EXEC sp_InsertarDireccion 'España', '999', 'Casco Histórico', 'San Miguel de Tucumán', 'Tucumán', '4000', '8', '18', 'Edificio moderno';
EXEC sp_InsertarDireccion 'Uruguay', '654', 'Microcentro', 'CABA', 'Buenos Aires', '1015', '9', '21', 'Apto profesional';
EXEC sp_InsertarDireccion 'Brasil', '111', 'Zona Sur', 'Posadas', 'Misiones', '3300', '2', '4', 'Zona centrica';

------ propietario ---------

EXEC sp_InsertarPropietario 'Juan', 'Pérez', '1156781234', '2023-01-10', '1980-06-15', 1, '20-12345678-9';
EXEC sp_InsertarPropietario 'María', 'González', '1167892345', '2023-01-15', '1985-08-20', 1, '27-23456789-0';
EXEC sp_InsertarPropietario 'Carlos', 'López', '1178903456', '2023-02-01', '1975-02-10', 1, '23-34567890-1';
EXEC sp_InsertarPropietario 'Laura', 'Martínez', '1189014567', '2023-02-10', '1990-12-01', 1, '26-45678901-2';
EXEC sp_InsertarPropietario 'Roberto', 'Díaz', '1190125678', '2023-03-01', '1982-11-22', 1, '20-56789012-3';
EXEC sp_InsertarPropietario 'Ana', 'Sánchez', '1111236789', '2023-03-15', '1978-09-05', 1, '27-67890123-4';
EXEC sp_InsertarPropietario 'Jorge', 'Ramírez', '1122347890', '2023-04-01', '1983-03-03', 1, '23-78901234-5';
EXEC sp_InsertarPropietario 'Lucía', 'Fernández', '1133458901', '2023-04-20', '1991-07-19', 1, '26-89012345-6';
EXEC sp_InsertarPropietario 'Diego', 'Herrera', '1144569012', '2023-05-01', '1989-10-10', 1, '20-90123456-7';
EXEC sp_InsertarPropietario 'Valeria', 'Torres', '1155670123', '2023-05-20', '1987-04-08', 1, '27-01234567-8';
EXEC sp_InsertarPropietario 'Martín', 'Gómez', '1166781234', '2023-06-01', '1981-06-21', 1, '23-12345678-9';
EXEC sp_InsertarPropietario 'Camila', 'Rojas', '1177892345', '2023-06-15', '1992-02-17', 1, '26-23456789-0';
EXEC sp_InsertarPropietario 'Facundo', 'Castro', '1188903456', '2023-07-01', '1984-11-12', 1, '20-34567890-1';
EXEC sp_InsertarPropietario 'Romina', 'Silva', '1199014567', '2023-07-20', '1993-08-09', 1, '27-45678901-2';
EXEC sp_InsertarPropietario 'Tomás', 'Vega', '1100125678', '2023-08-01', '1995-05-05', 1, '23-56789012-3';


------ cliente --------

EXEC sp_InsertarCliente '30111222', 'Juan', 'Pérez', 1, '1985-03-15', '2023-01-01', '1156781234';
EXEC sp_InsertarCliente '30222333', 'María', 'González', 1, '1990-07-22', '2023-01-05', '1167892345';
EXEC sp_InsertarCliente '30333444', 'Carlos', 'López', 1, '1978-11-30', '2023-01-10', '1178903456';
EXEC sp_InsertarCliente '30444555', 'Ana', 'Martínez', 1, '1989-04-10', '2023-01-12', '1189014567';
EXEC sp_InsertarCliente '30555666', 'Roberto', 'Díaz', 1, '1982-02-01', '2023-01-15', '1190125678';
EXEC sp_InsertarCliente '30666777', 'Laura', 'Sánchez', 1, '1991-09-18', '2023-01-18', '1111236789';
EXEC sp_InsertarCliente '30777888', 'Sofía', 'Gutiérrez', 1, '1995-12-05', '2023-01-22', '1122347890';
EXEC sp_InsertarCliente '30888999', 'Luis', 'Romero', 1, '1976-06-23', '2023-01-25', '1133458901';
EXEC sp_InsertarCliente '30999000', 'Marta', 'Fernández', 1, '1987-05-11', '2023-01-28', '1144569012';
EXEC sp_InsertarCliente '30100111', 'Jorge', 'Alvarez', 1, '1980-01-20', '2023-02-01', '1155670123';
EXEC sp_InsertarCliente '31000222', 'Julia', 'Herrera', 1, '1992-03-27', '2023-02-05', '1166781234';
EXEC sp_InsertarCliente '31111333', 'Diego', 'Rodríguez', 1, '1983-10-13', '2023-02-10', '1177892345';
EXEC sp_InsertarCliente '31222444', 'Patricia', 'Castro', 1, '1990-06-30', '2023-02-15', '1188903456';
EXEC sp_InsertarCliente '31333555', 'Oscar', 'Ruiz', 1, '1975-11-08', '2023-02-20', '1199014567';
EXEC sp_InsertarCliente '31444666', 'Carla', 'Morales', 1, '1993-04-15', '2023-02-25', '1100125678';


------- agente inmobiliario -----------

EXEC sp_InsertarAgente '40111222', 'Ignacio', 'Giménez', '1122334455', '10', '1980-10-10', '2025-01-01', 1;
EXEC sp_InsertarAgente '40222333', 'Luciana', 'Prieto', '1133445566', '12', '1985-09-12', '2025-01-05', 1;
EXEC sp_InsertarAgente '40333444', 'Esteban', 'Suárez', '1144556677', '15', '1978-03-25', '2025-01-08', 1;
EXEC sp_InsertarAgente '40444555', 'Pamela', 'Ruiz', '1155667788', '8', '1989-06-30', '2025-01-10', 1;
EXEC sp_InsertarAgente '40555666', 'Martín', 'Vera', '1166778899', '11', '1982-07-19', '2025-01-15', 1;
EXEC sp_InsertarAgente '40666777', 'Cecilia', 'Acosta', '1177889900', '14', '1991-05-05', '2025-01-18', 1;
EXEC sp_InsertarAgente '40777888', 'Fernando', 'Cáceres', '1188990011', '9', '1990-08-08', '2025-01-22', 1;
EXEC sp_InsertarAgente '40888999', 'Soledad', 'Ibarra', '1199001122', '13', '1984-11-15', '2025-01-25', 1;
EXEC sp_InsertarAgente '40999000', 'Federico', 'Moyano', '1100112233', '10', '1987-12-12', '2025-01-28', 1;
EXEC sp_InsertarAgente '41000111', 'Paula', 'Rivera', '1111223344', '7', '1993-03-03', '2025-02-01', 1;
EXEC sp_InsertarAgente '41111222', 'Santiago', 'Delgado', '1122334455', '10', '1995-01-01', '2025-02-05', 1;
EXEC sp_InsertarAgente '41222333', 'Agustina', 'Peralta', '1133445566', '12', '1990-06-10', '2025-02-10', 1;
EXEC sp_InsertarAgente '41333444', 'Tomás', 'Herrera', '1144556677', '11', '1988-09-30', '2025-02-15', 1;
EXEC sp_InsertarAgente '41444555', 'Camila', 'Sosa', '1155667788', '9', '1986-04-04', '2025-02-20', 1;
EXEC sp_InsertarAgente '41555666', 'Andrés', 'Moreno', '1166778899', '13', '1981-07-07', '2025-02-25', 1;

------- propiedad ---------

EXEC sp_InsertarPropiedad 'Casa familiar en zona céntrica', 1, 550000, 150, 5, '2010-05-10', 'Casa', 1;
EXEC sp_InsertarPropiedad 'PH cómodo con patio', 2, 320000, 90, 3, '2015-08-23', 'PH', 2;
EXEC sp_InsertarPropiedad 'Departamento moderno', 3, 400000, 70, 3, '2018-11-11', 'Departamento', 3;
EXEC sp_InsertarPropiedad 'Casa antigua con jardín', 4, 600000, 200, 6, '2005-03-14', 'Casa', 4;
EXEC sp_InsertarPropiedad 'Departamento céntrico', 5, 350000, 80, 3, '2017-07-09', 'Departamento', 5;
EXEC sp_InsertarPropiedad 'PH con buena iluminación', 6, 280000, 85, 3, '2016-04-02', 'PH', 6;
EXEC sp_InsertarPropiedad 'Casa con piscina', 7, 750000, 180, 7, '2012-12-30', 'Casa', 7;
EXEC sp_InsertarPropiedad 'Departamento con balcón', 8, 380000, 75, 3, '2019-01-15', 'Departamento', 8;
EXEC sp_InsertarPropiedad 'PH renovado', 9, 290000, 88, 3, '2014-06-20', 'PH', 9;
EXEC sp_InsertarPropiedad 'Casa en barrio residencial', 10, 620000, 170, 6, '2011-09-17', 'Casa', 10;
EXEC sp_InsertarPropiedad 'Departamento nuevo', 11, 450000, 78, 3, '2020-02-27', 'Departamento', 11;
EXEC sp_InsertarPropiedad 'PH con patio amplio', 12, 310000, 95, 3, '2013-10-05', 'PH', 12;
EXEC sp_InsertarPropiedad 'Casa clásica con garage', 13, 580000, 160, 5, '2009-08-29', 'Casa', 13;
EXEC sp_InsertarPropiedad 'Departamento con vista', 14, 420000, 72, 3, '2018-05-12', 'Departamento', 14;
EXEC sp_InsertarPropiedad 'PH acogedor', 15, 300000, 90, 3, '2015-11-18', 'PH', 15;

------- contrato ---------------


EXEC sp_InsertarContrato 'Entrega inmediata, sin reformas', 550000, '2025-06-10', 'Transferencia', 1, 1, 1;
EXEC sp_InsertarContrato 'Entrega inmediata, sin reformas', 320000, '2025-06-12', 'Transferencia', 2, 2, 2;
EXEC sp_InsertarContrato 'Se acepta mascota', 400000, '2025-06-14', 'Transferencia', 3, 3, 3;
EXEC sp_InsertarContrato 'Entrega inmediata, sin reformas', 600000, '2025-06-15', 'Transferencia', 4, 4, 4;
EXEC sp_InsertarContrato 'Se aceptan mascotas pequeñas', 350000, '2025-06-15', 'Transferencia', 5, 5, 5;
EXEC sp_InsertarContrato 'Entrega inmediata, sin reformas', 280000, '2025-06-14', 'Transferencia', 6, 6, 6;
EXEC sp_InsertarContrato 'Incluye mobiliario', 750000, '2025-06-16', 'Transferencia', 7, 7, 7;
EXEC sp_InsertarContrato 'Entrega a 30 días', 380000, '2025-06-21', 'Transferencia', 8, 8, 8;
EXEC sp_InsertarContrato 'Se acepta mascota', 290000, '2025-06-21', 'Transferencia', 9, 9, 9;
EXEC sp_InsertarContrato 'Entrega inmediata, sin reformas', 620000, '2025-06-24', 'Transferencia', 10, 10, 10;
EXEC sp_InsertarContrato 'Se acepta mascota', 450000, '2025-06-26', 'Transferencia', 11, 11, 11;
EXEC sp_InsertarContrato 'Entrega con llave', 310000, '2025-06-01', 'Transferencia', 12, 12, 12;
EXEC sp_InsertarContrato 'Entrega inmediata, sin reformas', 580000, '2025-06-01', 'Transferencia', 13, 13, 13;
EXEC sp_InsertarContrato 'Incluye cochera', 420000, '2025-06-01', 'Transferencia', 14, 14, 14;
EXEC sp_InsertarContrato 'Sin mascotas', 300000, '2025-06-01', 'Transferencia', 15, 15, 15;


------- visita -----------

EXEC sp_InsertarVisita '2025-06-01', 'Cliente interesado, pedir más fotos', 1, 1;
EXEC sp_InsertarVisita '2025-06-03', 'Visita con posibilidad de oferta', 1, 2;
EXEC sp_InsertarVisita '2025-06-05', 'Cliente quiere visitar en la tarde', 1, 3;
EXEC sp_InsertarVisita '2025-06-07', 'CLiente interesado', 1, 4;
EXEC sp_InsertarVisita '2025-06-10', 'Cliente quiere saber sobre gastos comunes', 1, 5;
EXEC sp_InsertarVisita '2025-06-12', 'Cliente interesado', 1, 6;
EXEC sp_InsertarVisita '2025-06-15', 'Visita con familia numerosa', 1, 7;
EXEC sp_InsertarVisita '2025-06-18', 'Interesados en financiación', 1, 8;
EXEC sp_InsertarVisita '2025-06-20', 'Visita programada para la tarde', 1, 9;
EXEC sp_InsertarVisita '2025-06-22', 'Cliente quiere comparar con otra propiedad', 1, 10;
EXEC sp_InsertarVisita '2025-06-25', 'Visita con agente de confianza', 1, 11;
EXEC sp_InsertarVisita '2025-06-27', 'Cliente solicita planos de la propiedad', 0, 12;
EXEC sp_InsertarVisita '2025-06-30', 'Interesados en barrio seguro', 0, 13;
EXEC sp_InsertarVisita '2025-07-02', 'Visita programada', 0, 14;
EXEC sp_InsertarVisita '2025-07-05', 'Cliente muy interesado, posible oferta', 0, 15;










GO
----VISTAS----------------------------------------------------------------------------------------------------------------------------------------------
--1 --  ver propiedades que valgan mas de 500000 
CREATE VIEW VISTA_PROPIEDADES_VALOR_MAS_500000 AS
SELECT 
    ID_propiedad,
    Descripcion,
    Valor_usd,
    Metros_cuadrados,
    Cantidad_ambientes,
    Fecha_contruccion,
    Tipo,
    ID_propietario,
    ID_direccion
FROM PROPIEDAD
WHERE Valor_usd > 500000;
GO


			---Ejecuto---

SELECT ID_propiedad,
    Descripcion,
    Valor_usd,
    Metros_cuadrados,
    Cantidad_ambientes,
    Fecha_contruccion,
    Tipo,
    ID_propietario,
    ID_direccion 
FROM VISTA_PROPIEDADES_VALOR_MAS_500000;
GO



---2 --- ver propiedades que valgan mas de 250000
CREATE VIEW VISTA_PROPIEDADES_MENORES_250000 AS
SELECT 
    ID_propiedad,
    Descripcion,
    Valor_usd,
    Metros_cuadrados,
    Cantidad_ambientes,
    Fecha_contruccion,
    Tipo,
    ID_propietario,
    ID_direccion
FROM PROPIEDAD
WHERE Valor_usd < 250000;
GO

			---Ejecuto---

SELECT ID_propiedad,
    Descripcion,
    Valor_usd,
    Metros_cuadrados,
    Cantidad_ambientes,
    Fecha_contruccion,
    Tipo,
    ID_propietario,
    ID_direccion 
FROM VISTA_PROPIEDADES_MENORES_250000;
GO


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
GO

---- ejecuto ------

SELECT ID_propiedad,
	Descripcion,
	Valor_usd,
	Metros_cuadrados,
	Cantidad_ambientes,
	Fecha_contruccion,
	Tipo, Propietario,
	Direccion
FROM vw_PropiedadesDetalladas;
GO





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
JOIN AGENTE_INMOBILIARIO a ON c.ID_agente = a.ID_agente
JOIN PROPIEDAD p ON c.ID_propiedad = p.ID_propiedad;
GO

---- ejecuto -----

SELECT ID_contrato,
	Fecha,
	Forma_pago,
	Precio_final,
	Condiciones,
	Cliente,
	Agente,
	Propiedad
FROM vw_ContratosCompletos;
GO


----- vista de visitas pendientes
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
WHERE v.Estado = 0; -- seleccionar solo las que esten pendientes (estado = 0)
GO


---- ejecuto -----

SELECT ID_visita,
	Fecha_visita,
	Comentarios,
	Propiedad,
	Direccion
FROM vw_VisitasPendientes;
GO
------ vista de propiedades por ciudad (promedio de precio y ambientes)
CREATE OR ALTER VIEW vw_PropiedadesPorCiudad AS
SELECT 
    d.Ciudad,
    COUNT(p.ID_propiedad) AS Cantidad_Propiedades,
    AVG(p.Valor_usd) AS Precio_Promedio,
    AVG(p.Cantidad_ambientes) AS Ambientes_Promedio
FROM PROPIEDAD p
JOIN DIRECCION d ON p.ID_direccion = d.ID_direccion
GROUP BY d.Ciudad;
GO

--- ejecuto ----

SELECT
	Ciudad,
	Cantidad_Propiedades,
	Precio_Promedio,
	Ambientes_promedio
FROM vw_PropiedadesPorCiudad;
GO
------ vista de clientes con mayor cantidad de contratos -------------
CREATE OR ALTER VIEW vw_ClientesConMasContratos AS
SELECT 
    cl.ID_cliente,
    cl.Nombre + ' ' + cl.Apellido AS Cliente,
    COUNT(c.ID_contrato) AS Cantidad_Contratos
FROM CLIENTE cl
LEFT JOIN CONTRATO c ON cl.ID_cliente = c.ID_cliente
GROUP BY cl.ID_cliente, cl.Nombre, cl.Apellido
GO

---- ejecuto ----

SELECT
	ID_cliente,
	Cliente,
	Cantidad_Contratos
FROM vw_ClientesConMasContratos
ORDER BY Cantidad_Contratos DESC;
GO

------------ procedimientos almacenados con valor para el sistema -----------------------------------------------------------------------------------------------------


----contratos con pagos pendientes (cantidad y porcentaje)---
GO
CREATE OR ALTER PROCEDURE sp_ContratosConPagosPendientes
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalContratos INT = (SELECT COUNT(*) FROM CONTRATO);

    DECLARE @ContratosPendientes INT = (
        SELECT COUNT(DISTINCT c.ID_contrato)
        FROM CONTRATO c
        JOIN PAGO p ON c.ID_contrato = p.ID_contrato
        WHERE p.Estado_pago = 0
    );

    SELECT 
        @TotalContratos AS Total_Contratos,
        @ContratosPendientes AS Contratos_Pendientes,
        CAST(ROUND(CAST(@ContratosPendientes AS FLOAT) * 100 / @TotalContratos, 2) AS DECIMAL(5,2)) AS Porcentaje_Pendientes;
END;


---- ejecuto ----

EXEC sp_ContratosConPagosPendientes;

---- calcular los pagos en un rango de fechas --
GO
CREATE OR ALTER PROCEDURE sp_TotalRecaudadoPorFecha
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- si son null muestra los datos de el ultimo trimestre
    IF @FechaInicio IS NULL SET @FechaInicio = DATEADD(MONTH, -3, GETDATE());
    IF @FechaFin IS NULL SET @FechaFin = GETDATE();

    SELECT
        SUM(Monto) AS Total_Recaudado
    FROM PAGO
    WHERE Estado_pago = 1
      AND Fecha_pago BETWEEN @FechaInicio AND @FechaFin;
END;


-----ejecuto -----


EXEC sp_TotalRecaudadoPorFecha @FechaInicio = '2025-05-30',  @FechaFin = '2025-06-30';


-----el tiempo promedio que pasa entre una visita y un contrato
GO
CREATE OR ALTER PROCEDURE sp_TiempoPromedioVisitaContrato
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        AVG(DATEDIFF(DAY, v.Fecha_visita, c.Fecha)) AS Promedio_Dias_Visita_Contrato
    FROM VISITA v
    JOIN CONTRATO c ON v.ID_propiedad = c.ID_propiedad
    WHERE v.Estado = 1
      AND c.Fecha >= v.Fecha_visita;
END;


-----ejecuto -----


EXEC sp_TiempoPromedioVisitaContrato;








----READ---


SELECT * FROM PROPIEDAD WHERE Fecha_contruccion>'2020-01-01';

SELECT Nombre, Apellido, COUNT(ID_propietario) AS Cantidad_propiedades FROM PROPIETARIO GROUP BY Nombre, Apellido;

SELECT Nombre,Apellido FROM CLIENTE WHERE Nombre LIKE 'L%' or Apellido LIKE '%o';

SELECT ID_cliente, Nombre, Apellido FROM CLIENTE WHERE Telefono IS NULL;

SELECT ID_visita, Comentarios, Estado, ID_propiedad FROM VISITA WHERE Fecha_visita >= DATEADD(DAY, -7, GETDATE());

SELECT ID_CLIENTE, Nombre, Apellido, Fecha_registro FROM CLIENTE WHERE Fecha_registro >= DATEADD(MONTH, -1, GETDATE());

SELECT ID_agente, Nombre, Apellido, Comision FROM AGENTE_INMOBILIARIO WHERE Estado = 1 AND Comision IS NOT NULL;

SELECT ID_propietario, Nombre, Apellido, Cuit FROM PROPIETARIO WHERE Cuit IS NOT NULL AND Estado = 1;

SELECT ID_pago, Fecha_pago, Monto, Metodo_pago FROM PAGO WHERE Estado_pago = 0;


----- consulta cantidad de contratos por barrio (teniendo en cuenta la cantidad de propiedades) -------

SELECT 
    D.Barrio AS Barrio,
    COUNT(C.ID_contrato) AS Cantidad_Contratos,
    COUNT(DISTINCT P.ID_propiedad) AS Cantidad_Propiedades
FROM DIRECCION D
LEFT JOIN PROPIEDAD P ON D.ID_direccion = P.ID_direccion
LEFT JOIN CONTRATO C ON P.ID_propiedad = C.ID_propiedad
GROUP BY D.Barrio
ORDER BY Cantidad_Contratos DESC;




---TRIGGERS---------------------------------------------------------------------------------------------------------------------------------
GO
CREATE TRIGGER TR_CompletarPagoAutomaticamente
ON CONTRATO
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO PAGO (
        Fecha_pago, 
        Monto, 
        Metodo_pago, 
        Descripcion, 
        Estado_pago, 
        ID_contrato
    )
    SELECT 
        GETDATE(),                            
        i.Precio_final,                       
        'Transferencia',                      ------ esto esta por default, no se acepta otro metodo
        CONCAT('Pago inicial para contrato ID: ', i.ID_contrato),
        0,                                    ------ se crea en pendiente el pago
        i.ID_contrato                         
    FROM inserted i;
END;


------ trigger para agregar fecha de registro al cliente si esta se agrego como null
GO
CREATE TRIGGER TR_agregarFechaPredeterminadaCliente
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
GO
CREATE TRIGGER TR_VisitaUnicaSinRepetir
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

SELECT COUNT(*) AS Total_Propiedades FROM PROPIEDAD;

SELECT AVG(Valor_usd) AS Precio_Promedio FROM PROPIEDAD;

SELECT MIN(Valor_usd) AS Precio_Minimo FROM PROPIEDAD;

SELECT MAX(Valor_usd) AS Precio_Maximo FROM PROPIEDAD;
GO


----FUNCIONES -------------------------------------------------------------------------------------

--- ranking barrios por precio de metro cuadrado promedio

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
);
GO
----ejecuto -----

SELECT Barrio, Precio_Promedio_Metro_Cuadrado FROM fn_BarriosMayorPrecioMetroCuadrado()
ORDER BY Precio_Promedio_Metro_Cuadrado DESC;
GO



----- cantidad de contratos por cliente

CREATE OR ALTER FUNCTION fn_ContratosPorCliente
(
    @ID_cliente INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        c.ID_contrato,
        c.Fecha,
        c.Forma_pago,
        c.Precio_final,
        c.Condiciones,
        p.Descripcion AS Propiedad,
        a.Nombre + ' ' + a.Apellido AS Agente
    FROM CONTRATO c
    JOIN PROPIEDAD p ON c.ID_propiedad = p.ID_propiedad
    JOIN AGENTE_INMOBILIARIO a ON c.ID_agente = a.ID_agente
    WHERE c.ID_cliente = @ID_cliente
);
GO

------- ejecuto -------

SELECT ID_contrato,
	Fecha,
	Forma_pago,
	Precio_final,
	Condiciones,
	Propiedad,
	Agente
FROM fn_ContratosPorCliente(1);