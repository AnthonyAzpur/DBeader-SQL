USE [BD_INTRANET]
GO
/****** Object:  StoredProcedure [salud].[sp_generar_carnet]    Script Date: 20/03/2025 17:22:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [salud].[sp_generar_carnet] 
    @id_pers INT,
    @manipula INT, 
    @id_giro INT,
    @id_usuario INT,
    @ocupacion VARCHAR(100),
    @num_rec VARCHAR(20)  -- Asegúrate de que 'num_rec' siempre sea VARCHAR
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @existe_vigente INT;
    DECLARE @id INT;
    DECLARE @numero VARCHAR(20);  -- 'numero' también como VARCHAR
    DECLARE @fecha_emision DATE = GETDATE(); 
    DECLARE @fecha_vencimiento DATE;
    DECLARE @existe_num_rec INT;
    DECLARE @id_carnet INT;  
    DECLARE @host VARCHAR(255);  -- Asignaremos el hostname aquí
    DECLARE @deleted_at DATETIME;
    DECLARE @created_at DATETIME;
    DECLARE @num_rec_usado INT;
    DECLARE @id_funcionario INT; -- Para almacenar el id del funcionario (cambio de id_firma a id_funcionario)

    -- Asignar el host usando el nombre del servidor
    SET @host = HOST_NAME();

    -- Si el host es NULL, asignar un valor por defecto
    IF @host IS NULL OR @host = ''
    BEGIN
        SET @host = 'Desconocido';
    END

    -- Verificación de si el recibo ya ha sido utilizado
    PRINT 'Comenzando la validación del número de recibo @num_rec = ' + @num_rec;
    
    -- Verificar cuántas veces ha sido utilizado el recibo y obtener las fechas si ya se ha utilizado
    SELECT 
        @num_rec_usado = COUNT(*)
    FROM salud.s_carnet
    WHERE num_rec = @num_rec;  -- 'num_rec' siempre se maneja como VARCHAR

    -- Si el recibo no ha sido utilizado nunca, proceder sin más validaciones
    IF @num_rec_usado = 0
    BEGIN
        PRINT 'El recibo nunca ha sido utilizado, procediendo sin validaciones adicionales.';
    END
    ELSE
    BEGIN
        -- Si el recibo ha sido utilizado más de una vez, no permitir su reutilización
        IF @num_rec_usado >= 2
        BEGIN
            PRINT 'El recibo ha sido utilizado más de una vez y no puede ser reutilizado.';
            SELECT 'El recibo ha sido utilizado más de una vez y no puede ser reutilizado.' AS mensaje;
            RETURN;
        END

        -- Obtener las fechas `deleted_at` y `created_at` si ya se ha utilizado el recibo
        SELECT 
            @deleted_at = deleted_at,
            @created_at = created_at
        FROM salud.s_carnet
        WHERE num_rec = @num_rec
        AND estado = 0 -- Solo considerar si el estado es anulado

        -- Verificar si el recibo está anulado y cumplir con las fechas
        IF @deleted_at IS NOT NULL AND @created_at IS NOT NULL
        BEGIN
            -- Validar la condición de "deleted_at" (menos de 3 horas)
            IF DATEDIFF(HOUR, @deleted_at, GETDATE()) <= 3
            BEGIN
                -- Validar que la fecha de creación (created_at) no supere los 2 días
                IF DATEDIFF(DAY, @created_at, GETDATE()) <= 2
                BEGIN
                    PRINT 'El recibo es válido para su reutilización.';
                END
                ELSE
                BEGIN
                    PRINT 'El recibo fue creado hace más de 2 días y no se puede reutilizar.';
                    SELECT 'El recibo fue creado hace más de 2 días y no se puede reutilizar.' AS mensaje;
                    RETURN;
                END
            END
            ELSE
            BEGIN
                PRINT 'El recibo fue anulado hace más de 3 horas y no se puede reutilizar.';
                SELECT 'El recibo fue anulado hace más de 3 horas y no se puede reutilizar.' AS mensaje;
                RETURN;
            END
        END
        ELSE
        BEGIN
            PRINT 'El recibo fue utilizado No se puede reutilizar.';
            SELECT 'El recibo fue utilizado No se puede reutilizar.' AS mensaje;
            RETURN;
        END
    END

    -- Obtener el siguiente ID de la secuencia (asegurándonos de que es tipo INT)
    SELECT @id = NEXT VALUE FOR salud.seq_id_carnet; 
    PRINT 'ID generado: ' + CAST(@id AS VARCHAR);

    -- Obtener el siguiente número de la secuencia
    DECLARE @year_part VARCHAR(4) = YEAR(GETDATE());  -- Año actual
    DECLARE @next_num INT;

    -- Usamos la secuencia para obtener el siguiente número
    SELECT @next_num = NEXT VALUE FOR salud.seq_numero_carnet;

    -- Concatenar el año con el siguiente número de la secuencia y dar formato
    -- Convertimos a VARCHAR para evitar el error de tipo de datos
    SET @numero = RIGHT('0000000' + CAST(@next_num AS VARCHAR), 7) + '-' + CAST(@year_part AS VARCHAR);
    PRINT 'Número generado: ' + @numero;

    IF @manipula = 1
        SET @fecha_vencimiento = DATEADD(MONTH, 6, @fecha_emision);
    ELSE IF @manipula = 2
        SET @fecha_vencimiento = DATEADD(YEAR, 1, @fecha_emision);

    PRINT 'Fecha de emisión: ' + CAST(@fecha_emision AS VARCHAR);
    PRINT 'Fecha de vencimiento: ' + CAST(@fecha_vencimiento AS VARCHAR);

    -- Verificar si ya tiene un carnet vigente con estado 1
    SELECT @existe_vigente = COUNT(*)
    FROM salud.s_carnet
    WHERE id_pers = @id_pers AND estado = 1 AND vencimiento > GETDATE();
    
    IF @existe_vigente > 0
    BEGIN       
        PRINT 'La persona tiene un carnet vigente.';
        SELECT 'La persona tiene un carnet vigente.' AS mensaje;
        RETURN;
    END;

    -- Buscar el funcionario activo con estado 1 y cuya fecha de creación esté entre inicio y fin
    SELECT TOP 1 
        @id_funcionario = id
    FROM salud.s_funcionario
    WHERE estado = 1
    AND @fecha_emision BETWEEN inicio AND fin;

    -- Verificar si se encontró un funcionario válido
    IF @id_funcionario IS NULL
    BEGIN
        PRINT 'No se encontró un funcionario activo para firmar el carnet.';
        SELECT 'No se encontró un funcionario activo para firmar el carnet.' AS mensaje;
        RETURN;
    END

    PRINT 'Funcionario encontrado para firmar el carnet: ' + CAST(@id_funcionario AS VARCHAR);

    -- Insertar el nuevo carnet en la tabla salud.s_carnet
    PRINT 'Insertando el nuevo carnet en la tabla salud.s_carnet';
    INSERT INTO salud.s_carnet 
    (
        id, 
        numero, 
        id_pers, 
        emision, 
        vencimiento, 
        manipula, 
        id_giro, 
        id_usuario, 
        host, 
        ocupacion, 
        num_rec,
        id_funcionario, -- Aquí se usa id_funcionario
        finalizado     
    )
    VALUES 
    (
        @id, 
        @numero, 
        @id_pers, 
        @fecha_emision, 
        @fecha_vencimiento, 
        @manipula, 
        @id_giro, 
        @id_usuario, 
        @host, 
        @ocupacion, 
        @num_rec,  -- Se pasa como VARCHAR
        @id_funcionario, -- Se pasa el id_funcionario
        0
    );
    
    SELECT @id_carnet = @id;

    -- Insertar en el historial
    PRINT 'Insertando en historial dashboard';
    INSERT INTO salud.s_historial_dashboard (tipo_accion, id_afectado, id_usuario, host)
    VALUES (1, @id, @id_usuario, @host);  

    PRINT 'Carnet generado exitosamente.';
    SELECT 'Carnet generado exitosamente.' AS mensaje;
END;
