. config/settings.ini # sourcing settings.ini parameters

export PGPASSWORD=$user_pg_pass 
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
	-f 'data/taxref_protection_articles.sql' 