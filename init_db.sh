. config/settings.ini

# Utilisation des variables dans des commandes (par exemple, pour se connecter à la base de données)
export PGPASSWORD=$user_pg_pass
psql -d $db_name -U $user_pg -h $db_host -p $db_port \
	-v _areas=$areas \
	-f data/init_db.sql

