alter PROCEDURE [transporte].[sp_moto]
    @placa VARCHAR(50),
    @serie VARCHAR(150),  -- Número de serie
    @motor VARCHAR(150) NULL,
    @color VARCHAR(50) NULL,
    @marca VARCHAR(150) NULL,
    @modelo VARCHAR(150) NULL,
    @ano_modelo VARCHAR NULL,
    @id_conductor INT NULL,  -- ID del conductor
    @id_usuario BIGINT = NULL,  -- ID del usuario que registra
    @licencia VARCHAR(150) NULL  -- Nueva variable para la licencia
AS
BEGIN
    -- Limpiar los datos antes de usarlos, eliminando espacios en blanco
    SET @placa = REPLACE(LTRIM(RTRIM(UPPER(@placa))), ' ', '');  -- Eliminar todos los espacios internos y convertir a mayúsculas
    SET @serie = LTRIM(RTRIM(@serie));
    SET @motor = LTRIM(RTRIM(@motor));
    SET @color = LTRIM(RTRIM(@color));
    SET @marca = LTRIM(RTRIM(@marca));
    SET @modelo = LTRIM(RTRIM(@modelo));
    SET @ano_modelo = LTRIM(RTRIM(UPPER(@ano_modelo)));
    SET @licencia = LTRIM(RTRIM(@licencia));

    -- Verificar si la placa ya existe
    IF EXISTS (SELECT 1 FROM transporte.t_moto WHERE placa = @placa)
    BEGIN
        -- Si la placa ya existe, realizar la actualización de los datos y actualizar `updated_at`
        UPDATE transporte.t_moto
        SET
            numero_serie = @serie,
            numero_motor = @motor,
            color = @color,
            marca = @marca,
            modelo = @modelo,
            año_modelo = @ano_modelo,
            licencia = @licencia,
            id_conductor = @id_conductor,
            updated_at = GETDATE(),  -- Actualizar la fecha de modificación
            host = HOST_NAME()  -- Registrar el host que está haciendo la actualización
        WHERE placa = @placa;

        -- Devolver el mensaje de éxito para la actualización
        SELECT 
            (SELECT id FROM transporte.t_moto WHERE placa = @placa) AS id,
            'Moto actualizada correctamente' AS mensaje;
        RETURN;  -- Terminar la ejecución si se actualizó correctamente
    END

    -- Si la placa no existe, insertar un nuevo registro
    BEGIN TRY
        BEGIN TRANSACTION

        -- Insertar la moto
        INSERT INTO transporte.t_moto (
            id_conductor,
            id_usuario,
            numero_serie,  -- Número de serie
            numero_motor,
            color,
            marca,
            modelo,
            año_modelo,
            placa,
            licencia,  -- Insertar la licencia
            estado,
            host,
            created_at
        )
        VALUES (
            @id_conductor,
            @id_usuario,
            @serie,  -- Solo se inserta el número de serie
            @motor,
            @color,
            @marca,
            @modelo,
            @ano_modelo,
            @placa,
            @licencia,  -- Insertar la licencia
            1, -- Estado activo
            HOST_NAME(),
            GETDATE()
        );

        -- Obtener el ID de la moto recién insertada
        DECLARE @id_moto INT;
        SET @id_moto = SCOPE_IDENTITY();  -- Devuelve el último ID insertado

        -- Devolver el ID y el mensaje de éxito en dos columnas separadas
        SELECT 
            @id_moto AS id,
            'Moto registrada correctamente' AS mensaje;

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Si ocurre un error, devolver el mensaje de error
        SELECT 
            NULL AS id,
            'Ocurrió un error: ' + ERROR_MESSAGE() AS mensaje;
    END CATCH;
END
