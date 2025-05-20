-- -- Consultas
\! echo -
\! echo Seleccionar todos los precios de exportación con contrato FIRME ordenados de mayor a menor
\! echo -
SELECT
    fecha.mes || '/' || fecha.anio as "Fecha",
    cuenca.nombre as "Cuenca",
    contrato.nombre as "Contrato",
    precio_exportacion as "Precio Exportación"
FROM
    precio p
    INNER JOIN cuenca ON p.cuenca_id = cuenca.id
    INNER JOIN contrato ON p.contrato_id = contrato.id
    INNER JOIN fecha ON p.fecha_id = fecha.id
WHERE
    contrato.nombre = 'FIRME'
ORDER BY
    precio_exportacion DESC;