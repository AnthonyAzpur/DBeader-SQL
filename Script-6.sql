	SELECT [id], [emision], [id_funcionario]
	FROM [BD_INTRANET].[salud].[s_certificado]
	WHERE [emision] >= '2025-01-01' 
	  AND [emision] <= GETDATE();
	  --
	  UPDATE [BD_INTRANET].[salud].[s_certificado]
SET [id_funcionario] = 3
WHERE [emision] >= '2025-01-01' 
  AND [emision] <= GETDATE();
  --
  UPDATE [BD_INTRANET].[salud].[s_certificado]
SET [id_funcionario] = 2
WHERE [emision] >= '2024-06-24' 
  AND [emision] <= '2024-12-30';
  --
    select *from [BD_INTRANET].[salud].[s_certificado]

WHERE [emision] >= '2024-06-24' 
  AND [emision] <= '2024-12-30';
  --
  UPDATE [BD_INTRANET].[salud].[s_certificado]
SET [id_funcionario] = 1
WHERE [emision] >= '2023-06-29' 
  AND [emision] <= '2024-06-21';
  --

  SELECT [id], [emision], [id_funcionario]
FROM [BD_INTRANET].[salud].[s_carnet]
WHERE [emision] >= '2024-06-24' 
  AND [emision] <= '2024-12-30';
  --
  select *from  [BD_INTRANET].[salud].[s_carnet]

WHERE [emision] >= '2024-06-24' 
  AND [emision] <= '2024-12-30';
