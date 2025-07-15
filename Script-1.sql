
  SELECT 
    pn.id AS id_natural, -- El id de la tabla d_pers_natural
    p.id AS idantiguo,  -- El id de la tabla d_persona
    p.nombre,           -- El nombre de la persona
    p.num_doc,          -- El número de documento
    p.email,            -- El correo electrónico
    p.telefono,         -- El teléfono
    p.tipo_pers,        -- El tipo de persona
    p.id_distrito,      -- El id del distrito
    p.direccion,        -- La dirección
    p.foto,             -- La foto
    p.estado,           -- El estado
    p.id_usuario,       -- El id del usuario
    p.host,             -- El host
    p.created_at      -- La fecha de creación

FROM 
    [BD_INTRANET].[sistema].[d_persona] p
JOIN 
    [BD_INTRANET].[sistema].[d_pers_natural] pn
    ON p.id = pn.id_persona  -- Aquí se asume que el id de d_persona se relaciona con el id de d_pers_natural
	--
    -- persona natural
    SELECT 
		[id]
      ,[nombre]
      ,[ape_paterno]
      ,[ape_materno]
      ,[est_civil]
      ,[tipo_doc]
      ,[genero]
      ,[fecha_nac]
      ,[nro_partida]
      ,[nro_sunarp]
      ,[estado]
      ,[id_usuario]
      ,[host]
      ,[created_at]
      
  FROM [BD_INTRANET].[sistema].[d_pers_natural]
--
  SELECT 
    c.[id],
    c.[numero],
	 d.[id] AS id_pers,
    c.[emision],
    c.[vencimiento],
    c.[manipula],
    c.[id_giro],
    c.[ocupacion],
    c.[estado],
    c.[id_usuario],
    1 as [host],
    c.[created_at],
    c.[num_rec],
    c.[qr_code],
    c.[id_funcionario],
    c.[migracion],
    c.[pdf],
    c.[numero_documento]
   
FROM 
    [BD_INTRANET].[salud].[s_carnet] c
JOIN 
    [BD_INTRANET].[sistema].[d_pers_natural] d
    ON c.[id_pers] = d.[id_persona]
	--
