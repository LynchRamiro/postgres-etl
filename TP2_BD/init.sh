echo "clonar el git de superset"
git clone --depth=1 https://github.com/apache/superset.git

echo " crear usuario superset"
docker compose exec -it superset superset fab create-admin \
              --username admin \
              --firstname Superset \
              --lastname Admin \
              --email admin@superset.com \
              --password admin
              
echo "migramos la base de datos"
docker compose exec -it superset superset db upgrade

echo "set roles"
docker compose exec -it superset superset init