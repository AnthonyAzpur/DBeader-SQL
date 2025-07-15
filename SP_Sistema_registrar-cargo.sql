USE BD_INTRANET;
GO

ALTER PROCEDURE sistema.sp_insertar_cargo
    @id_area INT,
    @cargo NVARCHAR(100),
    @orden INT,
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO sistema.g_cargo (
            id_area, cargo, orden, id_usuario, host
        )
        VALUES (
            @id_area, @cargo, @orden, @id_usuario, HOST_NAME()
        );
        SELECT 'Registro de cargo exitoso' AS mensaje;
    END TRY
    BEGIN CATCH

    END CATCH
END;
GO
