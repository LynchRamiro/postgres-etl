-- -- Consultas
\! echo -
\! echo Seleccionar todos los precios de la cuenca de Neuquén
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
    cuenca.nombre = 'Neuquina';