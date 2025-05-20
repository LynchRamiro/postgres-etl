-- Conectarse a la base
\c tpdml postgres;

-- Eliminar las tablas en orden por dependencias
DROP TABLE IF EXISTS precio CASCADE;
DROP TABLE IF EXISTS fecha CASCADE;
DROP TABLE IF EXISTS contrato CASCADE;
DROP TABLE IF EXISTS cuenca CASCADE;

-- Crear las tablas principales
CREATE TABLE cuenca (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE contrato (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE fecha (
    id SERIAL PRIMARY KEY,
    anio INT NOT NULL,
    mes INT NOT NULL
);

CREATE TABLE precio (
    id SERIAL PRIMARY KEY,
    fecha_id INT NOT NULL,
    cuenca_id INT NOT NULL,
    contrato_id INT NOT NULL,
    precio_distribuidora DECIMAL(10, 2),
    precio_gnc DECIMAL(10, 2),
    precio_usina DECIMAL(10, 2),
    precio_industria DECIMAL(10, 2),
    precio_otros DECIMAL(10, 2),
    precio_ppp DECIMAL(10, 2),
    precio_exportacion DECIMAL(10, 2),
    FOREIGN KEY (fecha_id) REFERENCES fecha(id),
    FOREIGN KEY (cuenca_id) REFERENCES cuenca(id),
    FOREIGN KEY (contrato_id) REFERENCES contrato(id)
);

-- Crear tabla temporal
CREATE TEMPORARY TABLE temp_precios (
    id_pub SERIAL PRIMARY KEY,
    anio INT NOT NULL,
    mes INT NOT NULL,
    cuenca VARCHAR(50) NOT NULL,
    contrato VARCHAR(50) NOT NULL,
    precio_distribuidora DECIMAL(10, 2),
    precio_gnc DECIMAL(10, 2),
    precio_usina DECIMAL(10, 2),
    precio_industria DECIMAL(10, 2),
    precio_otros DECIMAL(10, 2),
    precio_ppp DECIMAL(10, 2),
    precio_expo DECIMAL(10, 2),
    indice_tiempo VARCHAR(7) NOT NULL,
    fecha DATE NOT NULL
);

-- Cargar los datos a la tabla temporal (asegurate que el archivo esté dentro del contenedor)
COPY temp_precios
FROM '/datos/precios-de-gas-natural-.csv' DELIMITER ',' CSV HEADER;

-- Insertar datos únicos
INSERT INTO cuenca (nombre)
SELECT DISTINCT cuenca
FROM temp_precios
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO contrato (nombre)
SELECT DISTINCT contrato
FROM temp_precios
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO fecha (anio, mes)
SELECT DISTINCT anio, mes
FROM temp_precios
ON CONFLICT DO NOTHING;

-- Insertar los precios finales
INSERT INTO precio (
    fecha_id, cuenca_id, contrato_id, precio_distribuidora, 
    precio_gnc, precio_usina, precio_industria, precio_otros, 
    precio_ppp, precio_exportacion
)
SELECT
    f.id,
    cu.id,
    con.id,
    tp.precio_distribuidora,
    tp.precio_gnc,
    tp.precio_usina,
    tp.precio_industria,
    tp.precio_otros,
    tp.precio_ppp,
    tp.precio_expo
FROM temp_precios tp
JOIN cuenca cu ON tp.cuenca = cu.nombre
JOIN contrato con ON tp.contrato = con.nombre
JOIN fecha f ON tp.anio = f.anio AND tp.mes = f.mes
WHERE
    tp.precio_distribuidora IS NOT NULL AND
    tp.precio_gnc IS NOT NULL AND
    tp.precio_usina IS NOT NULL AND
    tp.precio_industria IS NOT NULL AND
    tp.precio_otros IS NOT NULL AND
    tp.precio_ppp IS NOT NULL AND
    tp.precio_expo IS NOT NULL;
