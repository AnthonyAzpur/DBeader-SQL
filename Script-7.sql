ALTER PROCEDURE [salud].[sp_listar_certificado_2]
    @inicio DATE = NULL,    -- Fecha de inicio (opcional)
    @fin DATE = NULL        -- Fecha de fin (opcional)
AS
BEGIN
    BEGIN TRY
        DECLARE @fecha_actual DATE = GETDATE();  -- Fecha actual

        -- Si no se encuentran certificados, se retorna el mensaje
        IF NOT EXISTS (
            SELECT 1
            FROM salud.s_certificado sc
            WHERE 
                (@inicio IS NULL OR sc.emision >= @inicio)  -- Filtra por fecha de emisión
                AND (@fin IS NULL OR sc.emision <= @fin)    -- Filtra por fecha de emisión
        )
        BEGIN
            SELECT 'No se encontraron certificados en el rango de fechas especificado.' AS mensaje;
        END
        ELSE
        BEGIN
            -- Si se encuentran certificados, se retorna la información
            SELECT 
                sc.id AS id_certificado,
                dpn.nombre, 
                dpn.ape_paterno, 
                dpn.ape_materno, 
                dp.num_doc,  
                sg.nombre AS nombre_giro, 
                sc.ocupacion, 
                CASE 
                    WHEN sc.migracion = 2 THEN sc.num_rec
                    ELSE sc.numero
                END AS numero,  
                sc.emision, 
                sc.vencimiento, 
                dp.direccion,
                sc.establecimiento, 
                -- Lógica del estado según la fecha de vencimiento y el valor de estado
                CASE 
                    WHEN sc.estado = 0 THEN 'Anulado'  -- Si el estado es 0, es "Anulado"
                    WHEN sc.vencimiento < @fecha_actual THEN 'Vencido'  -- Si la fecha de vencimiento es menor a la fecha actual, el estado es "Vencido"
                    WHEN sc.vencimiento >= @fecha_actual THEN 'Vigente' -- Si la fecha de vencimiento es mayor o igual a la fecha actual, el estado es "Vigente"
                    ELSE 'Desconocido'
                END AS estado
            FROM 
                salud.s_certificado sc
            JOIN 
                sistema.d_persona dp ON sc.id_pers = dp.id  -- Se une la tabla d_persona para obtener el nombre
            JOIN 
                sistema.d_pers_natural dpn ON dp.id = dpn.id_persona
            LEFT JOIN 
                salud.s_giro sg ON sc.id_giro = sg.id
            WHERE 
                (@inicio IS NULL OR sc.emision >= @inicio)  -- Filtro por fecha de emisión
                AND (@fin IS NULL OR sc.emision <= @fin)    -- Filtro por fecha de emisión
            ORDER BY 
                sc.emision;  -- Ordenar por fecha de emisión
        END
    END TRY
    BEGIN CATCH
        -- Captura de errores
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
