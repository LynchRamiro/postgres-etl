# ETL para la carga de *datasets* de Precio de Gas natural en Argentina

## Descarga de datasets

Los datasets utilizados en este proyecto pueden descargarse desde el portal oficial de datos abiertos del gobierno de Argentina: https://datos.gob.ar/dataset

Este portal proporciona información pública en formatos reutilizables, incluyendo datos relacionados con el precio del gas natural en Argentina.

## Resumen del tutorial

Este tutorial guía al usuario a través de los pasos necesarios para desplegar una infraestructura ETL utilizando Docker, PostgreSQL y  Apache Superset.

1. Levantar los servicios con Docker.  
2. Configurar la conexión a la base de datos en Apache Superset.  
3. Ejecutar consultas SQL para analizar los datos de casos de dengue.  
4. Crear gráficos y tableros interactivos para la visualización de datos.

## Palabras claves

* Docker  
* PostgreSQL  
* Apache Superset  
* pgAdmin  
* ETL  
* Visualización de Datos

## Mantenido Por

Costamagna Martín  
Giagnorio Gabriel  
Lynch Ramiro  
Mana Guido  
Pajon Valentino  
Rocha Gianella  
Testa Cecilia  
Villarreal Camila

## Descargo de Responsabilidad

El código proporcionado se ofrece "tal cual", sin garantía de ningún tipo, expresa o implícita. En ningún caso los autores o titulares de derechos de autor serán responsables de cualquier reclamo, daño u otra responsabilidad.

## Descripción del Proyecto

Este proyecto implementa un proceso ETL (Extract, Transform, Load) para la carga y análisis de datos relacionados con el precio del gas en Argentina. Utiliza herramientas modernas como Docker, PostgreSQL y  Apache Superset para facilitar la gestión, análisis y visualización de datos.

El objetivo principal es proporcionar una solución escalable y reproducible para analizar datos de dengue por grupo etario, departamento y provincia, permitiendo la creación de tableros interactivos y gráficos personalizados.

## Características Principales

* **Infraestructura Contenerizada:** Uso de Docker para simplificar la configuración y despliegue.  
* **Base de Datos Relacional:** PostgreSQL para almacenar y gestionar los datos.  
* **Visualización de Datos:** Apache Superset para crear gráficos y tableros interactivos.

## Requisitos Previos

* Docker  
* Docker Compose  
* Navegador web para acceder a Apache Superset 

## Servicios Definidos en Docker Compose

El archivo *docker-compose.yml* define los siguientes servicios:

1. **Base de Datos (PostgreSQL):**

  db:  
    image: postgres:alpine  
    restart: unless-stopped  
    volumes:  
      - postgres-db:/var/lib/postgresql/data  
      - ./initdb:/docker-entrypoint-initdb.d  
      - ./datos:/datos  
    environment:  
      - POSTGRES_USER=postgres  
      - POSTGRES_PASSWORD=postgres  
      - POSTGRES_DB=tpdml  
    ports:  
      - 5432:5432  
    networks:  
      - net  
    healthcheck:  
      test: ["CMD", "pg_isready", "-U", "postgres"]  
      interval: 10s  
      timeout: 5s  
      retries: 5

2. **Apache Superset**

superset:  
    image: apache/superset:4.0.0  
    restart: unless-stopped  
    env_file:  
      - .env.db  
    ports:  
      - 8088:8088  
    depends_on:  
      db:  
        condition: service_healthy # Aguarda hasta que la base de datos esté funcionando correctamente  
    networks:  
      - net

## Instrucciones de Configuración

1. **Clonar el repositorio**  
   git clone <URL_DEL_REPOSITORIO>  
   cd postgres-etl  
2. **Configurar el archivo .[env.db](http://env.db) con las siguientes variables de entorno:**  
   # Base de datos PostgreSQL  
   DATABASE_HOST=db  
   DATABASE_PORT=5432  
   DATABASE_NAME=tpdml  
   DATABASE_USER=postgres  
   DATABASE_PASSWORD=postgres  
     
   # PostgreSQL init args  
   POSTGRES_INITDB_ARGS="--auth-host=scram-sha-256 --auth-local=trust"  
   POSTGRES_PASSWORD=${DATABASE_PASSWORD}  
   PGUSER=${DATABASE_USER}  
     
   # pgAdmin (si decides usarlo luego)  
   PGADMIN_DEFAULT_EMAIL=postgres@postgresql.com  
   PGADMIN_DEFAULT_PASSWORD=${DATABASE_PASSWORD}  
     
   # Superset  
   SUPERSET_SECRET_KEY=9f3c38df8db2b2a4c619ea42d7e0cc90  
   SQLALCHEMY_DATABASE_URI=postgresql+psycopg2://${DATABASE_USER}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}  
3. **Levantar los servicios: Ejecuta los siguientes comandos para iniciar los contenedores:**  
   Docker compose up  
4. **Acceso a las herramientas**  
   Apache Superset: http://localhost:8088/  
   Credenciales predeterminadas: admin/admin

## Uso del proyecto

1. **Configuración de la base de datos**  
   Accede a Apache Superset y crea una conexión a la base de datos PostgreSQL en la sección Settings. Asegúrate de que la conexión sea exitosa antes de proceder.  
2. **Consultas SQL**  
   Consulta 1: **precios de la cuenca neuquina**  
   Esta consulta permite visualizar todos los precios de la cuenca neuquina  
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
   Consulta 2: **todos los precios de exportación con contrato FIRME ordenados de mayor a menor**  
   Esta consulta filtra todos los precios de exportación con contrato firme y los ordena de mayor a menor  
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
   Consulta 3: **Las últimas 10 publicaciones de los precios de la cuenca Austral Santa Cruz.**  
   Esta consulta filtra las últimas 10 publicaciones de los precios de la cuenca Austral Santa Cruz  
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

   ## Creación de gráficos y tableros

1. Ejecuta las consultas en SQL Lab de Apache Superset.  
2. Haz clic en el botón CREATE CHART para crear gráficos interactivos.  
3. Configura el tipo de gráfico y las dimensiones necesarias.  
4. Guarda el gráfico en un tablero con el botón SAVE.

## Estructura del proyecto

postgres-etl/  
├── docker-compose.yml       # Configuración de Docker Compose  
├── init.sh                  # Script de inicialización  
├── data/                    # Carpeta para almacenar datasets  
├── sql/                     # Consultas SQL predefinidas  
└── README.md                # Documentación del proyecto  
