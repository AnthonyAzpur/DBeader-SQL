USE [BD_INTRANET]
GO
/****** Object:  StoredProcedure [transporte].[sp_resolucion]    Script Date: 10/04/2025 12:11:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [transporte].[sp_resolucion]
    @numero_resolucion VARCHAR(200),
    @padron INT,
    @emision DATE,
    @cese DATE,
    @id_zona BIGINT,
    @id_juridica BIGINT,
    @id_usuario BIGINT,
    @mensaje NVARCHAR(500) OUTPUT
AS
BEGIN
    SET @mensaje = ISNULL(@mensaje, '');

    BEGIN TRY
        BEGIN TRANSACTION

        SET @numero_resolucion = LTRIM(RTRIM(UPPER(@numero_resolucion)));

        IF EXISTS (SELECT 1 FROM transporte.t_resolucion WHERE numero_resolucion = @numero_resolucion AND estado = 1)
        BEGIN
            SET @mensaje = 'La resolución ya existe.';
            PRINT 'La resolución ya existe: ' + @numero_resolucion;
        END
        ELSE
        BEGIN
            INSERT INTO transporte.t_resolucion (
                numero_resolucion,
                padron,
                id_zona,
                id_juridica,
                id_usuario,
                emision,
                cese,
                estado,
                host,
                created_at
            )
            VALUES (
                @numero_resolucion,
                @padron,
                @id_zona,
                @id_juridica,
                @id_usuario,
                @emision,
                @cese,
                1,
                HOST_NAME(),
                GETDATE()
            );

            SET @mensaje = 'SE REGISTRÓ CORRECTAMENTE';
            PRINT 'Resolución registrada correctamente: ' + @numero_resolucion;
        END

        COMMIT TRANSACTION;

        PRINT 'Transacción completada con éxito.';
        SELECT @mensaje AS mensaje;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        SET @mensaje = 'Ocurrió un error: ' + ERROR_MESSAGE();
        PRINT 'Error ocurrido: ' + ERROR_MESSAGE();

        SELECT @mensaje AS mensaje;
    END CATCH;
END
