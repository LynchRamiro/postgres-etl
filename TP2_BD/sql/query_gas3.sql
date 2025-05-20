-- -- Consultas
\! echo -
\! echo Seleccionar las últimas 10 publicacciones de los precios de la cuenca Austral Santa Cruz
\! echo -
SELECT
    fecha.mes || '/' || fecha.anio as "Fecha",
    cuenca.nombre as "Cuenca",
    contrato.nombre as "Contrato",
    precio_distribuidora as "Precio Distribuidora",
    precio_gnc as "Precio GNC",
    precio_usina as "Precio Usina",
    precio_industria as "Precio Industria",
    precio_otros as "Precio Otros",
    precio_ppp as "Precio PPP",
    precio_exportacion as "Precio Exportación"
FROM
    precio p
    INNER JOIN cuenca ON p.cuenca_id = cuenca.id
    INNER JOIN contrato ON p.contrato_id = contrato.id
    INNER JOIN fecha ON p.fecha_id = fecha.id
WHERE
    cuenca.nombre = 'Austral Santa Cruz'
ORDER BY
    fecha.anio DESC,
    fecha.mes DESC
LIMIT 10;